CREATE OR REPLACE PACKAGE log_util IS
  PROCEDURE log_start(
    p_proc_name IN VARCHAR2,
    p_text      IN VARCHAR2 DEFAULT NULL
  );

  PROCEDURE log_finish(
    p_proc_name IN VARCHAR2,
    p_text      IN VARCHAR2 DEFAULT NULL
  );

  PROCEDURE log_error(
    p_proc_name IN VARCHAR2,
    p_sqlerrm   IN VARCHAR2,
    p_text      IN VARCHAR2 DEFAULT NULL
  );
END log_util;
/

CREATE OR REPLACE PACKAGE BODY log_util IS

  -- �������� ��������� ��������� (��������� ����� � body)
  PROCEDURE to_log(
    p_appl_proc IN VARCHAR2,
    p_message   IN VARCHAR2
  ) IS
  BEGIN
    -- ��� ������� ������ ������� � ����� ������� ����
    INSERT INTO log_table (log_date, appl_proc, message)
    VALUES (SYSDATE, p_appl_proc, p_message);
    
    COMMIT;
  END to_log;

  PROCEDURE log_start(
    p_proc_name IN VARCHAR2,
    p_text      IN VARCHAR2 DEFAULT NULL
  ) IS
    v_text VARCHAR2(4000);
  BEGIN
    IF p_text IS NULL THEN
      v_text := '����� ���������, ����� ������� = ' || p_proc_name;
    ELSE
      v_text := p_text;
    END IF;

    to_log(p_appl_proc => p_proc_name, p_message => v_text);
  END log_start;

  PROCEDURE log_finish(
    p_proc_name IN VARCHAR2,
    p_text      IN VARCHAR2 DEFAULT NULL
  ) IS
    v_text VARCHAR2(4000);
  BEGIN
    IF p_text IS NULL THEN
      v_text := '���������� ���������, ����� ������� = ' || p_proc_name;
    ELSE
      v_text := p_text;
    END IF;

    to_log(p_appl_proc => p_proc_name, p_message => v_text);
  END log_finish;

  PROCEDURE log_error(
    p_proc_name IN VARCHAR2,
    p_sqlerrm   IN VARCHAR2,
    p_text      IN VARCHAR2 DEFAULT NULL
  ) IS
    v_text VARCHAR2(4000);
  BEGIN
    IF p_text IS NULL THEN
      v_text := '� �������� ' || p_proc_name || ' ������� �������. ' || p_sqlerrm;
    ELSE
      v_text := p_text;
    END IF;

    to_log(p_appl_proc => p_proc_name, p_message => v_text);
  END log_error;

END log_util;
/


