Работа с базами данных, пользователями и правами
Цель: - создание новой базы данных, схемы и таблицы
- создание роли для чтения данных из созданной схемы созданной базы данных
- создание роли для чтения и записи из созданной схемы созданной базы данных
1 создайте новый кластер PostgresSQL 13 (на выбор - GCE, CloudSQL)
2 зайдите в созданный кластер под пользователем postgres
3 создайте новую базу данных testdb
> create database testdb;

4 зайдите в созданную базу данных под пользователем postgres
> \c testdb

> You are now connected to database "testdb" as user "postgres".

5 создайте новую схему testnm
> create schema if not exists testnm;

6 создайте новую таблицу t1 с одной колонкой c1 типа integer
> create table testnm.t1 (c1 int);

7 вставьте строку со значением c1=1
> insert into testnm.t1 (c1) values (1);

8 создайте новую роль readonly
> CREATE ROLE readonly;

9 дайте новой роли право на подключение к базе данных testdb
> GRANT CONNECT ON DATABASE testdb TO readonly;

10 дайте новой роли право на использование схемы testnm
> GRANT USAGE ON SCHEMA testnm TO readonly;

11 дайте новой роли право на select для всех таблиц схемы testnm
> GRANT SELECT ON ALL TABLES IN SCHEMA testnm TO readonly;

12 создайте пользователя testread с паролем test123
> CREATE USER testread WITH PASSWORD 'test123';

13 дайте поль readonly пользователю testread
> GRANT readonly TO testread;

14 зайдите под пользователем testread в базу данных testdb
> \c testdb testread localhost

15 сделайте select * from t1;
16 получилось? (могло если вы делали сами не по шпаргалке и не упустили один существенный момент про который позже)
> Нет, нужно указать схему
> select * from testnm.t1;

17 напишите что именно произошло в тексте домашнего задания
> ERROR:  relation "t1" does not exist

18 у вас есть идеи почему? ведь права то дали?
> Видимо в п.6 не нужно было указывать схему :)

> Попробовал создать таблицу t2 без схемы, под пользователем postgres

> При селекте под юзером testread:

> permission denied for table t2

> Логично, так как таблица создалась в схеме public, а к ней нет доступа у роли readonly

19 посмотрите на список таблиц
> \dt

>  List of relations
>   Schema | Name | Type  |  Owner
>  --------+------+-------+----------
>   public | t2   | table | postgres
>  (1 row)

> \dt testnm.*

>  List of relations
>   Schema | Name | Type  |  Owner
>  --------+------+-------+----------
>   testnm | t1   | table | postgres
>  (1 row)

20 подсказка в шпаргалке под пунктом 20
21 а почему так получилось с таблицей (если делали сами и без шпаргалки то может у вас все нормально)
22 вернитесь в базу данных testdb под пользователем postgres
23 удалите таблицу t1
24 создайте ее заново но уже с явным указанием имени схемы testnm
25 вставьте строку со значением c1=1
26 зайдите под пользователем testread в базу данных testdb
27 сделайте select * from testnm.t1;
28 получилось?
> ERROR:  permission denied for table t1

29 есть идеи почему? если нет - смотрите шпаргалку
> Нет. Эх...
> Таблица пересоздавалась, права были на конкретные таблицы в момент выдачи прав.

30 как сделать так чтобы такое больше не повторялось? если нет идей - смотрите шпаргалку
> alter default privileges in schema testnm grant select on tables to readonly;

31 сделайте select * from testnm.t1;
32 получилось?
33 есть идеи почему? если нет - смотрите шпаргалку
> Подсмотрел
> alter default действует для новых таблиц. Для старых нужно явно выдать права или пересоздать.

31 сделайте select * from testnm.t1;
32 получилось?
> Да уж.... Заново выдал права через grant.

33 ура!
> Получилось :)

34 теперь попробуйте выполнить команду create table t2(c1 integer); insert into t2 values (2);
> Сработало

35 а как так? нам же никто прав на создание таблиц и insert в них под ролью readonly?
> В схеме public можно 
> When you create a new database, any role is allowed to create objects in the public schema

36 есть идеи как убрать эти права? если нет - смотрите шпаргалку
> Подсмотрел

> revoke create on schema public from public
> revoke all on database testdb from public;

37 если вы справились сами то расскажите что сделали и почему, если смотрели шпаргалку - объясните что сделали и почему выполнив указанные в ней команды
> Удаляем право создавать и вставлять в таблицы в схеме паблик для унаследованной роли public
> Удаляем возможность некоторых операций с testdb по умолчанию для унаследованной роли public

38 теперь попробуйте выполнить команду create table t3(c1 integer); insert into t2 values (2);
> ERROR:  permission denied for schema public

39 расскажите что получилось и почему
> Теперь не можем, так как порезали права