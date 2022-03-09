# dbt-events
a dbt package for event logger

A [dbt package](https://docs.getdbt.com/docs/building-a-dbt-project/package-management) for event logging  
This DBT package provides functionality for storing event information in the DWH.
## Installation

Add to your packages.yml
```yaml
packages:
  - git: "https://github.com/mashiike/dbt-events"
    revision: v0.0.0
```

And write the following macro.

```
{%- macro event_record_sql(event_type, serialized_event_params) %}
    {{ dbt_events.event_record_sql(event_type,serialized_event_params) }}
{%- endmacro %}
```

This macro can be extended as follows to increase the common event information.

```
{%- macro event_record_sql(event_type, serialized_event_params) %}
    {{ dbt_events.event_record_sql(event_type,serialized_event_params) }}
    ,{{ dbt_utils.safe_cast("'"~env_var('GIT_HASH','')~"'",dbt_utils.type_string()) }} as git_hash
{%- endmacro %}
```

## QuickStart 

For simplicity, if you want to record event information at the beginning and end Hooks of the model, you can do so as follows.

simple_events.sql:
```sql
{{
    config(
        pre_hook={
        "sql": "{{ dbt_events.record('start_simple_events', { 'branch': env_var('GIT_BRANCH') } ) }}",
        "transaction": False
        },
        post_hook={
        "sql": "{{ dbt_events.record('end_simple_events') }}",
        "transaction": False
        },
    )
}}

select *
from {{ ref('data') }}
```

The location where event information is recorded and the behavior when columns are changed can be changed by writing the following in dbt_project.yml.

```yml
vars:
  dbt_events:
    database: hoge
    schema: public
    identifier: fuga
    on_schema_change: append_new_columns

```

## LICENSE

MIT 
