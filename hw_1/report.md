###Работа с уровнями изоляции транзакции в PostgreSQL
Цель: 
- научится работать с Google Cloud Platform на уровне Google Compute Engine (IaaS)
- научится управлять уровнем изолции транзации в PostgreSQL и понимать особенность работы уровней read commited и repeatable read
- создать новый проект в Google Cloud Platform, например postgres2020-<yyyymmdd>, где yyyymmdd год, месяц и день вашего рождения (имя проекта должно быть уникально на уровне GCP)
- дать возможность доступа к этому проекту пользователю postgres202010@gmail.com с ролью Project Editor
> +
- далее создать инстанс виртуальной машины Compute Engine с дефолтными параметрами
- добавить свой ssh ключ в GCE metadata
- зайти удаленным ssh (первая сессия), не забывайте про ssh-add
- поставить PostgreSQL
- зайти вторым ssh (вторая сессия)
- запустить везде psql из под пользователя postgres
- выключить auto commit
- сделать в первой сессии новую таблицу и наполнить ее данными
create table persons(id serial, first_name text, second_name text);
insert into persons(first_name, second_name) values('ivan', 'ivanov');
insert into persons(first_name, second_name) values('petr', 'petrov');
commit;
- посмотреть текущий уровень изоляции: show transaction isolation level
> read committed
- начать новую транзакцию в обоих сессиях с дефолтным (не меняя) уровнем изоляции
- в первой сессии добавить новую запись
insert into persons(first_name, second_name) values('sergey', 'sergeev');
- сделать select * from persons во второй сессии
- видите ли вы новую запись и если да то почему?
> Нет, т.к. транзакция 1 не зафиксирована, грязные чтения невозможны в pg
- завершить первую транзакцию - commit;
- сделать select * from persons во второй сессии
- видите ли вы новую запись и если да то почему?
> Да, транзакция 1 зафиксирована, при каждой операции транзакции 2 видим зафиксированный снапшот на момент начала операции
- завершите транзакцию во второй сессии
- начать новые но уже repeatable read транзации - set transaction isolation level repeatable read;
- в первой сессии добавить новую запись
insert into persons(first_name, second_name) values('sveta', 'svetova');
- сделать select * from persons во второй сессии
- видите ли вы новую запись и если да то почему?
> Нет, транзация 1 не закоммичена
- завершить первую транзакцию - commit;
- сделать select * from persons во второй сессии
- видите ли вы новую запись и если да то почему?
> Нет, т.к. уровень изоляции repeatable read, то видим снапшот на момент начала транзакции, а не операции
- завершить вторую транзакцию
- сделать select * from persons во второй сессии
- видите ли вы новую запись и если да то почему?
> Теперь да, так как снапшот на момент создания транзакции теперь содержит новую строку
- остановите виртуальную машину но не удаляйте ее
