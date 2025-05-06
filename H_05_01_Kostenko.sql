CREATE TABLE employees AS
SELECT * FROM hr.employees;

CREATE OR REPLACE TRIGGER hire_date_update
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    IF :OLD.job_id != :NEW.job_id THEN
        :NEW.hire_date := TRUNC(SYSDATE);
    END IF;
END;
/

SELECT employee_id, job_id, hire_date FROM employees WHERE employee_id = 100;

UPDATE employees
SET job_id = 'SA_MAN'
WHERE employee_id = 100;

SELECT employee_id, job_id, hire_date FROM employees WHERE employee_id = 100;



Створіть тригер, який автоматично оновлює поле EMPLOYEES.HIRE_DATE.
Деталі:
Створіть тригер (подія - BEFORE UPDATE) hire_date_update, який автоматично оновлює поле "HIRE_DATE" в таблиці "EMPLOYEES", якщо значення поля "JOB_ID" змінюється (:OLD.job_id !=
:NEW.job_id). Нове значення "HIRE_DATE" має бути поточною датою усічене до дня. Для зміни старого значення в полі "HIRE_DATE" НЕ вийди використовувати звичайний UPDATE,
тому, що буде помилка "ORA-00060: deadlock detected while waiting for resource" і це нормально поведінка транзакційної БД, так як ми одночасно пробуємо змінити значення в одній
таблиці в двох різних стовпчиках. Для зміни старого значення в полі "HIRE_DATE треба використовувати функціонал тригера, через присвоєння новому значенню, ось так -
:NEW.hire_date := TRUNC(SYSDATE). Перевірити роботу тригера.
Зберегти код створення тригера, у файл під назвою H_05_01_tvoji_inichialy.sql. Загрузити в LMS Moodle.