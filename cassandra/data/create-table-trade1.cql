CREATE TABLE stockwatcher.Trade (
  stock_symbol VARCHAR,
  trade_timestamp TIMESTAMP,
  exchange_id VARCHAR,
  share_price DECIMAL,
  share_quantity INT,
  PRIMARY KEY (stock_symbol, trade_timestamp)
);
