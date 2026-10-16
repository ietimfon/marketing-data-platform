
{% macro verify_production_gold() %}

    {% if target.name != 'prod' %}
        {{ exceptions.raise_compiler_error(
            'verify_production_gold must run against the prod target'
        ) }}
    {% endif %}

    {% set query %}
        SELECT
            COUNT(*) AS total_rows,
            COUNT(DISTINCT marketing_spend_key) AS distinct_keys,
            COUNT_IF(marketing_spend_key IS NULL) AS null_keys
        FROM {{ ref('fct_marketing_spend') }}
    {% endset %}

    {% if execute %}

        {% set result = run_query(query) %}

        {% if result is none or result.rows | length == 0 %}
            {{ exceptions.raise_compiler_error(
                'Production Gold verification query returned no rows'
            ) }}
        {% endif %}

        {% set rows = result.rows[0] %}

        {% set total_rows = rows[0] | int %}
        {% set distinct_keys = rows[1] | int %}
        {% set null_keys = rows[2] | int %}

        {% do log('Production Gold rows: ' ~ total_rows, info=True) %}
        {% do log('Distinct keys: ' ~ distinct_keys, info=True) %}
        {% do log('Null keys: ' ~ null_keys, info=True) %}

        {% if total_rows != 95109 %}
            {{ exceptions.raise_compiler_error(
                'Unexpected production Gold row count: ' ~ total_rows
            ) }}
        {% endif %}

        {% if distinct_keys != total_rows or null_keys != 0 %}
            {{ exceptions.raise_compiler_error(
                'Production Gold key integrity validation failed'
            ) }}
        {% endif %}

        {% do log('Production Gold validation passed', info=True) %}

    {% endif %}

{% endmacro %}
