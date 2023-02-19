CREATE OR REPLACE TABLE keepcoding.ivr_summary AS
WITH summary --base de clientes
  AS (SELECT  calls_ivr_id AS ivr_id, 
              calls_phone_number AS phone_number,
              calls_ivr_result AS ivr_result,
              keepcoding.vdn_aggregation(calls_vdn_label) AS vdn_aggregation,
              calls_start_date AS start_date,
              calls_start_date_id,
              calls_end_date AS end_date,
              calls_total_duration AS total_duration,
              calls_customer_segment AS customer_segment,
              calls_ivr_language AS ivr_language,
              calls_steps_module AS steps_module,
              calls_module_aggregation AS module_aggregation,
              document_type, 
              IF(document_type ='NULL', 0, 1) AS doc_type_lg,
              document_identification, 
              IF(document_identification ='NULL', 0, 1) AS doc_id_lg,
              customer_phone, 
              IF(customer_phone ='NULL', 0, 1) AS cust_phone_lg,
              billing_account_id, 
              IF(billing_account_id ='NULL', 0, 1) AS bill_lg,
              IF(calls_module_aggregation LIKE '%AVERIA_MASIVA%', 1, 0) AS masiva_lg,
              step_name, 
              step_description_error,
              IF(step_name = 'CUSTOMERINFOBYPHONE.TX' AND step_description_error = 'NULL', 1, 0) AS info_by_phone_lg,
              IF(step_name = 'CUSTOMERINFOBYDNI.TX' AND step_description_error = 'NULL', 1, 0) AS info_by_dni_lg,
              -- falta flag repeated_phone_24H
              -- falta flag cause_recall_phone_24H
      FROM keepcoding.ivr_detail summary 
   QUALIFY ROW_NUMBER() OVER(PARTITION BY SAFE_CAST(ivr_id AS STRING) ORDER BY doc_type_lg DESC, doc_id_lg DESC, cust_phone_lg DESC, bill_lg DESC) = 1
           ),
llamadas 
  AS (SELECT  phone_number,
              IF(COUNT(phone_number) > 1, 1, 0) AS repeated_phone_24H,
              COUNT(phone_number) AS rep_num,
      FROM summary
      WHERE summary.start_date >= DATE_SUB(summary.start_date , INTERVAL 1 DAY) 
      GROUP BY phone_number
      ORDER BY 1),
llamadas_posterior
  AS (SELECT  phone_number,
              IF(COUNT(phone_number) > 1, 1, 0) AS cause_recall_phone_24H,
      FROM summary
      WHERE summary.start_date <= DATE_ADD(summary.start_date , INTERVAL 1 DAY) 
      GROUP BY phone_number
      ORDER BY 1)

SELECT suma.ivr_id,
      suma.phone_number,
      suma.ivr_result,
      suma.vdn_aggregation,
      suma.start_date,
      suma.end_date,
      suma.total_duration,
      suma.customer_segment,
      suma.ivr_language,
      suma.steps_module,
      suma.module_aggregation,
      suma.document_type,
      suma.document_identification,
      suma.customer_phone, 
      suma.billing_account_id,
      suma.masiva_lg,
      suma.info_by_phone_lg,
      suma.info_by_dni_lg,
      ll.repeated_phone_24H,
      lp.cause_recall_phone_24H
  FROM summary suma
  LEFT
  JOIN llamadas ll
    ON suma.phone_number = ll.phone_number

  LEFT
  JOIN llamadas_posterior lp
    ON suma.phone_number = lp.phone_number

  