CREATE TABLE employees AS SELECT * FROM employees;

INSERT INTO employees (
    employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id, department_id
) VALUES (
    999, 'Tetiana', 'Kostenko', 'tgurinenko18', '672205086', SYSDATE, 'IT_PROG', 50000, NULL, 100, 60
);

CREATE OR REPLACE VIEW dept_employee_count AS
SELECT department_id AS "Ід департаменту", COUNT(*) AS "Кількість співробітників"
FROM employees
GROUP BY department_id;

EXECUTE UTL_MAIL.SET_SERVER_PARAMETER('smtp_server', 'smtp.yourdomain.com');

DECLARE
    v_email      VARCHAR2(100);
    v_sender     VARCHAR2(100);
    v_message    VARCHAR2(32767);
BEGIN
    -- Отримуємо пошту
    SELECT LOWER(email) || '@gmail.com' INTO v_email
    FROM employees
    WHERE employee_id = 999;

    -- Формуємо HTML-таблицю
    v_message := '<h3>Кількість працівників по департаментах</h3>';
    v_message := v_message || '<table border="1"><tr><th>Ід департаменту</th><th>Кількість співробітників</th></tr>';

    FOR rec IN (
        SELECT department_id, COUNT(*) AS emp_count
        FROM employees
        GROUP BY department_id
    ) LOOP
        v_message := v_message || '<tr><td>' || rec.department_id || '</td><td>' || rec.emp_count || '</td></tr>';
    END LOOP;

    v_message := v_message || '</table>';

    -- Відправка листа
    UTL_MAIL.send(
        sender     => v_email,
        recipients => v_email,
        subject    => 'Звіт по департаментах',
        message    => v_message,
        mime_type  => 'text/html'
    );
    
    DBMS_OUTPUT.put_line('Лист відправлено на ' || v_email);
END;
/

Опис:
Зробити потрібний звіт і відправити його собі на пошту, знайшовши при цьому свою пошту в таблиці employees.
Деталі:
Зробити собі в схемі копію таблиці hr.employees та додати себе в цю таблицю, де в поле EMAIL треба додати свій реальний логін від своєї пошти. Далі зробити звіт про кількість працівників в
розрізі департаменту. Результат цього звіту відправити поштою у виді таблиці, де буде два стовпчика - "Ід департаменту" та "Кількість співробітників". Відправник повинен автоматично
вичитуватися з таблиці employees твоєї схеми де, по EMPLOYEE_ID треба знайти свій логін і далі при контактувати свій домен пошти (наприклад @GMAIL.COM)
Зберегти PL-SQL блок у файл під назвою H_05_03_tvoji_inichialy.sql. Загрузити в LMS Moodle.
