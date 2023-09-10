CREATE OR REPLACE TABLE keepcoding.ivr_summary AS
WITH Temp AS (
  SELECT
    calls_ivr_id AS ivr_id,
    calls_phone_number AS phone_number,
    calls_ivr_result AS ivr_result,
    CASE
      WHEN calls_vdn_label LIKE 'ATC%' THEN 'FRONT'
      WHEN calls_vdn_label LIKE 'TECH%' THEN 'TECH'
      WHEN calls_vdn_label = 'ABSORPTION' THEN 'ABSORPTION'
      ELSE 'RESTO'
    END AS vdn_aggregation,
    calls_start_date AS start_date,
    calls_end_date AS end_date,
    calls_total_duration AS total_duration,
    calls_customer_segment AS customer_segment,
    calls_ivr_language AS ivr_language,
    calls_steps_module AS steps_module,
    calls_module_aggregation AS module_aggregation,
    document_type,
    document_identification,
    customer_phone,
    billing_account_id,
    CAST(calls_steps_module AS STRING) AS str_steps_module,
    calls_start_date AS start_date_repeated,
    -- Acceder al valor de una columna de la fila anterior dentro del conjunto de resultados ordenado
    LAG(calls_start_date) OVER (PARTITION BY calls_phone_number ORDER BY calls_start_date) AS lag_start_date,
    -- Acceder al valor de una columna de la fila siguiente dentro del conjunto de resultados ordenado
    LEAD(calls_start_date) OVER (PARTITION BY calls_phone_number ORDER BY calls_start_date) AS lead_start_date,
    step_description_error
  FROM `entrega-378209.keepcoding.ivr_detail`
)
SELECT
  ivr_id,
  phone_number,
  ivr_result,
  vdn_aggregation,
  start_date,
  end_date,
  total_duration,
  customer_segment,
  ivr_language,
  steps_module,
  module_aggregation,
  COALESCE(document_type, 'DESCONOCIDO') AS document_type,
  COALESCE(document_identification, 'DESCONOCIDO') AS document_identification,  
  IFNULL(MAX(NULLIF(customer_phone, 'NULL')), 'DESCONOCIDO') AS customer_phone,
  COALESCE(MAX(NULLIF(billing_account_id, 'NULL')), 'DESCONOCIDO') AS billing_account_id,
  MAX(CASE WHEN str_steps_module LIKE '%AVERIA_MASIVA%' THEN 1 ELSE 0 END) AS masiva_lg,
  MAX(CASE WHEN str_steps_module LIKE '%CUSTOMERINFOBYPHONE.TX%' AND step_description_error IS NULL THEN 1 ELSE 0 END) AS info_by_phone_lg,
  MAX(CASE WHEN str_steps_module LIKE '%CUSTOMERINFOBYDNI.TX%' AND step_description_error IS NULL THEN 1 ELSE 0 END) AS info_by_dni_lg,
  MAX(CASE WHEN TIMESTAMP_DIFF(start_date, lag_start_date, HOUR) < 24 THEN 1 ELSE 0 END) AS repeated_phone_24H,
  MAX(CASE WHEN TIMESTAMP_DIFF(lead_start_date, end_date, HOUR) < 24 THEN 1 ELSE 0 END) AS cause_recall_phone_24H
FROM Temp
GROUP BY
  ivr_id,
  phone_number,
  ivr_result,
  vdn_aggregation,
  start_date,
  end_date,
  total_duration,
  customer_segment,
  ivr_language,
  steps_module,
  module_aggregation,
  document_type,
  document_identification;
