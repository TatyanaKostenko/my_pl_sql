SET SERVEROUTPUT ON
DECLARE
v_date DATE := TO_DATE('18.04.2025','DD.MM.YYYY');
v_day NUMBER;
BEGIN
v_day := to_number(to_char(v_date, 'dd'));
IF v_day = TO_NUMBER(TO_CHAR(LAST_DAY(TRUNC(SYSDATE)), 'DD')) THEN
dbms_output.put_line('������� ��������');
ELSIF
v_day=15 THEN
dbms_output.put_line('������� ������');
ELSIF
v_day<15 THEN
dbms_output.put_line('������ �� �����');
ELSIF
v_day>15 THEN
dbms_output.put_line('������ �� ��������');
END IF;
END;
/

