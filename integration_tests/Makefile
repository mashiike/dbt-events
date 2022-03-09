export GIT_HASH := $(shell git log -1 --format=%H)

test-redshift:
	dbt deps
	dbt run-operation --target redshift clear_dbt_events
	dbt run --target redshift --full-refresh
	dbt test --target redshift

clean:
	dbt clean
