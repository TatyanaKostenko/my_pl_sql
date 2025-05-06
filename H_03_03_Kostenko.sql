-- Створення пакета
CREATE OR REPLACE PACKAGE util IS
    FUNCTION get_job_title(p_employee_id IN tetyana_p15.employees.employee_id%TYPE) RETURN VARCHAR2;
    FUNCTION get_dep_name(p_employee_id IN tetyana_p15.employees.employee_id%TYPE) RETURN VARCHAR2;
    PROCEDURE del_jobs(p_job_id IN tetyana_p15.jobs.job_id%TYPE, po_result OUT VARCHAR2);
END util;
/

-- Тіло пакета
CREATE OR REPLACE PACKAGE BODY util IS

    FUNCTION get_job_title(p_employee_id IN tetyana_p15.employees.employee_id%TYPE)
    RETURN VARCHAR2
    IS
        v_job_id tetyana_p15.employees.job_id%TYPE;
        v_job_title tetyana_p15.jobs.job_title%TYPE;
    BEGIN
        SELECT job_id INTO v_job_id
        FROM tetyana_p15.employees
        WHERE employee_id = p_employee_id;

        SELECT job_title INTO v_job_title
        FROM tetyana_p15.jobs
        WHERE job_id = v_job_id;

        RETURN v_job_title;
    END get_job_title;

    FUNCTION get_dep_name(p_employee_id IN tetyana_p15.employees.employee_id%TYPE)
    RETURN VARCHAR2
    IS
        v_dep_id tetyana_p15.employees.department_id%TYPE;
        v_dep_name tetyana_p15.departments.department_name%TYPE;
    BEGIN
        SELECT department_id INTO v_dep_id
        FROM tetyana_p15.employees
        WHERE employee_id = p_employee_id;

        SELECT department_name INTO v_dep_name
        FROM tetyana_p15.departments
        WHERE department_id = v_dep_id;

        RETURN v_dep_name;
    END get_dep_name;

    PROCEDURE del_jobs(p_job_id IN tetyana_p15.jobs.job_id%TYPE, po_result OUT VARCHAR2)
    IS
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
    END del_jobs;

END util;
/

-- Видалення об'єктів з кореня схеми (окремі SQL-команди, без /)
DROP FUNCTION get_job_title;
DROP FUNCTION get_dep_name;
DROP PROCEDURE del_jobs;

-- Приклади виклику
-- 1. Отримання назви посади
DECLARE
    v_title VARCHAR2(100);
BEGIN
    v_title := util.get_job_title(100); -- заміни ID на існуючий
    DBMS_OUTPUT.PUT_LINE('Назва посади: ' || v_title);
END;
/

-- 2. Отримання назви департаменту
DECLARE
    v_dep_name VARCHAR2(100);
BEGIN
    v_dep_name := util.get_dep_name(100); -- заміни ID на існуючий
    DBMS_OUTPUT.PUT_LINE('Назва департаменту: ' || v_dep_name);
END;
/

-- 3. Видалення посади
DECLARE
    v_result VARCHAR2(200);
BEGIN
    util.del_jobs('IT_PROG', v_result); -- заміни на існуючий job_id
    DBMS_OUTPUT.PUT_LINE(v_result);
END;
/
