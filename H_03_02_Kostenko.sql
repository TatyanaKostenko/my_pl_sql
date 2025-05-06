CREATE OR REPLACE FUNCTION get_dep_name(p_employee_id IN hr.employees.employee_id%TYPE)
RETURN VARCHAR2
IS
    v_dep_id hr.employees.department_id%TYPE;
    v_dep_name tetyana_p15.departments.department_name%TYPE;
BEGIN
    SELECT department_id
    INTO v_dep_id
    FROM hr.employees
    WHERE employee_id = p_employee_id;

    SELECT department_name
    INTO v_dep_name
    FROM tetyana_p15.departments
    WHERE department_id = v_dep_id;

    RETURN v_dep_name;
END;
/
SELECT 
    employee_id,
    first_name,
    last_name,
    get_job_title(employee_id) AS job_title,
    get_dep_name(employee_id) AS department_name
FROM hr.employees;

