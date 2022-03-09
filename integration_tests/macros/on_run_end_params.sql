{% macro on_run_end_params(results) %}

    {% if execute %}
    {% set params = {} %}
    {% for res in results -%}
        {% set _ = params.update({ res.node.unique_id : res.status }) %}
    {% endfor %}
    {{ return(params) }}
    {% endif %}

{% endmacro %}
