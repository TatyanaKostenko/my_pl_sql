CREATE TABLE projects_ext (
    project_id     NUMBER,
    project_name   VARCHAR2(100),
    department_id  NUMBER
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY files_from_server
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
        (
            project_id     INTEGER EXTERNAL,
            project_name   CHAR,
            department_id  INTEGER EXTERNAL
        )
    )
    LOCATION ('PROJECTS.csv')
)
REJECT LIMIT UNLIMITED;

CREATE OR REPLACE VIEW rep_project_dep_v AS
SELECT
    d.department_name,
    p.project_name,
    COUNT(e.employee_id) AS employee_count,
    COUNT(DISTINCT e.manager_id) AS unique_managers,
    SUM(e.salary) AS total_salary
FROM projects_ext p
JOIN departments d ON p.department_id = d.department_id
JOIN employees e ON e.department_id = p.department_id
GROUP BY d.department_name, p.project_name;

DECLARE
    file_handle  UTL_FILE.FILE_TYPE;
BEGIN
    file_handle := UTL_FILE.FOPEN('FILES_FROM_SERVER', 'TOTAL_PROJ_INDEX_IP.csv', 'W');

    -- �������� ���������
    UTL_FILE.PUT_LINE(file_handle, 'Department Name,Project Name,Employee Count,Unique Managers,Total Salary');

    -- ���� �� VIEW
    FOR rec IN (
        SELECT * FROM rep_project_dep_v
    ) LOOP
        UTL_FILE.PUT_LINE(file_handle,
            rec.department_name || ',' ||
            rec.project_name || ',' ||
            rec.employee_count || ',' ||
            rec.unique_managers || ',' ||
            rec.total_salary
        );
    END LOOP;

    UTL_FILE.FCLOSE(file_handle);
END;
/

����:
������� �������� ��� � ���������� CSV ���� �� �����.
�����:
������� ��� �� ����� CSV ����� PROJECTS.csv (� ���� ��� �����, ����� ��� ������), ���� ����������� � �������� FILES_FROM_SERVER, ���������: project_id NUMBER, project_name
VARCHAR2, department_id NUMBER). ���������� ���������� ��� � ������ ����� ������, �� ����� �������� ����� ������������, ������� �����������, ������� ��������� ��������� ��
������� ��������. SQL ����� ���� ����� ���������� ���, ����� ��������� � VIEW rep_project_dep_v � � ������� ����� FOR, ����?������ ��������������� ����� � rep_project_dep_v
(������ ������ � ������� FOR ����� ������� "FROM EXTERNAL" � ������� PL-SQL ����� ���� ����������� �� ����������� �������. � ����� �������� VIEW - Ͳ). ��������� ��� �����
����������� � ��������� FILES_FROM_SERVER �� ������ TOTAL_PROJ_INDEX_tvoji_inichialy.csv
�������� PL-SQL ���� � ���� �� ������ H_05_02_tvoji_inichialy.sql. ��������� � LMS Moodle.