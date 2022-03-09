{% macro clear_dbt_events() %}
{% do adapter.drop_relation( dbt_events.get_event_relation() ) %}
{% endmacro %}
