CREATE OR REPLACE PACKAGE BODY util IS

  --  Перевірка робочого часу
  PROCEDURE check_working_time IS
  BEGIN
    IF TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN') IN ('SAT', 'SUN') OR
       TO_CHAR(SYSDATE, 'HH24MI') NOT BETWEEN '0800' AND '1800' THEN
      RAISE_APPLICATION_ERROR(-20001, 'Ви можете видаляти співробітника лише в робочий час');
    END IF;
  END check_working_time;

  --  Процедура звільнення співробітника
  PROCEDURE fire_an_employee(p_employee_id IN NUMBER) IS
    v_exists         NUMBER;
    v_first_name     tetyana_p15.employees.first_name%TYPE;
    v_last_name      tetyana_p15.employees.last_name%TYPE;
    v_job_id         tetyana_p15.employees.job_id%TYPE;
    v_department_id  tetyana_p15.employees.department_id%TYPE;
  BEGIN
    log_util.log_start('fire_an_employee');

    -- Перевірка робочого часу
    check_working_time;

    -- Перевірка існування співробітника
    SELECT COUNT(*) INTO v_exists
    FROM tetyana_p15.employees
    WHERE employee_id = p_employee_id;

    IF v_exists = 0 THEN
      RAISE_APPLICATION_ERROR(-20001, 'Переданий співробітник не існує');
    END IF;

    -- Збереження інформації перед видаленням
    INSERT INTO tetyana_p15.employees_history (
      employee_id, first_name, last_name, email,
      phone_number, hire_date, job_id, salary,
      commission_pct, manager_id, department_id, fired_at
    )
    SELECT
      employee_id, first_name, last_name, email,
      phone_number, hire_date, job_id, salary,
      commission_pct, manager_id, department_id, SYSDATE
    FROM tetyana_p15.employees
    WHERE employee_id = p_employee_id;

    -- Отримати дані для повідомлення
    SELECT first_name, last_name, job_id, department_id
    INTO v_first_name, v_last_name, v_job_id, v_department_id
    FROM tetyana_p15.employees
    WHERE employee_id = p_employee_id;

    -- Видалення співробітника
    BEGIN
      DELETE FROM tetyana_p15.employees
      WHERE employee_id = p_employee_id;

      DBMS_OUTPUT.PUT_LINE(
        'Співробітник ' || v_first_name || ', ' || v_last_name || ', ' || v_job_id || ', ' || v_department_id || ' успішно звільнений.'
      );
    EXCEPTION
      WHEN OTHERS THEN
        log_util.log_error('fire_an_employee', SQLERRM);
        RAISE;
    END;

    log_util.log_finish('fire_an_employee');

  END fire_an_employee;

END util;
/
