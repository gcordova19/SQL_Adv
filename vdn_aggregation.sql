-- Funcion  vdn_label
-- empieza por ATC pondremos FRONT, si empieza por TECH pondremos TECH si es
-- ABSORPTION dejaremos ABSORPTION y si no es ninguna de las anteriores
-- pondremos RESTO.
CREATE OR REPLACE FUNCTION keepcoding.vdn_aggregation(p_string STRING) RETURNS STRING AS (
(SELECT CASE WHEN p_string LIKE "ATC%" THEN 'FRONT'
             WHEN p_string LIKE 'TECH' THEN 'TECH'
             WHEN p_string LIKE 'ABSORPTION' THEN 'ABSORPTION'
             ELSE 'RESTO'
        END )
);