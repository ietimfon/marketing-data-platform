
{% docs __overview__ %}

# Marketing Data Platform

## Business purpose

This project centralizes Facebook Ads and Snapchat Ads
performance data in Databricks using dbt.

It enables analysts to measure advertising spend,
impressions, clicks, CTR, CPC, CPM, and campaign
performance.

## Data architecture

### Bronze: Raw sources

Nine Delta tables containing Facebook and Snapchat
advertising data.

### Silver: Staging and intermediate models

- Standardize source column names and data types.
- Preserve missing performance values.
- Resolve Snapchat ad-group history duplicates.
- Enrich statistics with campaign metadata.
- Combine both platforms into a common model.

### Gold: Analytics

`fct_marketing_spend` provides a unified, ad-level
advertising performance fact table.

## Business metric definitions

- CTR (%) = clicks / impressions * 100
- CPC = spend / clicks
- CPM = spend / impressions * 1000

Undefined ratios return NULL.

## Important data limitations

- Facebook performance covers 2025.
- Snapchat performance covers 2024.
- Spend includes different source currencies.
- Missing clicks and impressions are preserved as NULL.
- Campaign and ad-group names reflect available metadata,
  not necessarily historical names as of the reporting date.

## Data quality

The project uses dbt tests to validate identifiers,
accepted values, metric calculations, non-negative
metrics, and reconciliation with raw source data.

## Consumers

- Marketing analysts
- Databricks SQL users
- BI applications
- Downstream analytics and AI applications

{% enddocs %}
