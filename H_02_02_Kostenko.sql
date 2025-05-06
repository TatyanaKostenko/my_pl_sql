SET SERVEROUTPUT ON;
DECLARE
    v_def_percent VARCHAR2(30);
    v_percent VARCHAR2(5);
BEGIN
    FOR emp IN (
        SELECT first_name || ' ' || last_name AS emp_name, commission_pct * 100 AS percent_of_salary, manager_id
        FROM hr.employees
        WHERE department_id = 80
        ORDER BY first_name ) LOOP
        -- Перевіряємо, якщо manager_id = 100
        IF emp.manager_id = 100 THEN
            DBMS_OUTPUT.PUT_LINE('Співробітник - ' || emp.emp_name || ', процент до зарплати на зараз заборонений');
            CONTINUE;  -- Пропускаємо поточну ітерацію
        END IF;
        -- Розгалуження по проценту до зарплати
        IF emp.percent_of_salary BETWEEN 10 AND 20 THEN
            v_def_percent := 'мінімальний';
        ELSIF emp.percent_of_salary BETWEEN 25 AND 30 THEN
            v_def_percent := 'середній';
        ELSIF emp.percent_of_salary BETWEEN 35 AND 40 THEN
            v_def_percent := 'максимальний';
        END IF;
        -- Формуємо значення для v_percent
        v_percent := CONCAT(emp.percent_of_salary, '%');
        -- Виводимо результат
        DBMS_OUTPUT.PUT_LINE('Співробітник - ' || emp.emp_name || '; процент до зарплати - ' || v_percent || '; опис процента - ' || v_def_percent);
    END LOOP;
END;
/
