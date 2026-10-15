WITH stats AS (

    SELECT *
    FROM {{ ref('stg_facebook_ads_stats') }}

),

ads AS (

    SELECT *
    FROM {{ ref('stg_facebook_ads') }}

),

campaigns AS (

    SELECT *
    FROM {{ ref('stg_facebook_campaigns') }}

),

adgroups AS (

    SELECT *
    FROM {{ ref('stg_facebook_adgroups') }}

),

accounts AS (

    SELECT *
    FROM {{ ref('stg_facebook_accounts') }}

),

enriched AS (

    SELECT
        s.platform,
        s.date,

        s.account_id,
        ac.account_name,
        ac.currency_code,

        a.campaign_id,
        c.campaign_name,

        a.ad_group_id,
        g.ad_group_name,

        s.ad_id,
        a.ad_name,
        a.ad_status,

        s.spend,
        s.impressions,
        s.clicks

    FROM stats s

    LEFT JOIN ads a
        ON s.ad_id = a.ad_id
        AND s.account_id = a.account_id

    LEFT JOIN campaigns c
        ON a.campaign_id = c.campaign_id

    LEFT JOIN adgroups g
        ON a.ad_group_id = g.ad_group_id

    LEFT JOIN accounts ac
        ON s.account_id = ac.account_id

)

SELECT *
FROM enriched
