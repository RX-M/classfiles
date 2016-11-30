CREATE TABLE stockwatcher.WatchListItem (
  watchlist_id TIMEUUID,
  stock_symbol VARCHAR,
  start_price DECIMAL,
  created TIMESTAMP,
  PRIMARY KEY (watchlist_id, stock_symbol)
);
