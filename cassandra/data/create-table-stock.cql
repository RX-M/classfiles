CREATE TABLE stockwatcher.Stock (
  stock_symbol VARCHAR,
  company_name VARCHAR,
  active BOOLEAN,
  current_price DECIMAL,
  exchange_id VARCHAR,
  PRIMARY KEY (stock_symbol)
);
