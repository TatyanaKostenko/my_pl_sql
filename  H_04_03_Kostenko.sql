FUNCTION get_sum_price_sales(p_table IN VARCHAR2) RETURN NUMBER IS
    v_sql   VARCHAR2(1000);
    v_sum   NUMBER;
    v_err_msg VARCHAR2(200) := '������������ ��������! ��������� products ��� products_old';
BEGIN
    -- �������� �������� p_table
    IF p_table NOT IN ('products', 'products_old') THEN
        to_log(p_message => v_err_msg);
        raise_application_error(-20001, v_err_msg);
    END IF;

    -- ���������� �� ��������� ���������� SQL
    v_sql := 'SELECT SUM(price_sales) FROM hr.' || p_table;
    EXECUTE IMMEDIATE v_sql INTO v_sum;

    RETURN v_sum;
EXCEPTION
    WHEN OTHERS THEN
        raise_application_error(-20002, '������� ��� ��������� ����: ' || SQLERRM);
END get_sum_price_sales;

-- ���������� ������� � PACKAGE
FUNCTION get_sum_price_sales(p_table IN VARCHAR2) RETURN NUMBER;


����:
�� ����� ������� PL-SQL ����� � �������� �� ��� "��������� SQL", �������� ������� � ����� util, ��� � ��������� ���� � ����� HR, � ������� products ��� products_old.
�����:
�������� ������� util.get_sum_price_sales � ����� ������� ���������� p_table (��� �������� ������� ��������� ����� �� ���������� - products ��� products_old) - ���� �������� � ��������
p_table, ����-��� ���� ��������, ��� ����������� �� products ��� products_old, ��� ������ ���������� ������� � ������� "������������ ��������! ��������� products ��� products_old" (��� �������
-20001). ���� �������� �������, ��� ������� ������� ������� ���� �� ���� price_sales � ������� �������.
�����, ���� �������� �� �������, ����� �������� raise_application_error, ��������� ��������� to_log ��� ������ � ��� ��� �� ������� ������ �������. � �������� p_message �������� ����� ����� ��
����� �� � � raise_application_error.
�������� ��� ��������� ������� � ���� �� ������ H_04_03_tvoji_inichialy.sql. ��������� � LMS Moodle.