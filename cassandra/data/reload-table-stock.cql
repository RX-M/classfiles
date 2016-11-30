TRUNCATE stockwatcher.stock;
COPY stockwatcher.stock (stock_symbol, company_name, exchange_id, active, current_price, industry_id) FROM 'stocks-v2.csv';

