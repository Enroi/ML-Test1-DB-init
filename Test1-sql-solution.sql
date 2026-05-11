SELECT
    rt.file_type, avg(cl."load")
FROM
    cpu_load cl
JOIN received_types rt ON
    rt.received_at >= cl.time_frame_start
    AND rt.received_at < cl.time_frame_finish
GROUP BY 1
ORDER BY 1;