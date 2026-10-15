
{% macro verify_bronze_access() %}

    {% set sql %}
        SELECT COUNT(*) AS total_rows
        FROM {{ source('facebook', 'facebook_accounts') }}
    {% endset %}

    {% set result = run_query(sql) %}

    {% if execute and result is not none %}
        {% do log(result.print_table(), info=True) %}
    {% endif %}

{% endmacro %}
