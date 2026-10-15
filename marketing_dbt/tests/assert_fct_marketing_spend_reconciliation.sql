
WITH source_totals AS (

    SELECT
        'facebook' AS platform,
        COUNT(*) AS row_count,
        SUM(TRY_CAST(ad_spend AS DECIMAL(20,6)))
            AS total_spend
    FROM {{ source('facebook', 'facebook_ads_stats') }}

    UNION ALL

    SELECT
        'snapchat' AS platform,
        COUNT(*) AS row_count,
        SUM(TRY_CAST(ad_spend AS DECIMAL(20,6)))
            AS total_spend
    FROM {{ source('snapchat', 'snapchat_ads_stats') }}

),

fact_totals AS (

    SELECT
        platform,
        COUNT(*) AS row_count,
        SUM(spend) AS total_spend
    FROM {{ ref('fct_marketing_spend') }}
    GROUP BY platform

),

comparison AS (

    SELECT
        s.platform,
        s.row_count AS source_rows,
        f.row_count AS fact_rows,
        s.total_spend AS source_spend,
        f.total_spend AS fact_spend
    FROM source_totals s
    LEFT JOIN fact_totals f
        ON s.platform = f.platform

)

SELECT *
FROM comparison

WHERE fact_rows IS NULL
   OR source_rows <> fact_rows
   OR source_spend IS NULL
   OR fact_spend IS NULL
   OR ABS(source_spend - fact_spend) > 0.000001

UNION ALL

SELECT
    f.platform,
    0 AS source_rows,
    f.row_count AS fact_rows,
    CAST(NULL AS DECIMAL(20,6)) AS source_spend,
    f.total_spend AS fact_spend
FROM fact_totals f
LEFT JOIN source_totals s
    ON f.platform = s.platform
WHERE s.platform IS NULL
