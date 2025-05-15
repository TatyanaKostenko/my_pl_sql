BEGIN
    DBMS_SCHEDULER.create_job (
        job_name        => 'API_NBU_SYNC_JOB',  
        job_type        => 'PLSQL_BLOCK', 
        job_action      => 'BEGIN tetyana_p15.api_nbu_sync; END;',
        start_date      => TO_TIMESTAMP('2025-05-15 06:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        repeat_interval => 'FREQ=DAILY; BYHOUR=6; BYMINUTE=0; BYSECOND=0', 
        enabled         => TRUE  -- Активувати завдання
    );
END;
/
