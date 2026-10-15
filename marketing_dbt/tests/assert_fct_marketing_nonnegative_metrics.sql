
SELECT *
FROM {{ ref('fct_marketing_spend') }}
WHERE
    spend < 0
    OR impressions < 0
    OR clicks < 0
    OR ctr < 0
    OR cpc < 0
    OR cpm < 0
