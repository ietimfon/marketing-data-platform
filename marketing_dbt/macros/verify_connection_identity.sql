
{% macro verify_connection_identity() %}

    {% set sql %}
        SELECT
            current_user() AS active_identity,
            current_catalog() AS active_catalog,
            current_schema() AS active_schema
    {% endset %}

    {% set result = run_query(sql) %}

    {% if execute and result is not none %}
        {% do result.print_table() %}
    {% endif %}

{% endmacro %}
