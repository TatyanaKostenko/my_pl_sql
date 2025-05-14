CREATE OR REPLACE PACKAGE util IS
  PROCEDURE add_employee(
    p_first_name     IN VARCHAR2,
    p_last_name      IN VARCHAR2,
    p_email          IN VARCHAR2,
    p_phone_number   IN VARCHAR2,
    p_hire_date      IN DATE      DEFAULT TRUNC(SYSDATE, 'dd'),
    p_job_id         IN VARCHAR2,
    p_salary         IN NUMBER,
    p_commission_pct IN NUMBER    DEFAULT NULL,
    p_manager_id     IN NUMBER    DEFAULT 100,
    p_department_id  IN NUMBER
  );
END util;
/

CREATE OR REPLACE PACKAGE BODY util IS

  PROCEDURE add_employee(
    p_first_name     IN VARCHAR2,
    p_last_name      IN VARCHAR2,
    p_email          IN VARCHAR2,
    p_phone_number   IN VARCHAR2,
    p_hire_date      IN DATE      DEFAULT TRUNC(SYSDATE, 'dd'),
    p_job_id         IN VARCHAR2,
    p_salary         IN NUMBER,
    p_commission_pct IN NUMBER    DEFAULT NULL,
    p_manager_id     IN NUMBER    DEFAULT 100,
    p_department_id  IN NUMBER
  ) IS
    v_new_employee_id   employees.employee_id%TYPE;
    v_min_salary        jobs.min_salary%TYPE;
    v_max_salary        jobs.max_salary%TYPE;
    v_dummy             NUMBER;
  BEGIN
    log_util.log_start(p_proc_name => 'add_employee');

    -- Перевірка на робочий день і час
    IF TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN') IN ('SAT', 'SUN') OR
       TO_CHAR(SYSDATE, 'HH24MI') NOT BETWEEN '0800' AND '1800' THEN
      RAISE_APPLICATION_ERROR(-20001, 'Ви можете додавати нового співробітника лише в робочий час');
    END IF;

    -- Перевірка чи існує код посади
    SELECT COUNT(*) INTO v_dummy
    FROM jobs
    WHERE job_id = p_job_id;

    IF v_dummy = 0 THEN
      RAISE_APPLICATION_ERROR(-20001, 'Введено неіснуючий код посади');
    END IF;

    -- Перевірка чи існує відділ
    SELECT COUNT(*) INTO v_dummy
    FROM departments
    WHERE department_id = p_department_id;

    IF v_dummy = 0 THEN
      RAISE_APPLICATION_ERROR(-20001, 'Введено неіснуючий ідентифікатор відділу');
    END IF;

    -- Перевірка зарплати на відповідність діапазону
    SELECT min_salary, max_salary
    INTO v_min_salary, v_max_salary
    FROM jobs
    WHERE job_id = p_job_id;

    IF p_salary < v_min_salary OR p_salary > v_max_salary THEN
      RAISE_APPLICATION_ERROR(-20001, 'Введено неприпустиму заробітну плату для даного коду посади');
    END IF;

    -- Визначення нового employee_id (максимум + 1)
    SELECT NVL(MAX(employee_id), 0) + 1
    INTO v_new_employee_id
    FROM employees;

    -- Додавання нового співробітника в таблицю
    BEGIN
      INSERT INTO employees (
        employee_id,
        first_name,
        last_name,
        email,
        phone_number,
        hire_date,
        job_id,
        salary,
        commission_pct,
        manager_id,
        department_id
      ) VALUES (
        v_new_employee_id,
        p_first_name,
        p_last_name,
        p_email,
        p_phone_number,
        p_hire_date,
        p_job_id,
        p_salary,
        p_commission_pct,
        p_manager_id,
        p_department_id
      );

      DBMS_OUTPUT.PUT_LINE('Співробітник ' || p_first_name || ', ' || p_last_name || ', ' || p_job_id || ', ' || p_department_id || ' успішно додано до системи');

    EXCEPTION
      WHEN OTHERS THEN
        log_util.log_error('add_employee', SQLERRM);
        RAISE;
    END;

    log_util.log_finish('add_employee');

  END add_employee;

END util;
/








CREATE OR REPLACE PACKAGE BODY util IS

  -- Перевірка робочого часу
  PROCEDURE check_working_time IS
  BEGIN
    IF TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN') IN ('SAT', 'SUN') OR
       TO_CHAR(SYSDATE, 'HH24MI') NOT BETWEEN '0800' AND '1800' THEN
      RAISE_APPLICATION_ERROR(-20001, 'Ви можете видаляти співробітника лише в робочий час');
    END IF;
  END check_working_time;

  -- Процедура звільнення співробітника (оптимізована)
  PROCEDURE fire_an_employee(p_employee_id IN NUMBER) IS
    -- Змінні для співробітника
    v_employee_id     tetyana_p15.employees.employee_id%TYPE;
    v_first_name      tetyana_p15.employees.first_name%TYPE;
    v_last_name       tetyana_p15.employees.last_name%TYPE;
    v_email           tetyana_p15.employees.email%TYPE;
    v_phone_number    tetyana_p15.employees.phone_number%TYPE;
    v_hire_date       tetyana_p15.employees.hire_date%TYPE;
    v_job_id          tetyana_p15.employees.job_id%TYPE;
    v_salary          tetyana_p15.employees.salary%TYPE;
    v_commission_pct  tetyana_p15.employees.commission_pct%TYPE;
    v_manager_id      tetyana_p15.employees.manager_id%TYPE;
    v_department_id   tetyana_p15.employees.department_id%TYPE;
  BEGIN
    log_util.log_start('fire_an_employee');

    -- Перевірка робочого часу
    check_working_time;

    -- Отримати всі дані по співробітнику
    BEGIN
      SELECT employee_id, first_name, last_name, email, phone_number, hire_date,
             job_id, salary, commission_pct, manager_id, department_id
      INTO
           v_employee_id, v_first_name, v_last_name, v_email, v_phone_number,
           v_hire_date, v_job_id, v_salary, v_commission_pct, v_manager_id, v_department_id
      FROM tetyana_p15.employees
      WHERE employee_id = p_employee_id;
    EXCEPTION
    WHEN OTHERS THEN -- Перевірка існування співробітника
    raise_application_error(-20001, 'Переданий співробітник не існує. Detail: '||SQLERRM);
      END;

    -- Вставка в історичну таблицю (через dual)
    INSERT INTO tetyana_p15.employees_history (
      employee_id, first_name, last_name, email, phone_number, hire_date,
      job_id, salary, commission_pct, manager_id, department_id, fired_at
    )
    SELECT
      v_employee_id, v_first_name, v_last_name, v_email, v_phone_number,
      v_hire_date, v_job_id, v_salary, v_commission_pct, v_manager_id, v_department_id, SYSDATE
    FROM dual;

    -- Видалення співробітника
    BEGIN
      DELETE FROM tetyana_p15.employees
      WHERE employee_id = v_employee_id;

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


   
