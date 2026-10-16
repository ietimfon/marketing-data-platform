
{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set pr_number = env_var('DBT_CI_PR_NUMBER', '') -%}

    {%- if target.name == 'ci' and pr_number | length > 0 -%}
        {%- if not modules.re.match('^[0-9]+$', pr_number) -%}
            {{ exceptions.raise_compiler_error('DBT_CI_PR_NUMBER must contain only digits') }}
        {%- endif -%}

        {%- if custom_schema_name is none -%}
            {{ 'pr_' ~ pr_number ~ '_' ~ target.schema }}
        {%- else -%}
            {{ 'pr_' ~ pr_number ~ '_' ~ (custom_schema_name | trim) }}
        {%- endif -%}

    {%- elif custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}

{%- endmacro %}


