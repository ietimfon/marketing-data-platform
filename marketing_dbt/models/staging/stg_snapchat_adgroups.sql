WITH source_data AS (
    SELECT *
    FROM {{ source('snapchat', 'snapchat_adgroups') }}
)

SELECT
    CAST(_surrogate_key AS STRING) AS source_surrogate_key,
    TRIM(CAST(ad_group_id AS STRING)) AS ad_group_id,
    TRIM(CAST(campaign_id AS STRING)) AS campaign_id,
    TRIM(ad_group_name) AS ad_group_name,
    TRY_CAST(ad_group_updated_at AS TIMESTAMP) AS updated_at
FROM source_data