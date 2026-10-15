WITH source_data AS (
    SELECT *
    FROM {{ source('snapchat', 'snapchat_ads_stats') }}
)

SELECT
    TRIM(CAST(ad_detail_id AS STRING)) AS ad_id,
    UPPER(TRIM(ad_currency_code)) AS currency_code,
    UPPER(TRIM(ad_country)) AS country_code,

    TRY_CAST(
        NULLIF(LOWER(TRIM(ad_spend)), 'null')
        AS DECIMAL(20,6)
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
    TRIM(data_src) AS data_source,
    'snapchat' AS platform

FROM source_data