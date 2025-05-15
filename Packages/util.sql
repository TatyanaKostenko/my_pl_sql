CREATE OR REPLACE PACKAGE util IS
  -- Процедура для додавання нового співробітника
  PROCEDURE add_employee(
    p_first_name     IN VARCHAR2,
    p_last_name      IN VARCHAR2,
    p_email          IN VARCHAR2,
    p_phone_number   IN VARCHAR2,
    p_hire_date      IN DATE DEFAULT TRUNC(SYSDATE, 'dd'),
    p_job_id         IN VARCHAR2,
    p_salary         IN NUMBER,
    p_commission_pct IN NUMBER DEFAULT NULL,
    p_manager_id     IN NUMBER DEFAULT 100,
    p_department_id  IN NUMBER
  );

  -- Процедура для звільнення співробітника
  PROCEDURE fire_an_employee(p_employee_id IN NUMBER);

  -- Процедура для зміни атрибутів співробітника
  PROCEDURE change_attribute_employee(
    p_employee_id     IN NUMBER,
    p_first_name      IN VARCHAR2 DEFAULT NULL,
    p_last_name       IN VARCHAR2 DEFAULT NULL,
    p_email           IN VARCHAR2 DEFAULT NULL,
    p_phone_number    IN VARCHAR2 DEFAULT NULL,
    p_job_id          IN VARCHAR2 DEFAULT NULL,
    p_salary          IN NUMBER DEFAULT NULL,
    p_commission_pct  IN NUMBER DEFAULT NULL,
    p_manager_id      IN NUMBER DEFAULT NULL,
    p_department_id   IN NUMBER DEFAULT NULL
  );
PROCEDURE api_nbu_sync;

END util;




