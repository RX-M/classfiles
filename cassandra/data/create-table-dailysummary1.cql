CREATE TABLE stockwatcher.DailySummary (
  stock_symbol VARCHAR,
  trade_date TIMESTAMP,
  price_open DECIMAL,
  price_close DECIMAL,
  price_high DECIMAL,
  price_low DECIMAL,
  share_volume INT,
  PRIMARY KEY (stock_symbol, trade_date)
);
