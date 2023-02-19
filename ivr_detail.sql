CREATE OR REPLACE TABLE keepcoding.ivr_detail AS
WITH detalle --base de clientes
  AS (SELECT  ivr_id AS calls_ivr_id, 
              phone_number AS calls_phone_number,
              ivr_result AS calls_ivr_result,
              vdn_label AS calls_vdn_label,
              start_date AS calls_start_date,
              FORMAT_DATE("%Y%m%d",start_date ) AS calls_start_date_id,
              end_date AS calls_end_date,
              FORMAT_DATE("%Y%m%d",end_date ) AS calls_end_date_id,
              total_duration AS calls_total_duration,
              customer_segment AS calls_customer_segment,
              ivr_language AS calls_ivr_language,
              steps_module AS calls_steps_module,
              module_aggregation AS calls_module_aggregation,
      FROM keepcoding.ivr_calls detalle ),
mod_comp --merge modules y steps
  AS ( SELECT  modul.ivr_id,
        modul.module_sequece,
        modul.module_name,
        modul.module_duration,
        modul.module_result,
        step.step_sequence,
        step.step_name,
        step.step_result,
        step.step_description_error,
        step.document_type,
        step.document_identification,
        step.customer_phone,
        step.billing_account_id,
  FROM keepcoding.ivr_modules modul
  LEFT  
  JOIN keepcoding.ivr_steps step
    ON step.ivr_id = modul.ivr_id  AND  step.module_sequece = modul.module_sequece)


SELECT  calls_ivr_id,
        calls_phone_number,
        calls_ivr_result,
        calls_vdn_label,
        calls_start_date,
        calls_start_date_id,
        calls_end_date,
        calls_end_date_id,
        calls_total_duration,
        calls_customer_segment,
        calls_ivr_language,
        calls_steps_module,
        calls_module_aggregation,
        module_sequece,
        module_name,
        module_duration,
        module_result,
        step_sequence,
        step_name,
        step_result,
        step_description_error,
        document_type,
        document_identification,
        customer_phone,
        billing_account_id,
  FROM detalle 
  LEFT 
  JOIN mod_comp
    ON detalle.calls_ivr_id = mod_comp.ivr_id




