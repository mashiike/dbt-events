{{
    config(
        pre_hook={
        "sql": "{{ dbt_events.record('start_dbt_event_view') }}",
        "transaction": False
        },
        post_hook={
        "sql": "{{ dbt_events.record('end_dbt_event_view') }}",
        "transaction": False
        },
    )
}}

select *
from {{ dbt_events.get_event_relation() }}
