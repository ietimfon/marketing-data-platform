WITH source_data AS (

    SELECT *
    FROM {{ source('facebook', 'facebook_ads') }}

)

SELECT
    TRIM(CAST(ad_id AS STRING)) AS ad_id,
    TRIM(CAST(campaign_id AS STRING)) AS campaign_id,
    TRIM(CAST(ad_group_id AS STRING)) AS ad_group_id,
    TRIM(CAST(account_id AS STRING)) AS account_id,
    TRIM(ad_name) AS ad_name,
    UPPER(TRIM(ad_status)) AS ad_status,
    TRY_CAST(ad_updated_at AS TIMESTAMP) AS updated_at

FROM source_data
