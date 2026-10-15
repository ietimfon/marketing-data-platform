
WITH stats AS (

    SELECT *
    FROM {{ ref('stg_snapchat_ads_stats') }}

),

ads AS (

    SELECT *
    FROM {{ ref('stg_snapchat_ads') }}

),

adgroups AS (

    SELECT *
    FROM {{ ref('int_snapchat_adgroups_deduped') }}

),

campaigns AS (

    SELECT *
    FROM {{ ref('stg_snapchat_campaigns') }}

)

SELECT
    s.platform,
    s.date,

    c.account_id,
    CAST(NULL AS STRING) AS account_name,
    s.currency_code,

    g.campaign_id,
    c.campaign_name,

    a.ad_group_id,
    g.ad_group_name,

    s.ad_id,
    a.ad_name,
    CAST(NULL AS STRING) AS ad_status,

    s.country_code,
    s.data_source,

    s.spend,
    s.impressions,
    s.clicks

FROM stats s

LEFT JOIN ads a
    ON s.ad_id = a.ad_id

LEFT JOIN adgroups g
    ON a.ad_group_id = g.ad_group_id

LEFT JOIN campaigns c
    ON g.campaign_id = c.campaign_id
