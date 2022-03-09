{%- macro snowflake__serialize_event_params(params) %}
    {%- if params is none %}
    PARSE_JSON(NULL)
    {%- else %}
    PARSE_JSON('{{tojson(params)}}')
    {%- endif %}
{%- endmacro %}

