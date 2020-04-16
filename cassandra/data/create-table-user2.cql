DROP TABLE IF EXISTS stockwatcher.User;
CREATE TABLE stockwatcher.User (
  user_id TIMEUUID,
  display_name VARCHAR,
  first_name VARCHAR,
  last_name VARCHAR,
  emails SET<VARCHAR>,
  strategies LIST<VARCHAR>,
  PRIMARY KEY (user_id)
);

