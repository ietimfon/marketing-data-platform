
WITH source_data AS (

    SELECT *
    FROM {{ ref('stg_snapchat_adgroups') }}

),

ranked AS (

    SELECT
        source_surrogate_key,
        ad_group_id,
        campaign_id,
        ad_group_name,
        updated_at,

        ROW_NUMBER() OVER (
            PARTITION BY ad_group_id
            ORDER BY
                updated_at DESC NULLS LAST,
                source_surrogate_key DESC
        ) AS row_num

    FROM source_data

)

SELECT
    ad_group_id,
    campaign_id,
    ad_group_name,
    updated_at

FROM ranked

WHERE row_num = 1
