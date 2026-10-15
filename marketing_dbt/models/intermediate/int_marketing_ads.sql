
WITH facebook AS (

    SELECT
        platform,
        date,
        account_id,
        account_name,
        currency_code,
        campaign_id,
        campaign_name,
        ad_group_id,
        ad_group_name,
        ad_id,
        ad_name,
        ad_status,
        CAST(NULL AS STRING) AS country_code,
        CAST(NULL AS STRING) AS data_source,
        spend,
        impressions,
        clicks
    FROM {{ ref('int_facebook_ads') }}

),

snapchat AS (

    SELECT
        platform,
        date,
        account_id,
        account_name,
        currency_code,
        campaign_id,
        campaign_name,
        ad_group_id,
        ad_group_name,
        ad_id,
        ad_name,
        ad_status,
        country_code,
        data_source,
        spend,
        impressions,
        clicks
    FROM {{ ref('int_snapchat_ads') }}

)

SELECT * FROM facebook

UNION ALL

SELECT * FROM snapchat
