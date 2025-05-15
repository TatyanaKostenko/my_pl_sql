INSERT INTO sys_params (
    param_name, value_date, value_text, param_descr
) VALUES (
    'list_currencies',
    SYSDATE,
    'USD,EUR,KZT,AMD,GBP,ILS',
    'Список валют для синхронізації в процедурі util.api_nbu_sync'
);
COMMIT;
