DO $$
DECLARE
    file_type_count int = 10;
    big_file_type int = 0;
    bit_file_type_name varchar;
    work_time TIMESTAMP;
    start_current_day TIMESTAMP;
    random_seconds int;
    current_file_type_name varchar;
    cpu_load_value float;
    count_big_in_time_frame int;
    count_not_big_in_time_frame int;
BEGIN
    RAISE NOTICE 'Очистка таблиц перед заполнением';
    TRUNCATE TABLE received_types RESTART IDENTITY RESTRICT;
    TRUNCATE TABLE cpu_load RESTART IDENTITY RESTRICT;
    
    RAISE NOTICE 'Начено создание % типов файлов. Из них большим будет тип %', file_type_count, big_file_type;
    
    RAISE NOTICE 'Начальное время генерации лог сообщений %', work_time;
    RAISE NOTICE 'Конечное время генерации лог сообщений %', start_current_day;

    FOR i IN 0..file_type_count - 1 LOOP
        current_file_type_name := 'type_' || i;
        RAISE NOTICE 'Начал работу с файловым типом %', current_file_type_name;
        random_seconds := floor(random() * 600)::int;
        work_time := date_trunc('day', now() - '1 day'::interval) + (random_seconds || ' seconds')::interval;
        start_current_day := date_trunc('day', now());
        WHILE work_time < start_current_day LOOP
            INSERT INTO received_types (file_type, received_at) values (current_file_type_name, work_time);

            random_seconds := floor(random() * 600)::int;
            work_time := work_time + (random_seconds || ' seconds')::interval;
        END LOOP;
    END LOOP;

    RAISE NOTICE '%', 'Начало заполнения таблицы загрузки процессора';
    bit_file_type_name := 'type_' || big_file_type;

    work_time := date_trunc('day', now() - '1 day'::interval) + '5 seconds'::interval;
    start_current_day := date_trunc('day', now());
    WHILE work_time < start_current_day LOOP
        SELECT coalesce(count(*), 0) 
        FROM received_types rt 
        WHERE rt.received_at >= work_time - '5 seconds'::interval AND rt.received_at < work_time AND file_type = bit_file_type_name 
        INTO count_big_in_time_frame;

        SELECT coalesce(count(*), 0) 
        FROM received_types rt 
        WHERE rt.received_at >= work_time - '5 seconds'::interval AND rt.received_at < work_time AND file_type != bit_file_type_name 
        INTO count_not_big_in_time_frame;

        IF (count_big_in_time_frame > 0) THEN
            cpu_load_value := random() * (99.99 - 70) + 70;
        ELSIF count_not_big_in_time_frame > 0 THEN
            cpu_load_value := random() * (30 - 10) + 10;
        ELSE
            cpu_load_value := random() * (5 - 1) + 1;
        END IF;
        INSERT INTO cpu_load(time_frame_start, time_frame_finish, "load") VALUES (work_time - '5 seconds'::interval, work_time, cpu_load_value);
        
        work_time := work_time + '5 seconds'::interval;
    END LOOP;
    RAISE NOTICE '%', 'База заполнена';
END $$;