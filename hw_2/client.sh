#!/bin/sh

# client.sh

until psql -h "pg-server" -U "admin" -c '\q'; do
   echo "Postgres is unavailable - sleeping"
  sleep 1
done

echo "ok! Postgres is available!"
psql -h "pg-server" -U "admin" -c "create table if not exists test(c1 text);";
psql -h "pg-server" -U "admin" -c "\dt";
psql -h "pg-server" -U "admin" -c "insert into test values('hello!');";
psql -h "pg-server" -U "admin" -c "select * from test;";