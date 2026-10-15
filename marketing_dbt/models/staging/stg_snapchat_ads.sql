WITH source_data AS (
    SELECT *
    FROM {{ source('snapchat', 'snapchat_ads') }}
)

SELECT
    TRIM(CAST(ad_id AS STRING)) AS ad_id,
    TRIM(CAST(ad_group_id AS STRING)) AS ad_group_id,
    TRIM(ad_name) AS ad_name,
    TRY_CAST(ad_detail_updated_at AS TIMESTAMP) AS updated_at
FROM source_data