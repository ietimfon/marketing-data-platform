
{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='marketing_spend_key',
        on_schema_change='fail',
        tags=['incremental_demo']
    )
}}

WITH source_data AS (

    SELECT *
    FROM {{ ref('fct_marketing_spend') }}

    {% if is_incremental() %}
        WHERE date >= (
            SELECT DATE_SUB(
                COALESCE(MAX(date), DATE('1900-01-01')),
                {{ var('incremental_lookback_days', 7) }}
            )
            FROM {{ this }}
        )
    {% endif %}

)

SELECT *
FROM source_data
