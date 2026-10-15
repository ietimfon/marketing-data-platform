
WITH source_data AS (

    SELECT *
    FROM {{ source('facebook', 'facebook_ads_stats') }}

),

cleaned AS (

    SELECT
        CAST(ad_id AS STRING) AS ad_id,
        CAST(account_id AS STRING) AS account_id,

        TRY_CAST(
            NULLIF(LOWER(TRIM(ad_spend)), 'null')
            AS DECIMAL(20, 6)
        ) AS spend,

        TRY_CAST(
            NULLIF(LOWER(TRIM(ad_impressions)), 'null')
            AS BIGINT
        ) AS impressions,

        TRY_CAST(
            NULLIF(LOWER(TRIM(ad_clicks)), 'null')
            AS BIGINT
        ) AS clicks,

        TRY_CAST(ad_date AS DATE) AS date,

        'facebook' AS platform

    FROM source_data

)

SELECT *
FROM cleaned
