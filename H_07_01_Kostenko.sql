CREATE OR REPLACE PACKAGE util AS
    TYPE region_cnt_emp_rec IS RECORD (
        region_name regions.region_name%TYPE,
        cnt_emp     NUMBER
    );

    TYPE region_cnt_emp_tab IS TABLE OF region_cnt_emp_rec PIPELINED;

    FUNCTION get_region_cnt_emp(p_department_id IN departments.department_id%TYPE DEFAULT NULL)
        RETURN region_cnt_emp_tab PIPELINED;
END util;
/

CREATE OR REPLACE PACKAGE BODY util AS

    FUNCTION get_region_cnt_emp(p_department_id IN departments.department_id%TYPE DEFAULT NULL)
        RETURN region_cnt_emp_tab PIPELINED IS

        v_rec region_cnt_emp_rec;

        CURSOR cur IS
            SELECT
                r.region_name,
                COUNT(e.employee_id) AS cnt_emp
            FROM
                employees e
                JOIN departments d ON e.department_id = d.department_id
                JOIN locations l ON d.location_id = l.location_id
                JOIN countries c ON l.country_id = c.country_id
                JOIN regions r ON c.region_id = r.region_id
            WHERE
                (e.department_id = p_department_id OR p_department_id IS NULL)
            GROUP BY
                r.region_name;

    BEGIN
        FOR rec IN cur LOOP
            v_rec.region_name := rec.region_name;
            v_rec.cnt_emp     := rec.cnt_emp;
            PIPE ROW(v_rec);
        END LOOP;

        RETURN;
    END get_region_cnt_emp;

END util;
/


����:
�������� pipelined ������� get_region_cnt_emp
�����:
�������� ������ ������ �� ������� ����������� � ������� �����. ���� ���� ������� ������� SQL �����, ������� ����� ������ ������ where (em.department_id = null or null is null). ��� �
����� util �������� pipelined ������� get_region_cnt_emp � ��������� ������ RECORD �� TABLE. ������� ������� �������� p_department_id default null � � ������� ������� �������� ���
�������� � SQL ����� - where (em.department_id = p_department_id or p_department_id is null). ����� ����� ���� ������� ��������� ��� �������� � �������� p_department_id, �������
������� ��������� ��� �� ��� ������������� ����, � ���� �������� ��������� �������� � p_department_id, ��� ������� ������� ��������� ��� �� ���������� ������������.
����, �� ��� � �� ��'���� �� �������� � ���� HR: https://docs.google.com/document/d/14tevUjgjfNqiwqKsxGBokP6__DeMpHxB/edit
�������� PL-SQL ���� � ���� �� ������ H_07_01_tvoji_inichialy.sql. ��������� � LMS Moodle
