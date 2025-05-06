FUNCTION get_sum_price_sales(p_table IN VARCHAR2) RETURN NUMBER IS
    v_sql   VARCHAR2(1000);
    v_sum   NUMBER;
    v_err_msg VARCHAR2(200) := 'Неприпустиме значення! Очікується products або products_old';
BEGIN
    -- Перевірка значення p_table
    IF p_table NOT IN ('products', 'products_old') THEN
        to_log(p_message => v_err_msg);
        raise_application_error(-20001, v_err_msg);
    END IF;

    -- Формування та виконання динамічного SQL
    v_sql := 'SELECT SUM(price_sales) FROM hr.' || p_table;
    EXECUTE IMMEDIATE v_sql INTO v_sum;

    RETURN v_sum;
EXCEPTION
    WHEN OTHERS THEN
        raise_application_error(-20002, 'Помилка при обчисленні суми: ' || SQLERRM);
END get_sum_price_sales;

-- Оголошення функції у PACKAGE
FUNCTION get_sum_price_sales(p_table IN VARCHAR2) RETURN NUMBER;


Опис:
На основі першого PL-SQL блоку з практики по темі "Динамічний SQL", написати функцію в пакеті util, яка б повертала суму зі схеми HR, з таблиці products або products_old.
Деталі:
Створити функцію util.get_sum_price_sales з одним вхідним параметром p_table (цей параметр повинен працювати тільки із значеннями - products або products_old) - якщо передати в параметр
p_table, будь-яке інше значення, яке відрізняється від products або products_old, тоді відразу генерувати помилку з текстом "Неприпустиме значення! Очікується products або products_old" (код помилки
-20001). Якщо перевірка пройшла, тоді функція повинна вивести суму по полю price_sales з потрібної таблиці.
Також, якщо перевірка не пройшла, перед викликом raise_application_error, викликати процедуру to_log для запису в лог про не успішний виклик функції. В параметр p_message передати точно такий же
текст як і в raise_application_error.
Зберегти код оголошеної функції у файл під назвою H_04_03_tvoji_inichialy.sql. Загрузити в LMS Moodle.