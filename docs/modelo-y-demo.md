# Qué es el modelo y cómo ver su resultado

TutorIA es un prototipo local que utiliza datos sintéticos. n8n coordina la ejecución; el modelo está implementado en Python en `app/pipeline.py` y la API que lo ejecuta está en `app/api.py`.

## Recorrido de una ejecución

1. En n8n, abrir el flujo **TutorIA — generación sintética pendiente de aprobación**.
2. Pulsar **Execute workflow** una sola vez. El estado Inactive es normal para un flujo manual.
3. n8n envía una petición autenticada a `POST http://api:8000/demo/run` dentro de la red de Docker.
4. Python genera 600 registros ficticios con asistencia, promedio y créditos aprobados; valida y limpia los datos.
5. Un pipeline imputa valores ausentes, estandariza las variables y entrena una regresión logística con 400 registros de periodos anteriores. La imputación y el escalado se ajustan solo con los datos de entrenamiento.
6. Evalúa los 200 registros del último periodo y calcula probabilidades de riesgo. Guarda los casos pendientes en SQLite y un informe de calidad.
7. Abrir el nodo **Generar casos pendientes** y consultar Output para ver el resumen.

La tabla de n8n muestra el resultado de la ejecución, no una representación visual del modelo. Cada ejecución vuelve a entrenar el modelo en memoria y crea un lote nuevo; no hay un archivo de modelo persistente ni un registro de modelos.

## Resultado comprobado en Windows

El 5 de noviembre de 2026, el usuario ejecutó el flujo en Docker Desktop en su PC Windows y compartió una captura de la respuesta exitosa del nodo HTTP:

| Campo de la API | Resultado observado |
| --- | --- |
| batch | 1 |
| cases | 200 |
| metrics.train_rows | 400 |
| metrics.test_rows | 200 |
| metrics.test_periodo | 20241 |
| metrics.average_precision | 0.4422213245495807 |
| metrics.brier | 0.1626127186344105 |
| metrics.precision_05 | 0.45161290322580644 |
| metrics.recall_05 | 0.3111111111111111 |

El rastro mostró las operaciones `clean`, `train` y `write_report`. Esto demuestra la conexión n8n → API → entrenamiento y generación de casos en esa ejecución local. Es evidencia aportada por el usuario, no una ejecución remota del agente en su PC. Las cinco pruebas automatizadas se verificaron por separado dentro de Docker en el entorno cloud.

El traductor del navegador puede cambiar los nombres de los campos; los identificadores anteriores son los originales de la API. Las métricas describen esta demo sintética y no prueban eficacia con alumnos reales.

## Qué hacer después

Los casos quedan pendientes de revisión humana. En la API, `/review` permite consultarlos con la credencial de revisor y `/review/{id}` registrar una decisión. El cliente móvil solo puede consultar casos aprobados. Ejecutar el flujo no aprueba casos automáticamente.

Para trabajar con datos reales todavía hace falta acordar la definición y el horizonte del resultado a predecir, preparar los datos con autorización, validar temporalmente el modelo y evaluar su rendimiento y calibración. La demo no está integrada al SUM ni incluye una interfaz completa para cargar y explorar datos reales.

## Acceso desde la PC

Seguir [las instrucciones para Windows](../scripts/README.md). Docker Desktop debe estar funcionando y los servicios iniciados. Abrir n8n en http://localhost:5678 y la documentación de la API en http://localhost:8000/docs desde la misma PC. Estos accesos locales no conectan a los servicios de un entorno cloud.

Los tokens, cuentas de n8n, bases de datos y volúmenes locales no se suben a Git. Conservar `.env` en privado y los volúmenes de Docker para mantener el acceso y los datos de esa instalación.
