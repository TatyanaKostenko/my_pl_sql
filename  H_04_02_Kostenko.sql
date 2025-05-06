PROCEDURE del_jobs(
  p_job_id IN tetyana_p15.jobs.job_id%TYPE,
  po_result OUT VARCHAR2
) IS
  v_delete_no_data_found EXCEPTION;
BEGIN
  -- Перевірка на робочий день
  check_work_time;
  -- Спроба видалення
  BEGIN
    DELETE FROM tetyana_p15.jobs
    WHERE job_id = p_job_id;
    IF SQL%ROWCOUNT = 0 THEN
      RAISE v_delete_no_data_found;
    END IF;
    po_result := 'Посада ' || p_job_id || ' успішно видалена';
  EXCEPTION
    WHEN v_delete_no_data_found THEN
      raise_application_error(-20004, 'Посада ' || p_job_id || ' не існує');
    WHEN OTHERS THEN
      raise_application_error(-20005, 'Помилка при видаленні посади: ' || SQLERRM);
  END;
END del_jobs;

-- Оголошення процедури у PACKAGE
PROCEDURE del_jobs(
  p_job_id IN tetyana_p15.jobs.job_id%TYPE,  po_result OUT VARCHAR2);

Опис:
Доробити існуючу процедуру util.del_jobs через використання EXCEPTION-нів.
Деталі:
Шматок коду з DELETE обернути в BEGIN .. EXCEPTION .. END. Оголосити змінну v_delete_no_data_found типу даних EXCEPTION. Відразу після виконання DELETE, зробити якщо
SQL%ROWCOUNT = 0 тоді запускати RAISE v_delete_no_data_found. В блоці EXCEPTION написати якщо наступила наша користувацька помилка v_delete_no_data_found, тоді
генерувати помилку (через raise_application_error) "Посада <p_job_id> не існує" (код помилки -20004). В конструкції через EXCEPTION, нам НЕ потрібна змінна v_is_exist_job
та SELECT INTO, де ми записуємо в цю змінну кількість. Також в підсумку НЕ потрібен IF..ELSE де ми шось шукали в змінній v_is_exist_job. Тобто все НЕ потрібне треба
прибрати. В піддсумку, якщо посада видалена успішно, залишити як і було запис тексту "Посада <p_job_id> успішно видалена" у вихідний параметр po_result.
Також перед блоком з видаленням посади, з початку треба перевірити чи робочий сьогодні день. Це зробити просто за допомогою виклику процедури check_work_time.
Зберегти код доробленої оголошеної функції у файл під назвою H_04_02_tvoji_inichialy.sql. Загрузити в LMS Moodle