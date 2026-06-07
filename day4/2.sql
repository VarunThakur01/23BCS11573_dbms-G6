WITH cleaned_tasks AS (
    SELECT DISTINCT start_time, end_time
    FROM task_schedule
    WHERE start_time IS NOT NULL AND end_time IS NOT NULL
),
event_list AS (
    SELECT start_time AS time, 1 AS type FROM cleaned_tasks
    UNION ALL
    SELECT end_time AS time, -1 AS type FROM cleaned_tasks
),
running_sum AS (
    SELECT 
        time, 
        SUM(type) OVER (ORDER BY time, type) AS active_tasks
    FROM event_list
)
SELECT MAX(active_tasks) AS min_cpus
FROM running_sum;
 