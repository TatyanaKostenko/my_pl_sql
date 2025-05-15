create or replace PACKAGE pkg_table_copy IS
  -- Головна процедура
  PROCEDURE copy_table(
    p_source_scheme IN VARCHAR2,
    p_target_scheme IN VARCHAR2 DEFAULT USER,
    p_list_table    IN VARCHAR2,
    p_copy_data     IN BOOLEAN DEFAULT FALSE,
    po_result       OUT VARCHAR2
  );
END pkg_table_copy;

create or replace PACKAGE BODY pkg_table_copy IS

  -- Тип для списку таблиць
  TYPE t_varchar2_tab IS TABLE OF VARCHAR2(4000);

  -- Pipelined функція для розбиття CSV
  FUNCTION table_from_list(p_list IN VARCHAR2) 
  RETURN t_varchar2_tab PIPELINED IS
    v_str VARCHAR2(4000) := p_list || ',';
    v_pos PLS_INTEGER;
  BEGIN
    LOOP
      v_pos := INSTR(v_str, ',');
      EXIT WHEN v_pos = 0;
      PIPE ROW(TRIM(SUBSTR(v_str, 1, v_pos - 1)));
      v_str := SUBSTR(v_str, v_pos + 1);
    END LOOP;
    RETURN;
  END;

  -- Процедура логування
  PROCEDURE to_log(p_message IN VARCHAR2) IS
  BEGIN
    INSERT INTO log_table(message, log_time)
    VALUES (p_message, SYSTIMESTAMP);
    COMMIT;
  END;

  -- Процедура створення таблиці (автономна транзакція)
  PROCEDURE do_create_table(p_sql IN VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    EXECUTE IMMEDIATE p_sql;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      NULL; -- помилку опрацьовує головна процедура
  END;

  -- Головна процедура
  PROCEDURE copy_table(
    p_source_scheme IN VARCHAR2,
    p_target_scheme IN VARCHAR2 DEFAULT USER,
    p_list_table    IN VARCHAR2,
    p_copy_data     IN BOOLEAN DEFAULT FALSE,
    po_result       OUT VARCHAR2
  ) IS

    CURSOR cur_tables IS
      SELECT table_name,
             'CREATE TABLE ' || p_target_scheme || '.' || table_name || ' (' ||
             LISTAGG(column_name || ' ' || data_type || NVL(count_symbol, ''), ', ')
             WITHIN GROUP(ORDER BY column_id) || ')' AS ddl_code
      FROM (
        SELECT table_name,
               column_name,
               data_type,
               CASE
                 WHEN data_type IN ('VARCHAR2', 'CHAR') THEN '(' || data_length || ')'
                 WHEN data_type = 'NUMBER' THEN 
                      CASE 
                        WHEN data_precision IS NOT NULL AND data_scale IS NOT NULL THEN '(' || data_precision || ',' || data_scale || ')'
                        WHEN data_precision IS NOT NULL THEN '(' || data_precision || ')'
                        ELSE NULL
                      END
                 ELSE NULL
               END AS count_symbol,
               column_id
        FROM all_tab_columns
        WHERE owner = UPPER(p_source_scheme)
          AND table_name IN (SELECT * FROM TABLE(table_from_list(p_list_table)))
      )
      GROUP BY table_name;

  BEGIN
    FOR rec IN cur_tables LOOP
      BEGIN
        -- Перевірка наявності таблиці
        DECLARE
          v_exists NUMBER;
        BEGIN
          SELECT COUNT(*) INTO v_exists
          FROM all_tables
          WHERE owner = UPPER(p_target_scheme)
            AND table_name = rec.table_name;

          IF v_exists = 0 THEN
            -- Створення таблиці
            do_create_table(rec.ddl_code);
            to_log('Таблиця ' || rec.table_name || ' створена в схемі ' || p_target_scheme);

            -- Копіювання даних
            IF p_copy_data THEN
              EXECUTE IMMEDIATE 'INSERT INTO ' || p_target_scheme || '.' || rec.table_name ||
                                ' SELECT * FROM ' || p_source_scheme || '.' || rec.table_name;
              to_log('Дані скопійовано в таблицю ' || rec.table_name);
            END IF;
          ELSE
            to_log('Таблиця ' || rec.table_name || ' вже існує в схемі ' || p_target_scheme || '. Пропущено.');
          END IF;

        END;

      EXCEPTION
        WHEN OTHERS THEN
          to_log('ПОМИЛКА при обробці таблиці ' || rec.table_name || ': ' || SQLERRM);
          CONTINUE;
      END;

    END LOOP;

    po_result := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      po_result := 'ERROR: ' || SQLERRM;
      to_log(po_result);
  END;

END pkg_table_copy;
