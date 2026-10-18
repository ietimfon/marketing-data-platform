# Marketing Data Platform with Databricks and dbt

An end-to-end marketing analytics data platform built using **Databricks, Unity Catalog, Delta Lake, dbt, Elementary, and GitHub Actions**.

The platform transforms Facebook Ads and Snapchat Ads datasets into a unified marketing spend fact table, with automated data-quality checks and continuous integration and deployment.

## 1. Project Overview

This project implements a Medallion Architecture for marketing analytics.

The pipeline:

1. Ingests source CSV files into Databricks Delta tables.
2. Standardizes source data using dbt staging models.
3. Integrates Facebook and Snapchat advertising datasets.
4. Produces an analytics-ready Gold fact table.
5. Validates data quality through automated dbt tests.
6. Supports incremental processing using Delta MERGE.
7. Automates pull-request validation and production deployment using GitHub Actions.

**Validated dataset:** 95,109 marketing spend records, with 95,109 distinct non-null surrogate keys.

## 2. Technology Stack

| Technology | Purpose |
|---|---|
| Databricks | Data processing and SQL execution |
| Unity Catalog | Data governance and environment isolation |
| Delta Lake | Reliable transactional storage |
| dbt Core | SQL transformations, testing, and documentation |
| Elementary | Data observability |
| GitHub Actions | CI/CD automation |
| GitHub | Source control and pull-request workflow |
| Python | dbt execution environment |

Validated local versions include dbt Core 1.12.5 and dbt-databricks 1.12.6.

## 3. Data Architecture

The solution follows a Bronze–Silver–Gold architecture.

```text
Facebook Ads CSVs          Snapchat Ads CSVs
        |                         |
        +------------+------------+
                     |
                     v
          BRONZE — Delta Tables
            marketing_dev.bronze
                 9 tables
                     |
                     v
             SILVER — dbt Views
              9 staging models
              4 intermediate models
                     |
                     v
             GOLD — dbt Models
            fct_marketing_spend
        fct_marketing_spend_incremental
                     |
                     v
            Analytics-ready data
                     |
          +----------+-----------+
          |                      |
       dbt Tests              Elementary
          |
      GitHub Actions CI/CD
```

### Bronze Layer

The Bronze layer stores the ingested source datasets as Delta tables in `marketing_dev.bronze`.

The source datasets cover Facebook Ads and Snapchat Ads.

### Silver Layer

The Silver layer uses dbt views for source standardization and intermediate transformations.

Staging models standardize fields and source structures. Intermediate models integrate related advertising entities and produce a unified dataset.

Key models include:

- `int_facebook_ads`
- `int_snapchat_adgroups_deduped`
- `int_snapchat_ads`
- `int_marketing_ads`

### Gold Layer

The Gold layer contains two models:

**`fct_marketing_spend`**

The main analytics-ready fact table, materialized as a Databricks table.

**`fct_marketing_spend_incremental`**

An incremental-materialization demonstration using Databricks Delta MERGE and the existing Gold fact table as its upstream source.

## 4. Environment Separation

Unity Catalog provides separate environments for development, continuous integration, and production.

| Environment | Catalog | Purpose |
|---|---|---|
| Development | `marketing_dev` | Source data and development transformations |
| CI | `marketing_ci` | Automated validation |
| Production | `marketing_prod` | Production analytical models |

The CI workflow uses pull-request-specific schemas, such as:

```text
marketing_ci.pr_<PR_NUMBER>_silver
marketing_ci.pr_<PR_NUMBER>_gold
marketing_ci.pr_<PR_NUMBER>_elementary
```

This reduces interference between concurrent pull-request validations.

All environments access the governed Bronze source tables in `marketing_dev.bronze`.

## 5. Marketing Metrics

The Gold fact table exposes the following metrics.

| Metric | Definition |
|---|---|
| Spend | Advertising expenditure |
| Impressions | Number of ad impressions |
| Clicks | Number of ad clicks |
| CTR | `(clicks / impressions) * 100` |
| CPC | `spend / clicks` |
| CPM | `(spend / impressions) * 1000` |

Calculated ratios return NULL where the denominator is zero or the necessary input is missing.

CTR is expressed as a percentage. CPC and CPM are expressed in the currency of the underlying advertising record.

**Important:** Advertising currencies should not be aggregated indiscriminately across different currency codes without conversion into a reporting currency.

## 6. Surrogate Key Strategy

The main Gold fact table uses a deterministic SHA-256 surrogate key named `marketing_spend_key`.

The key is constructed from identifying fields, including:

- Advertising platform
- Account identifier
- Ad identifier
- Reporting date
- Additional Snapchat-specific source dimensions

This key supports data-integrity checks and Delta MERGE matching.

Validation confirmed:

| Check | Result |
|---|---:|
| Total records | 95,109 |
| Distinct surrogate keys | 95,109 |
| Null surrogate keys | 0 |

## 7. Data Quality and Observability

The dbt project contains **21 data tests**.

The test suite includes key-integrity checks and business-oriented data validation.

The incremental fact model has dedicated tests verifying that `marketing_spend_key` is:

- Unique
- Not null

Elementary is integrated for dbt observability and execution monitoring.

