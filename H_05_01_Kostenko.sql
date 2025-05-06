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



������� ������, ���� ����������� ������� ���� EMPLOYEES.HIRE_DATE.
�����:
������� ������ (���� - BEFORE UPDATE) hire_date_update, ���� ����������� ������� ���� "HIRE_DATE" � ������� "EMPLOYEES", ���� �������� ���� "JOB_ID" ��������� (:OLD.job_id !=
:NEW.job_id). ���� �������� "HIRE_DATE" �� ���� �������� ����� ������ �� ���. ��� ���� ������� �������� � ��� "HIRE_DATE" �� ����� ��������������� ��������� UPDATE,
����, �� ���� ������� "ORA-00060: deadlock detected while waiting for resource" � �� ��������� �������� ������������ ��, ��� �� �� ��������� ������� ������ �������� � ����
������� � ���� ����� ����������. ��� ���� ������� �������� � ��� "HIRE_DATE ����� ��������������� ���������� �������, ����� ��������� ������ ��������, ��� ��� -
:NEW.hire_date := TRUNC(SYSDATE). ��������� ������ �������.
�������� ��� ��������� �������, � ���� �� ������ H_05_01_tvoji_inichialy.sql. ��������� � LMS Moodle.