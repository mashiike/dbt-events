{%- macro redshift__serialize_event_params(params) %}
    {%- if params is none %}
    json_parse(NULL)
    {%- else %}
    json_parse('{{tojson(params)}}')
    {%- endif %}
{%- endmacro %}