CREATE OR REPLACE PACKAGE BODY util IS

  PROCEDURE add_employee(
    p_first_name     IN VARCHAR2,
    p_last_name      IN VARCHAR2,
    p_email          IN VARCHAR2,
    p_phone_number   IN VARCHAR2,
    p_hire_date      IN DATE DEFAULT TRUNC(SYSDATE, 'dd'),
    p_job_id         IN VARCHAR2,
    p_salary         IN NUMBER,
    p_commission_pct IN NUMBER DEFAULT NULL,
    p_manager_id     IN NUMBER DEFAULT 100,
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

  PROCEDURE check_working_time IS
  BEGIN
    IF TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN') IN ('SAT', 'SUN') OR
       TO_CHAR(SYSDATE, 'HH24MI') NOT BETWEEN '0800' AND '1800' THEN
      RAISE_APPLICATION_ERROR(-20001, 'Зміни дозволені лише в робочий час');
    END IF;
  END check_working_time;

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

  PROCEDURE change_attribute_employee(
    p_employee_id     IN NUMBER,
    p_first_name      IN VARCHAR2 DEFAULT NULL,
    p_last_name       IN VARCHAR2 DEFAULT NULL,
    p_email           IN VARCHAR2 DEFAULT NULL,
    p_phone_number    IN VARCHAR2 DEFAULT NULL,
    p_job_id          IN VARCHAR2 DEFAULT NULL,
    p_salary          IN NUMBER DEFAULT NULL,
    p_commission_pct  IN NUMBER DEFAULT NULL,
    p_manager_id      IN NUMBER DEFAULT NULL,
    p_department_id   IN NUMBER DEFAULT NULL
  ) IS
    v_any_change BOOLEAN := FALSE;
  BEGIN
    log_util.log_start('change_attribute_employee');

    -- Перевірка, що хоча б одне поле задане
    IF p_first_name IS NULL AND
       p_last_name IS NULL AND
       p_email IS NULL AND
       p_phone_number IS NULL AND
       p_job_id IS NULL AND
       p_salary IS NULL AND
       p_commission_pct IS NULL AND
       p_manager_id IS NULL AND
       p_department_id IS NULL THEN
      DBMS_OUTPUT.PUT_LINE('Жодне поле не передано для оновлення.');
      log_util.log_finish('change_attribute_employee');
      RETURN;
    END IF;

    -- Оновлення кожного атрибута, якщо передано
    BEGIN
      IF p_first_name IS NOT NULL THEN
        UPDATE tetyana_p15.employees SET first_name = p_first_name WHERE employee_id = p_employee_id;
        v_any_change := TRUE;
      END IF;

      IF p_last_name IS NOT NULL THEN
        UPDATE tetyana_p15.employees SET last_name = p_last_name WHERE employee_id = p_employee_id;
        v_any_change := TRUE;
      END IF;

      IF p_email IS NOT NULL THEN
        UPDATE tetyana_p15.employees SET email = p_email WHERE employee_id = p_employee_id;
        v_any_change := TRUE;
      END IF;

      IF p_phone_number IS NOT NULL THEN
        UPDATE tetyana_p15.employees SET phone_number = p_phone_number WHERE employee_id = p_employee_id;
        v_any_change := TRUE;
      END IF;

      IF p_job_id IS NOT NULL THEN
        UPDATE tetyana_p15.employees SET job_id = p_job_id WHERE employee_id = p_employee_id;
        v_any_change := TRUE;
      END IF;

      IF p_salary IS NOT NULL THEN
        UPDATE tetyana_p15.employees SET salary = p_salary WHERE employee_id = p_employee_id;
        v_any_change := TRUE;
      END IF;

      IF p_commission_pct IS NOT NULL THEN
        UPDATE tetyana_p15.employees SET commission_pct = p_commission_pct WHERE employee_id = p_employee_id;
        v_any_change := TRUE;
      END IF;

      IF p_manager_id IS NOT NULL THEN
        UPDATE tetyana_p15.employees SET manager_id = p_manager_id WHERE employee_id = p_employee_id;
        v_any_change := TRUE;
      END IF;

      IF p_department_id IS NOT NULL THEN
        UPDATE tetyana_p15.employees SET department_id = p_department_id WHERE employee_id = p_employee_id;
        v_any_change := TRUE;
      END IF;

      IF v_any_change THEN
        DBMS_OUTPUT.PUT_LINE('У співробітника ' || p_employee_id || ' успішно оновлені атрибути.');
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        log_util.log_error('change_attribute_employee', SQLERRM);
        RAISE;
    END;

    log_util.log_finish('change_attribute_employee');
  END change_attribute_employee;




  PROCEDURE api_nbu_sync IS
    v_list_currencies VARCHAR2(2000);
    v_curr VARCHAR2(3);
    v_exchange_rate NUMBER;
    v_rate_date DATE;
BEGIN
    -- Отримуємо список валют з таблиці sys_params
    BEGIN
        SELECT value_text INTO v_list_currencies
        FROM tetyana_p15.sys_params
        WHERE param_name = 'list_currencies';
    EXCEPTION
        WHEN OTHERS THEN
            log_util.log_error('api_nbu_sync', 'Помилка при отриманні списку валют: ' || SQLERRM);
            RAISE_APPLICATION_ERROR(-20001, 'Помилка при отриманні списку валют');
    END;

    -- Прокручуємо список валют і виконуємо операції синхронізації
    FOR cc IN (SELECT value_list AS curr FROM TABLE(util.table_from_list(p_list_val => v_list_currencies))) LOOP
        BEGIN
            -- Отримуємо курс для валюти з API
            SELECT * INTO v_exchange_rate, v_rate_date
            FROM TABLE(util.get_currency(p_currency => cc.curr));

            -- Вставка нових даних в таблицю cur_exchange
            INSERT INTO tetyana_p15.cur_exchange (currency_code, exchange_rate, rate_date)
            VALUES (cc.curr, v_exchange_rate, v_rate_date);

            -- Логування успіху
            log_util.log_finish('api_nbu_sync', 'Для валюти ' || cc.curr || ' курс оновлений успішно');

        EXCEPTION
            WHEN OTHERS THEN
                -- Логування помилки
                log_util.log_error('api_nbu_sync', 'Помилка при синхронізації валюти ' || cc.curr || ': ' || SQLERRM);
                CONTINUE;
        END;
    END LOOP;

    -- Завершення процедури
    log_util.log_finish('api_nbu_sync', 'Процедура синхронізації завершена успішно');
END api_nbu_sync;



END util; 
