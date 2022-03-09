{%- macro event_record_sql(event_type, serialized_event_params) %}
    {{ dbt_events.event_record_sql(event_type,serialized_event_params) }}
    ,{{ dbt_utils.safe_cast("'"~env_var('GIT_HASH','')~"'",dbt_utils.type_string()) }} as git_hash
{%- endmacro %}
