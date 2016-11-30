CREATE TABLE stockwatcher.StockSearch (
  industry_id INT,
  exchange_id VARCHAR,
  stock_symbol VARCHAR,
  PRIMARY KEY (industry_id, exchange_id, stock_symbol)
);

