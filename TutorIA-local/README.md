# TutorIA local

Esta versión contiene la app Android, el modelo de deserción entrenable con datos sintéticos, la API local, los flujos de n8n y las seis skills.

- Abre android/ en Android Studio. La app accede a FastAPI desde el emulador mediante 10.0.2.2:8000.
- Sigue servidor/README.md para generar los datos y entrenar el modelo antes de iniciar la API. En Docker Desktop, usa el flujo servidor/n8n/tutoria_revision.json.
- Las skills se pueden consultar desde servidor/SKILLS_INDEX.md.
