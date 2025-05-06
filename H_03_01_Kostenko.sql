CREATE OR REPLACE PROCEDURE del_jobs (
    p_job_id IN tetyana_p15.jobs.job_id%TYPE,
    po_result OUT VARCHAR2
) IS
    v_exists NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_exists
    FROM tetyana_p15.jobs
    WHERE job_id = p_job_id;

    IF v_exists = 0 THEN  
        po_result := 'Посада ' || p_job_id || ' не існує';
        RETURN;
    END IF;
    DELETE FROM tetyana_p15.jobs
    WHERE job_id = p_job_id;
    po_result := 'Посада ' || p_job_id || ' успішно видалена';
END;
/

DECLARE
    v_result VARCHAR2(100);
BEGIN
    del_jobs('SA_REP', v_result);
    DBMS_OUTPUT.PUT_LINE(v_result);
END;
/

