CREATE TABLE employees AS SELECT * FROM employees;

INSERT INTO employees (
    employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id, department_id
) VALUES (
    999, 'Tetiana', 'Kostenko', 'tgurinenko18', '672205086', SYSDATE, 'IT_PROG', 50000, NULL, 100, 60
);

CREATE OR REPLACE VIEW dept_employee_count AS
SELECT department_id AS "�� ������������", COUNT(*) AS "ʳ������ �����������"
FROM employees
GROUP BY department_id;

EXECUTE UTL_MAIL.SET_SERVER_PARAMETER('smtp_server', 'smtp.yourdomain.com');

DECLARE
    v_email      VARCHAR2(100);
    v_sender     VARCHAR2(100);
    v_message    VARCHAR2(32767);
BEGIN
    -- �������� �����
    SELECT LOWER(email) || '@gmail.com' INTO v_email
    FROM employees
    WHERE employee_id = 999;

    -- ������� HTML-�������
    v_message := '<h3>ʳ������ ���������� �� �������������</h3>';
    v_message := v_message || '<table border="1"><tr><th>�� ������������</th><th>ʳ������ �����������</th></tr>';

    FOR rec IN (
        SELECT department_id, COUNT(*) AS emp_count
        FROM employees
        GROUP BY department_id
    ) LOOP
        v_message := v_message || '<tr><td>' || rec.department_id || '</td><td>' || rec.emp_count || '</td></tr>';
    END LOOP;

    v_message := v_message || '</table>';

    -- ³������� �����
    UTL_MAIL.send(
        sender     => v_email,
        recipients => v_email,
        subject    => '��� �� �������������',
        message    => v_message,
        mime_type  => 'text/html'
    );
    
    DBMS_OUTPUT.put_line('���� ���������� �� ' || v_email);
END;
/

����:
������� �������� ��� � ��������� ���� ��� �� �����, ��������� ��� ����� ���� ����� � ������� employees.
�����:
������� ��� � ���� ���� ������� hr.employees �� ������ ���� � �� �������, �� � ���� EMAIL ����� ������ ��� �������� ���� �� �� �����. ��� ������� ��� ��� ������� ���������� �
����� ������������. ��������� ����� ���� ��������� ������ � ��� �������, �� ���� ��� ��������� - "�� ������������" �� "ʳ������ �����������". ³�������� ������� �����������
������������ � ������� employees �� ����� ��, �� EMPLOYEE_ID ����� ������ ��� ���� � ��� ��� ������������ ��� ����� ����� (��������� @GMAIL.COM)
�������� PL-SQL ���� � ���� �� ������ H_05_03_tvoji_inichialy.sql. ��������� � LMS Moodle.
