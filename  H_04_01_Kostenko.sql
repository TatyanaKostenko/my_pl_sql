-- �������� ��������� check_work_time � BODY ������ util 
PROCEDURE check_work_time IS
BEGIN
  IF TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE = AMERICAN') IN ('SAT', 'SUN') THEN
    raise_application_error(-20205, '�� ������ ������� ���� ���� � ������ ��');
  END IF;
END check_work_time;

-- �������� ��������� add_new_jobs:
PROCEDURE add_new_jobs(
  p_job_id IN VARCHAR2,
  p_job_title IN VARCHAR2,
  p_min_salary IN VARCHAR2,
  p_max_salary IN NUMBER DEFAULT NULL,
  po_err OUT VARCHAR2
) IS
  v_max_salary jobs.max_salary%TYPE;
  salary_err EXCEPTION;
BEGIN
  check_work_time;

  IF p_max_salary IS NULL THEN
    v_max_salary := p_min_salary * c_percent_of_min_salary;
  ELSE
    v_max_salary := p_max_salary;
  END IF;

  BEGIN
    IF (p_min_salary < 2000 OR p_max_salary < 2000) THEN
      RAISE salary_err;
    END IF;

    INSERT INTO jobs(job_id, job_title, min_salary, max_salary)
    VALUES (p_job_id, p_job_title, p_min_salary, v_max_salary);

    po_err := '������ '||p_job_id||' ������ ������';

  EXCEPTION
    WHEN salary_err THEN
      raise_application_error(-20001, '�������� �������� ����� �� 2000');
    WHEN dup_val_on_index THEN
      raise_application_error(-20002, '������ '||p_job_id||' ��� ����');
    WHEN OTHERS THEN
      raise_application_error(-20003, '������� ������� ��� �������� ���� ������. '|| SQLERRM);
  END;
END add_new_jobs;



����:
�������� ������ ��������� �������� ������� ���. ��� ������������ �� � �������� �����, ��� �� ��������� ���.
�����:
�������� ������ ��������� (��� ������� �� �������� ���������) � check_work_time, ����� ������� ��� � ��������� util.add_new_jobs. �����, ��� ������� ���������, ������� ����������� ���� �������
����, � ���� ������� ������ ��� ����� ��������� ������� ���������� ��� ������� -20205 �� ����� ������� "�� ������ ������� ���� ���� � ������ ��". ��������� check_work_time �������� ����� �
body ������ util.
� �������� util.add_new_jobs ����������� ��������� check_work_time ������ ���� ���� ��� �� ���� �������� ������� ���.
�������� ��� ��� ���������� ��������� check_work_time � ����� util, � ���� �� ������ H_04_01_tvoji_inichialy.sql. ��������� � LMS Moodle.


