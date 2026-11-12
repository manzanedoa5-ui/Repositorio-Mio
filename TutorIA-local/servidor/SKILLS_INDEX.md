# Skills de TutorIA

Asignación propuesta para cuando se integre el harness con los agentes.

| Skill | Rol que la consulta |
| --- | --- |
| [student-data-validation](skills/student-data-validation/SKILL.md) | Validación de datos |
| [risk-scoring](skills/risk-scoring/SKILL.md) | Evaluación del riesgo |
| [academic-insight](skills/academic-insight/SKILL.md) | Análisis académico |
| [normative-rules](skills/normative-rules/SKILL.md) | Revisión normativa |
| [safety-gate](skills/safety-gate/SKILL.md) | Revisión de seguridad |
| [evidence-report](skills/evidence-report/SKILL.md) | Preparación de evidencia |

Las skills viven en el proyecto Python. Para consultarlas manualmente, pide al asistente de programación que abra el archivo indicado y lo use en la tarea correspondiente. Para ejecutarlas como parte del flujo, el harness deberá cargar las instrucciones según la tarea y aplicar las reglas obligatorias en código. FastAPI y n8n aún no cargan estos archivos automáticamente.
