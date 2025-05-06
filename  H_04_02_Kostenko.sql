PROCEDURE del_jobs(
  p_job_id IN tetyana_p15.jobs.job_id%TYPE,
  po_result OUT VARCHAR2
) IS
  v_delete_no_data_found EXCEPTION;
BEGIN
  -- �������� �� ������� ����
  check_work_time;
  -- ������ ���������
  BEGIN
    DELETE FROM tetyana_p15.jobs
    WHERE job_id = p_job_id;
    IF SQL%ROWCOUNT = 0 THEN
      RAISE v_delete_no_data_found;
    END IF;
    po_result := '������ ' || p_job_id || ' ������ ��������';
  EXCEPTION
    WHEN v_delete_no_data_found THEN
      raise_application_error(-20004, '������ ' || p_job_id || ' �� ����');
    WHEN OTHERS THEN
      raise_application_error(-20005, '������� ��� �������� ������: ' || SQLERRM);
  END;
END del_jobs;

-- ���������� ��������� � PACKAGE
PROCEDURE del_jobs(
  p_job_id IN tetyana_p15.jobs.job_id%TYPE,  po_result OUT VARCHAR2);

����:
�������� ������� ��������� util.del_jobs ����� ������������ EXCEPTION-��.
�����:
������ ���� � DELETE �������� � BEGIN .. EXCEPTION .. END. ��������� ����� v_delete_no_data_found ���� ����� EXCEPTION. ³����� ���� ��������� DELETE, ������� ����
SQL%ROWCOUNT = 0 ��� ��������� RAISE v_delete_no_data_found. � ����� EXCEPTION �������� ���� ��������� ���� ������������� ������� v_delete_no_data_found, ���
���������� ������� (����� raise_application_error) "������ <p_job_id> �� ����" (��� ������� -20004). � ����������� ����� EXCEPTION, ��� �� ������� ����� v_is_exist_job
�� SELECT INTO, �� �� �������� � �� ����� �������. ����� � ������� �� ������� IF..ELSE �� �� ���� ������ � ����� v_is_exist_job. ����� ��� �� ������� �����
��������. � ��������, ���� ������ �������� ������, �������� �� � ���� ����� ������ "������ <p_job_id> ������ ��������" � �������� �������� po_result.
����� ����� ������ � ���������� ������, � ������� ����� ��������� �� ������� ������� ����. �� ������� ������ �� ��������� ������� ��������� check_work_time.
�������� ��� ��������� ��������� ������� � ���� �� ������ H_04_02_tvoji_inichialy.sql. ��������� � LMS Moodle