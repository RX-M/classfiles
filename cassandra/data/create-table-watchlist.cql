CREATE TABLE stockwatcher.WatchList (
  watchlist_id TIMEUUID,
  user_id TIMEUUID,
  display_name VARCHAR,
  visibility VARCHAR,
  active BOOLEAN,
  PRIMARY KEY (watchlist_id)
);
