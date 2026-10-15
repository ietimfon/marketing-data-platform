
SELECT
    marketing_spend_key,
    spend,
    impressions,
    clicks,
    ctr,
    cpc,
    cpm

FROM {{ ref('fct_marketing_spend') }}

WHERE
    NOT (
        ctr <=> CASE
            WHEN impressions > 0 AND clicks IS NOT NULL
            THEN ROUND(
                CAST(clicks AS DOUBLE) / impressions * 100, 4
            )
            ELSE NULL
        END
    )

    OR NOT (
        cpc <=> CASE
            WHEN clicks > 0 AND spend IS NOT NULL
            THEN ROUND(
                CAST(spend AS DOUBLE) / clicks, 4
            )
            ELSE NULL
        END
    )

    OR NOT (
        cpm <=> CASE
            WHEN impressions > 0 AND spend IS NOT NULL
            THEN ROUND(
                CAST(spend AS DOUBLE) / impressions * 1000, 4
            )
            ELSE NULL
        END
    )
