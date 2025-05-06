-- ��������� ������
CREATE OR REPLACE PACKAGE util IS
    FUNCTION get_job_title(p_employee_id IN tetyana_p15.employees.employee_id%TYPE) RETURN VARCHAR2;
    FUNCTION get_dep_name(p_employee_id IN tetyana_p15.employees.employee_id%TYPE) RETURN VARCHAR2;
    PROCEDURE del_jobs(p_job_id IN tetyana_p15.jobs.job_id%TYPE, po_result OUT VARCHAR2);
END util;
/

-- ҳ�� ������
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
            po_result := '������ ' || p_job_id || ' �� ����';
            RETURN;
        END IF;

        DELETE FROM tetyana_p15.jobs
        WHERE job_id = p_job_id;

        po_result := '������ ' || p_job_id || ' ������ ��������';
    END del_jobs;

END util;
/

-- ��������� ��'���� � ������ ����� (����� SQL-�������, ��� /)
DROP FUNCTION get_job_title;
DROP FUNCTION get_dep_name;
DROP PROCEDURE del_jobs;

-- �������� �������
-- 1. ��������� ����� ������
DECLARE
    v_title VARCHAR2(100);
BEGIN
    v_title := util.get_job_title(100); -- ����� ID �� ��������
    DBMS_OUTPUT.PUT_LINE('����� ������: ' || v_title);
END;
/

-- 2. ��������� ����� ������������
DECLARE
    v_dep_name VARCHAR2(100);
BEGIN
    v_dep_name := util.get_dep_name(100); -- ����� ID �� ��������
    DBMS_OUTPUT.PUT_LINE('����� ������������: ' || v_dep_name);
END;
/

-- 3. ��������� ������
DECLARE
    v_result VARCHAR2(200);
BEGIN
    util.del_jobs('IT_PROG', v_result); -- ����� �� �������� job_id
    DBMS_OUTPUT.PUT_LINE(v_result);
END;
/