### Running Tests

From the dbt project directory:

```bash
dbt test --target dev
```

To test the incremental model:

```bash
dbt test --select fct_marketing_spend_incremental --target ci
```

A configured Databricks connection and appropriate Unity Catalog permissions are required.

## 8. Incremental Materialization

The project includes `fct_marketing_spend_incremental` as a demonstration of incremental Delta processing.

Configuration:

```sql
{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='marketing_spend_key',
        on_schema_change='fail'
    )
}}
```

### Processing Strategy

- First execution: load the full upstream Gold fact table.
- Subsequent executions: select records inside a configurable lookback window.
- Match records using `marketing_spend_key`.
- Use Delta MERGE to insert new records or update matching records.

The default lookback is seven days.

### Validation Evidence

The incremental model was validated through:

1. Initial load of 95,109 records.
2. Repeated successful dbt executions.
3. Databricks Delta history showing MERGE operations.
4. Unique and non-null surrogate key tests.
5. Reconciliation against the original Gold fact table.

Observed reconciliation differences:

| Metric | Difference |
|---|---:|
| Record count | 0 |
| Spend | 0 |
| Impressions | 0 |
| Clicks | 0 |

### Incremental Processing Limitations

This is an incremental-materialization demonstration rather than a complete change-data-capture implementation.

Its lookback is calculated from the maximum date across the incremental target. Consequently, it can miss late-arriving corrections outside the lookback period, particularly where advertising platforms have different maximum reporting dates.

The source is the existing Gold fact table; therefore, the upstream Gold table is still rebuilt using its configured table materialization.

A production-ready enhancement would use ingestion or modification timestamps, a source-aware watermark, or another reliable change-detection mechanism.

## 9. Continuous Integration and Deployment

GitHub Actions provides automated CI/CD.

### Pull-Request CI

Workflow: `.github/workflows/dbt-ci.yml`

On pull requests targeting `main`, the workflow:

1. Installs Python and dbt dependencies.
2. Authenticates to Databricks using a CI Service Principal.
3. Verifies the connection.
4. Validates pull-request schema routing.
5. Initializes Elementary.
6. Builds and tests the dbt models.
7. Uploads execution artifacts.

The repository has a branch-protection ruleset configured to require the `Build and Test dbt` status check before merging.

### Production Deployment

Workflow: `.github/workflows/dbt-production.yml`

Production deployment supports:

- Manual execution through `workflow_dispatch`.
- Automatic execution when changes are pushed or merged into `main`.

The workflow authenticates using a separate production Service Principal, builds and tests production models, validates Gold data, and uploads execution artifacts.

Both manually initiated and automatically triggered production deployment runs have completed successfully.

### Authentication

CI and production authenticate to Databricks using OAuth machine-to-machine credentials stored in GitHub Secrets.

Credentials and local dbt profiles are excluded from source control.

## 10. Project Structure

```text
marketing-data-platform/
|
+-- .github/
|   +-- workflows/
|       +-- ci-connection-test.yml
|       +-- dbt-ci.yml
|       +-- dbt-production.yml
|
+-- marketing_dbt/
|   +-- models/
|   |   +-- staging/
|   |   +-- intermediate/
|   |   +-- marts/
|   |
|   +-- macros/
|   +-- tests/
|   +-- dbt_project.yml
|   +-- packages.yml
|
+-- .gitignore
+-- README.md
```

## 11. Running the Project Locally

### Prerequisites

- Python and a dedicated virtual environment
- dbt Core with the Databricks adapter
- Access to a Databricks SQL Warehouse
- Appropriate Unity Catalog permissions
- A locally configured dbt profile

### Setup

Clone the repository:

```bash
git clone https://github.com/ietimfon/marketing-data-platform.git
cd marketing-data-platform/marketing_dbt
```

Install dependencies using the project's Python environment, then install dbt packages:

```bash
dbt deps
```

Verify the Databricks connection:

```bash
dbt debug --target dev
```

Build the development models:

```bash
dbt build --target dev
```

Generate dbt documentation:

```bash
dbt docs generate --target dev
dbt docs serve
```

The appropriate environment credentials and configured `profiles.yml` must be supplied separately. Do not commit credentials or access tokens.

## 12. Key Engineering Outcomes

The implementation demonstrates:

- Bronze–Silver–Gold modeling with Databricks and dbt.
- Governed Delta tables using Unity Catalog.
- Cross-platform Facebook and Snapchat advertising transformations.
- A unified, validated marketing analytics fact table.
- Automated dbt testing and Elementary integration.
- Incremental materialization using Delta MERGE.
- Pull-request schema isolation.
- OAuth-based Service Principal authentication.
- Automated GitHub Actions CI and production deployment.

## 13. Future Improvements

Potential enhancements include:

- Source-level incremental ingestion using modification timestamps.
- Automated schema cleanup after pull-request closure.
- Currency normalization for cross-market reporting.
- Expanded monitoring and alerting.
- Automated source freshness checks.
- Data lineage and operational dashboards.

---

**Project:** Marketing Data Platform with Databricks and dbt

**Repository:** https://github.com/ietimfon/marketing-data-platform