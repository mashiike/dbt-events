{%- macro serialize_event_params(params) %}
    {{ return(adapter.dispatch('serialize_event_params', 'dbt_events') (params)) }}
{%- endmacro %}

{%- macro default__serialize_event_params(params) %}
    {%- if params is none %}
    {{ dbt_utils.safe_cast("NULL", dbt_utils.type_string()) }}
    {%- else %}
    {{ dbt_utils.safe_cast("'"~tojson(params)~"'", dbt_utils.type_string()) }}
    {%- endif %}
{%- endmacro %}
