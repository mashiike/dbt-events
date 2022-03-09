{%- macro event_variables(variable_name) %}
    {{ return(adapter.dispatch('event_variables', 'dbt_events') (variable_name)) }}
{%- endmacro %}


{%- macro default__event_variables(variable_name) -%}
    {%- set config = var('dbt_events','') %}
    {%- if config == '' %}
        {{ return(none) }}
    {%- endif %}
    {%- set val = config[variable_name] %}
    {%- if val is not defined %}
        {{ return(none) }}
    {%- endif %}
    {{ return(val) }}
{%- endmacro %}

{%- macro event_database_name() %}
    {{ return(adapter.dispatch('event_database_name', 'dbt_events') ()) }}
{%- endmacro %}

{%- macro default__event_database_name(variable_name) -%}
    {%- set custom_database_name = dbt_events.event_variables('database') %}
    {%- set database_name = generate_database_name(custom_database_name) %}
    {{ return(database_name) }}
{%- endmacro %}

{%- macro event_schema_name() %}
    {{ return(adapter.dispatch('event_schema_name', 'dbt_events') ()) }}
{%- endmacro %}

{%- macro default__event_schema_name() -%}
    {%- set custom_schema_name = dbt_events.event_variables('schema') %}
    {%- set schema_name = generate_schema_name(custom_schema_name) %}
    {{ return(schema_name) }}
{%- endmacro %}

{%- macro event_identifier() %}
    {{ return(adapter.dispatch('event_identifier', 'dbt_events') ()) }}
{%- endmacro %}

{%- macro default__event_identifier() -%}
    {%- set custom_identifier = dbt_events.event_variables('identifier') %}
    {%- if custom_identifier is none or custom_identifier == '' %}
        {%- set custom_identifier = 'dbt_events' %}
    {%- endif %}
    {%- set identifier = generate_alias_name(custom_identifier) %}
    {{ return(identifier) }}
{%- endmacro %}

{%- macro get_event_relation() %}
    {{ return(adapter.dispatch('get_event_relation', 'dbt_events') ()) }}
{%- endmacro %}

{%- macro default__get_event_relation() -%}
    {% set target_relation = api.Relation.create(
                database=dbt_events.event_database_name(),
                schema=dbt_events.event_schema_name(),
                identifier=dbt_events.event_identifier(),
                type='table') %}
    {{ return(target_relation) }}
{%- endmacro %}

{%- macro event_on_schema_change() %}
    {{ return(adapter.dispatch('event_on_schema_change', 'dbt_events') ()) }}
{%- endmacro %}

{%- macro default__event_on_schema_change() -%}
    {%- set on_schema_change = dbt_events.event_variables('on_schema_change') %}
    {%- if on_schema_change is none or on_schema_change == '' %}
        {%- set on_schema_change = 'ignore' %}
    {%- endif %}
    {{ return(on_schema_change) }}
{%- endmacro %}
