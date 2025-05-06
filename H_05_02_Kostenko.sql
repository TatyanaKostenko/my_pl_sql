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

    -- Записуємо заголовок
    UTL_FILE.PUT_LINE(file_handle, 'Department Name,Project Name,Employee Count,Unique Managers,Total Salary');

    -- Цикл по VIEW
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

Опис:
Зробити потрібний звіт і сформувати CSV файл на диску.
Деталі:
Зробити звіт на основі CSV файлу PROJECTS.csv (у файлі три рядка, тобто три проєкти), файл знаходиться у директорії FILES_FROM_SERVER, структура: project_id NUMBER, project_name
VARCHAR2, department_id NUMBER). Необхідний групований звіт в рамках трьох проєктів, де треба показати назву департаментів, кількість співробітників, кількість унікальних менеджерів та
сумарна зарплата. SQL запит який формує остаточний звіт, треба завернути у VIEW rep_project_dep_v і в середині цикла FOR, обов?язково використовувати запит з rep_project_dep_v
(просто селект в середині FOR через механізм "FROM EXTERNAL" в середині PL-SQL блока буде сприйматися як синтаксична помилка. А через оболонку VIEW - НІ). Отриманий звіт треба
завантажити в директорію FILES_FROM_SERVER під назвою TOTAL_PROJ_INDEX_tvoji_inichialy.csv
Зберегти PL-SQL блок у файл під назвою H_05_02_tvoji_inichialy.sql. Загрузити в LMS Moodle.