# SQL_Adv

- CREAR TABLA DE ivr_detail ->  ivr_detail.sql
- CREAR TABLA DE ivr_summary -> ivr_summary.sql funcion extra vdn_aggregation.sql
Modificacion:
Este código realiza una serie de transformaciones y cálculos en los datos de llamadas telefónicas en una tabla llamada `ivr_detail` y luego crea una nueva tabla llamada `ivr_summary`. 

1. Extrae datos relevantes de la tabla `ivr_detail`, como números de teléfono, fechas, duración de llamadas, etc.
2. Asigna una categoría (`vdn_aggregation`) según ciertos patrones en la etiqueta de la llamada.
3. Rellena valores nulos en las columnas de documentos con 'DESCONOCIDO'.
4. Realiza cálculos para determinar si un número repite llamadas en las 24 horas siguientes (`repeated_phone_24H`) o si causa una llamada en las 24 horas posteriores (`cause_recall_phone_24H`).Esto ayuda a identificar patrones de llamadas repetidas en un corto período de tiempo.
5. Agrupa los resultados por varios atributos y crea la tabla `ivr_summary` con los resultados de los cálculos y transformaciones anteriores.
- CREAR FUNCIÓN DE LIMPIEZA DE ENTEROS -> EJERCICIO3.SQL
