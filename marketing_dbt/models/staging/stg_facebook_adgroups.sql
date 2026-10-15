
WITH source_data AS (

    SELECT *
    FROM {{ source('facebook', 'facebook_adgroups') }}

)

SELECT
    TRIM(CAST(ad_group_id AS STRING)) AS ad_group_id,
    TRIM(ad_group_name) AS ad_group_name,
    TRY_CAST(ad_group_updated_at AS TIMESTAMP) AS updated_at

FROM source_data
