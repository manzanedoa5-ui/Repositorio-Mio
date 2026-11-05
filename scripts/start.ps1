$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
function Invoke-Docker {
    & docker @args
    if ($LASTEXITCODE -ne 0) { throw "Docker fallo: $($args[0])" }
}
Invoke-Docker info --format '{{.ServerVersion}}'
if (!(Test-Path .env)) {
    $lines = foreach ($name in @('OPERATOR_TOKEN','REVIEWER_TOKEN','MOBILE_TOKEN')) {
        $bytes = New-Object byte[] 32
        $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
        try { $rng.GetBytes($bytes) } finally { $rng.Dispose() }
        "$name=$([Convert]::ToBase64String($bytes))"
    }
    [IO.File]::WriteAllLines((Join-Path $PWD '.env'), $lines)
}
Invoke-Docker compose up -d --build
foreach ($url in @('http://127.0.0.1:8000/health','http://127.0.0.1:5678/healthz')) {
    $ready = $false
    for ($i=0; $i -lt 90; $i++) {
        try {
            $response = Invoke-WebRequest -UseBasicParsing -Uri $url -TimeoutSec 3
            if ($response.StatusCode -eq 200) { $ready = $true; break }
        } catch { }
        Start-Sleep -Seconds 1
    }
    if (!$ready) { throw "El servicio no responde: $url. Revisa docker compose logs." }
}
$workflows = Invoke-Docker compose exec -T n8n n8n list:workflow --onlyId
if ($workflows -notcontains 'tutoriaSyntheticDemo') {
    $tokenLine = Get-Content .env | Where-Object { $_ -match '^OPERATOR_TOKEN=' } | Select-Object -First 1
    if (!$tokenLine) { throw 'Falta OPERATOR_TOKEN en .env' }
    $token = $tokenLine.Substring('OPERATOR_TOKEN='.Length)
    $credential = @(@{id='tutoriaOperator';name='TutorIA local operator';type='httpHeaderAuth';data=@{name='Authorization';value="Bearer $token"}})
    $json = ConvertTo-Json -InputObject $credential -Depth 5 -Compress
    try {
        $json | & docker compose exec -T n8n node -e "require('fs').writeFileSync('/tmp/tutoria-credential.json',require('fs').readFileSync(0),{mode:384})"
        if ($LASTEXITCODE -ne 0) { throw 'No se pudo preparar la credencial' }
        Invoke-Docker compose exec -T n8n n8n import:credentials --input=/tmp/tutoria-credential.json
        Invoke-Docker compose cp n8n/demo.json n8n:/tmp/tutoria-workflow.json
        Invoke-Docker compose exec -T -u 0 n8n chown node:node /tmp/tutoria-workflow.json
        Invoke-Docker compose exec -T n8n n8n import:workflow --input=/tmp/tutoria-workflow.json
    } finally {
        Invoke-Docker compose exec -T n8n rm -f /tmp/tutoria-credential.json /tmp/tutoria-workflow.json
    }
}
Write-Host 'Listo. Abre http://localhost:5678 para n8n y http://localhost:8000/docs para la API.'
Write-Host 'No se ha generado un lote. Ejecuta el flujo manual cuando quieras probar el modelo.'
