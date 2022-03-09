{%- macro initialize() %}
    {{ return(adapter.dispatch('initialize', 'dbt_events') ()) }}
{%- endmacro %}

{%- macro default__initialize() -%}
    {%- set event_relation = adapter.get_relation(
                database=dbt_events.event_database_name(),
                schema=dbt_events.event_schema_name(),
                identifier=dbt_events.event_identifier() ) %}
    {%- if event_relation is none %}
        {%- set target_relation = dbt_events.get_event_relation() %}
        {% do adapter.create_schema(api.Relation.create(database=target_relation.database, schema=target_relation.schema)) %}
        {%- do run_query( get_create_table_as_sql(False, target_relation, dbt_events.get_event_record_sql('initialize', none))) -%}
        {{ return(target_relation) }}
    {%- endif %}
    {{ return(event_relation) }}
{%- endmacro %}

{%- macro record(event_type, params=none, execute_only=True) %}
    {{ return(adapter.dispatch('record', 'dbt_events') (event_type, params, execute_only)) }}
{%- endmacro %}

{%- macro default__record(event_type, params, execute_only) -%}
    {%- if execute or not execute_only %}
        {%- set event_relation = dbt_events.initialize() %}
        {%- set tmp_relation = make_temp_relation(event_relation) %}
        {%- do run_query( get_create_table_as_sql(True, tmp_relation, dbt_events.get_event_record_sql(event_type, params))) -%}
        {%- do adapter.expand_target_column_types(
                from_relation=tmp_relation,
                to_relation=event_relation) %}
        {%- set on_schema_change = incremental_validate_on_schema_change(dbt_events.event_on_schema_change()) %}
        {%- set dest_columns = process_schema_changes(on_schema_change, tmp_relation, event_relation) %}
        {%- if not dest_columns %}
            {% set dest_columns = adapter.get_columns_in_relation(event_relation) %}
        {%- endif %}
        {%- set record_insert_sql %}
            BEGIN;
            {{ get_delete_insert_merge_sql(event_relation, tmp_relation, none, dest_columns) }};
            COMMIT;
        {%- endset %}
        {%- do run_query(record_insert_sql) %}
    {%- endif %}
{%- endmacro %}

{%- macro get_event_record_sql(event_type, params) -%}
    {{ return(adapter.dispatch('get_event_record_sql', 'dbt_events') (event_type, params)) }}
{%- endmacro %}

{%- macro default__get_event_record_sql(event_type, params) -%}
    {%- set serialized_event_params = dbt_events.serialize_event_params(params) %}
    {{ return(event_record_sql(event_type, serialized_event_params)) }}
{%- endmacro %}

{%- macro event_record_sql(event_type, serialized_event_params) %}
    {{ return(adapter.dispatch('event_record_sql', 'dbt_events') (event_type,serialized_event_params)) }}
{%- endmacro %}

{%- macro default__event_record_sql(event_type, serialized_event_params) %}
    select
        {{ dbt_utils.current_timestamp_in_utc() }} as event_timestamp,
        {{ dbt_utils.safe_cast("'"~invocation_id~"'",dbt_utils.type_string()) }} as dbt_invocation_id,
        {{ dbt_utils.safe_cast("'"~run_started_at~"'",dbt_utils.type_timestamp()) }} as dbt_run_started_at,
        {{ dbt_utils.safe_cast("'"~event_type~"'",dbt_utils.type_string()) }} as event_type,
        {{ serialized_event_params }} as event_params,
        {%- set model_unique_id = model['unique_id'] %}
        {%- if model_unique_id is defined and model_unique_id is not none and model_unique_id != '' %}
            {{ dbt_utils.safe_cast("'"~model_unique_id~"'", dbt_utils.type_string()) }} as model_unique_id
        {%- else %}
            {{ dbt_utils.safe_cast("NULL", dbt_utils.type_string()) }} as model_unique_id
        {%- endif %},
        {{ dbt_utils.safe_cast("'"~dbt_version~"'",dbt_utils.type_string()) }} as dbt_version
{%- endmacro %}
