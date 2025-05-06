CREATE TABLE interbank_index_ua_history (
    date_index      DATE PRIMARY KEY,
    value           NUMBER,
    index_name      VARCHAR2(100),
    indicator_id    VARCHAR2(100)
);

CREATE OR REPLACE VIEW interbank_index_ua_v AS
SELECT 
    TO_DATE(json_value(value, '$.date'), 'YYYY-MM-DD') AS date_index,
    TO_NUMBER(json_value(value, '$.value')) AS value,
    json_value(value, '$.indexName') AS index_name,
    json_value(value, '$.indicatorId') AS indicator_id
FROM JSON_TABLE(
    SYS.GET_NBU('https://bank.gov.ua/NBU_uonia?id_api=UONIA_UnsecLoansDepo&json'),
    '$[*]' COLUMNS (
        value CLOB PATH '$'
    )
);

CREATE OR REPLACE PROCEDURE download_ibank_index_ua AS
BEGIN
    MERGE INTO interbank_index_ua_history t
    USING (
        SELECT * FROM interbank_index_ua_v
    ) v
    ON (t.date_index = v.date_index)
    WHEN MATCHED THEN 
        UPDATE SET 
            t.value = v.value,
            t.index_name = v.index_name,
            t.indicator_id = v.indicator_id
    WHEN NOT MATCHED THEN
        INSERT (date_index, value, index_name, indicator_id)
        VALUES (v.date_index, v.value, v.index_name, v.indicator_id);
END;
/

BEGIN
    DBMS_SCHEDULER.create_job (
        job_name        => 'JOB_DOWNLOAD_UONIA',
        job_type        => 'STORED_PROCEDURE',
        job_action      => 'download_ibank_index_ua',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=DAILY;BYHOUR=9;BYMINUTE=0',
        enabled         => TRUE
    );
END;
/

����:
������� ������� ���� ���� ���������� ������ ���� � ��, ���������� ������ ������������ ������ ��������.
�����:
��� ���� ��� �������� ���������� ������ ������������ ������ ��������, ������������� API �� ���:
https://bank.gov.ua/NBU_uonia?id_api=UONIA_UnsecLoansDepo&json
��� ��������� ������� interbank_index_ua_history � �� �� ��������� ������ JSON ���������. ��������� view interbank_index_ua_v ��
����� ������� API ����� ������� SYS.GET_NBU. View interbank_index_ua_v ������� ������ ������� JSON ��������� � ����� ��������� �
�������� ����� �����. ��� ��������� ��������� download_ibank_index_ua, ��� ������� ��������� ��� � view interbank_index_ua_v �
������� interbank_index_ua_history.
��������� download_ibank_index_ua ������� �� ������� � ���������� ����� ���� � 9 �����
�������� ��� ��������� ��� ��?����, � ���� �� ������ H_06_01_tvoji_inichialy.sql. ��������� � LMS Moodle
