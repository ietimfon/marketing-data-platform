
WITH source_data AS (

    SELECT *
    FROM {{ ref('int_marketing_ads') }}

),

keyed AS (

    SELECT
        SHA2(
            TO_JSON(
                NAMED_STRUCT(
                    'platform', platform,
                    'account_id', account_id,
                    'ad_id', ad_id,
                    'date', CAST(date AS STRING),
                    'currency_code',
                        CASE WHEN platform = 'snapchat'
                            THEN currency_code ELSE NULL END,
                    'country_code',
                        CASE WHEN platform = 'snapchat'
                            THEN country_code ELSE NULL END,
                    'data_source',
                        CASE WHEN platform = 'snapchat'
                            THEN data_source ELSE NULL END
                ),
                MAP('ignoreNullFields', 'false')
            ),
            256
        ) AS marketing_spend_key,

        date,
        platform,
        account_id,
        account_name,
        campaign_id,
        campaign_name,
        ad_group_id,
        ad_group_name,
        ad_id,
        ad_name,
        ad_status,
        currency_code,
        country_code,
        data_source,
        spend,
        impressions,
        clicks

    FROM source_data

),

final AS (

    SELECT
        *,

        CASE
            WHEN impressions > 0 AND clicks IS NOT NULL
                THEN ROUND(
                    CAST(clicks AS DOUBLE)
                    / impressions * 100, 4
                )
            ELSE NULL
        END AS ctr,

        CASE
            WHEN clicks > 0 AND spend IS NOT NULL
                THEN ROUND(
                    CAST(spend AS DOUBLE) / clicks, 4
                )
            ELSE NULL
        END AS cpc,

        CASE
            WHEN impressions > 0 AND spend IS NOT NULL
                THEN ROUND(
                    CAST(spend AS DOUBLE)
                    / impressions * 1000, 4
                )
            ELSE NULL
        END AS cpm

    FROM keyed

)

SELECT *
FROM final
