WITH source_data AS (

    SELECT *
    FROM {{ source('facebook', 'facebook_accounts') }}

)

SELECT
    TRIM(CAST(account_id AS STRING)) AS account_id,
    TRIM(account_name) AS account_name,
    UPPER(TRIM(ad_currency_code)) AS currency_code,
    TRY_CAST(account_created_at AS TIMESTAMP) AS created_at,
    TRY_CAST(account_updated_at AS TIMESTAMP) AS updated_at

FROM source_data
