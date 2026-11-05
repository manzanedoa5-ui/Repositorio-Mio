# Ejecutar en Windows

Requisitos: Docker Desktop funcionando con contenedores Linux y PowerShell. No necesitas instalar Python ni n8n por separado.

Descarga el ZIP del repositorio o clonalo. Extrae el ZIP y abre PowerShell en la carpeta que contiene `compose.yaml`. Ejecuta:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\start.ps1
```

El permiso de ejecucion se aplica solo a ese proceso. El script crea `.env` con tres tokens aleatorios si no existe, construye la API, inicia n8n, verifica ambos servicios e importa el flujo y la credencial de operador solo si el flujo no existe. No imprime tokens ni genera lotes automaticamente. Conserva `.env` en privado: no lo compartas ni lo subas a Git.

Abre **http://localhost:5678** en el navegador de tu PC. Crea tu cuenta local de n8n en el primer acceso; es independiente de Docker. Abre el flujo **TutorIA — generacion sintetica pendiente de aprobacion** y pulsa **Execute workflow**. El nodo HTTP debe devolver `cases: 200`, `train_rows: 400` y `test_rows: 200`. Cada ejecucion crea un lote nuevo; no lo reintentes automaticamente.

Si prefieres la terminal:

```powershell
docker compose exec -T n8n n8n execute --id=tutoriaSyntheticDemo
```

La API se consulta en **http://localhost:8000/docs**. Usa Authorize con el token correspondiente de tu archivo local `.env`: operador para generar, revisor para consultar `/review` y aprobar, movil para `/cases`. n8n solo tiene la credencial de operador. Los casos no aparecen para el movil hasta que una persona los aprueba. No compartas capturas que incluyan tokens.

## Detener y volver a iniciar

```powershell
docker compose stop
docker compose start
```

Los volumenes conservan la base SQLite y la configuracion de n8n. No uses `docker compose down -v` salvo que quieras borrar esos datos. Conserva tambien `.env`; cambiar sus tokens exige actualizar la credencial en n8n y recrear la API.

## Comprobar y diagnosticar

```powershell
docker compose ps
docker compose logs --tail 50 api n8n
Invoke-RestMethod http://localhost:8000/health
```

Para ejecutar las cinco pruebas dentro de la imagen sin instalar Python:

```powershell
docker compose cp tests api:/tmp/tutoria-tests
docker compose exec -T -u 0 api chown -R 10001:10001 /tmp/tutoria-tests
docker compose exec -T api python -m unittest discover -s /tmp/tutoria-tests -v
```

## Entorno cloud con proxy

El build local usa los certificados normales de la imagen. En Codex, agrega el override que monta el certificado del proxy sin incorporarlo a la imagen:

```sh
docker compose -f compose.yaml -f compose.cloud.yaml build api
```

Si los tokens estan en otro archivo, agrega `--env-file /ruta/al/archivo` despues de `compose`. Nunca desactives la verificacion TLS.

El flujo Docker/n8n y las cinco pruebas fueron comprobados en Linux cloud. El usuario confirmó una ejecución correcta del flujo en Docker Desktop en Windows; ver [el resultado y la explicación del modelo](../docs/modelo-y-demo.md). La demo usa datos sinteticos; el modelo se entrena en memoria en cada ejecucion. Android sigue pendiente de validacion.
