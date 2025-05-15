BEGIN
  util.change_attribute_employee(
    p_employee_id    => 357,
    p_first_name     => 'Таня',
    p_salary         => 500000
  );
END;
/
