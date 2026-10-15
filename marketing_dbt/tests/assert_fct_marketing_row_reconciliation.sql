
WITH source_counts AS (

    SELECT
        'facebook' AS platform,
        COUNT(*) AS row_count
    FROM {{ source('facebook', 'facebook_ads_stats') }}

    UNION ALL

    SELECT
        'snapchat' AS platform,
        COUNT(*) AS row_count
    FROM {{ source('snapchat', 'snapchat_ads_stats') }}

),

fact_counts AS (

    SELECT
        platform,
        COUNT(*) AS row_count
    FROM {{ ref('fct_marketing_spend') }}
    GROUP BY platform

)

SELECT
    s.platform,
    s.row_count AS source_rows,
    COALESCE(f.row_count, 0) AS fact_rows

FROM source_counts s

LEFT JOIN fact_counts f
    ON s.platform = f.platform

WHERE s.row_count <> COALESCE(f.row_count, 0)
   OR f.platform IS NULL

UNION ALL

SELECT
    f.platform,
    0 AS source_rows,
    f.row_count AS fact_rows
FROM fact_counts f
LEFT JOIN source_counts s
    ON f.platform = s.platform
WHERE s.platform IS NULL
