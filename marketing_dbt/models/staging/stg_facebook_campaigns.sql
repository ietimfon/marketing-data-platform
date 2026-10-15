WITH source_data AS (

    SELECT *
    FROM {{ source('facebook', 'facebook_campaigns') }}

)

SELECT
    TRIM(CAST(campaign_id AS STRING)) AS campaign_id,
    TRIM(campaign_name) AS campaign_name,
    TRY_CAST(campaign_updated_at AS TIMESTAMP) AS updated_at

FROM source_data
