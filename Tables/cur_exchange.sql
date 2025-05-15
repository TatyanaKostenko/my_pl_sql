CREATE TABLE tetyana_p15.cur_exchange (
    currency_code  VARCHAR2(3),
    exchange_rate  NUMBER,
    rate_date      DATE,
    inserted_at    DATE DEFAULT SYSDATE
);
