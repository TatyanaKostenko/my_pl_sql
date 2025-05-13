CREATE TABLE log_table (
  log_id     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  log_date   DATE DEFAULT SYSDATE,
  appl_proc  VARCHAR2(100),
  message    VARCHAR2(4000)
);
