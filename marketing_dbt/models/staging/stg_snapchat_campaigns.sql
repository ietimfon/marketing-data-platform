WITH source_data AS (
    SELECT *
    FROM {{ source('snapchat', 'snapchat_campaigns') }}
)

SELECT
    TRIM(CAST(campaign_id AS STRING)) AS campaign_id,
    TRIM(CAST(account_id AS STRING)) AS account_id,
    TRIM(campaign_name) AS campaign_name
FROM source_data