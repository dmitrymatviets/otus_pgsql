## Домашнее задание
#### Установка и настройка PostgteSQL в контейнере Docker
Цель:
- создавать дополнительный диск для уже существующей виртуальной машины, размечать его и делать на нем файловую систему
- переносить содержимое базы данных PostgreSQL на дополнительный диск
- переносить содержимое БД PostgreSQL между виртуальными машинами
- установить PostgreSQL в Docker контейнере
- настроить контейнер для внешнего подключения
1 вариант:
- создайте виртуальную машину c Ubuntu 20.04 LTS (bionic) в GCE типа e2-medium в default VPC в любом регионе и зоне, например us-central1-a
- поставьте на нее PostgreSQL через sudo apt
> Поставил 13 версию по инструкции https://www.postgresql.org/download/linux/debian/
- проверьте что кластер запущен через sudo -u postgres pg_lsclusters
> Ver Cluster Port Status Owner    Data directory              Log file
  13  main    5432 online postgres /var/lib/postgresql/13/main /var/log/postgresql/postgresql-13-main.log
- зайдите из под пользователя postgres в psql и сделайте произвольную таблицу с произвольным содержимым
postgres=# create table test(c1 text);
postgres=# insert into test values('1');
\q
- остановите postgres например через sudo -u postgres pg_ctlcluster 13 main stop
> Status down
> Ver Cluster Port Status Owner    Data directory              Log file
> 13  main    5432 down   postgres /var/lib/postgresql/13/main /var/log/postgresql/postgresql-13-main.log
- создайте новый standard persistent диск GKE через Compute Engine -> Disks в том же регионе и зоне что GCE инстанс размером например 10GB
- добавьте свеже-созданный диск к виртуальной машине - надо зайти в режим ее редактирования и дальше выбрать пункт attach existing disk
- проинициализируйте диск согласно инструкции и подмонтировать файловую систему, только не забывайте менять имя диска на актуальное, в вашем случае это скорее всего будет /dev/sdb - https://www.digitalocean.com/community/tutorials/how-to-partition-and-format-storage-devices-in-linux
> После настроек в /etc/fstab, диск остается подмонтированным после перезагрузки. Проверил через sudo reboot.
- сделайте пользователя postgres владельцем /mnt/data - chown -R postgres:postgres /mnt/data/
- перенесите содержимое /var/lib/postgres/10 в /mnt/data - mv /var/lib/postgresql/13 /mnt/data
- попытайтесь запустить кластер - sudo -u postgres pg_ctlcluster 13 main start
- напишите получилось или нет и почему
> Не получилось, т.к. в настройках задана Data Directory кластера /var/lib/postgresql/13/main, а ее переместили выше
- задание: найти конфигурационный параметр в файлах раположенных в /etc/postgresql/10/main который надо поменять и поменяйте его
- напишите что и почему поменяли
> postgresql.conf: data_directory = '/mnt/data/13/main' 
> т.к. перенесли данные кластера на внешний диск
- попытайтесь запустить кластер - sudo -u postgres pg_ctlcluster 13 main start
- напишите получилось или нет и почему
> Получилось
- зайдите через через psql и проверьте содержимое ранее созданной таблицы
> Присутствует
- задание со звездочкой: не удаляя существующий GCE инстанс сделайте новый, поставьте на его PostgreSQL, удалите файлы с данными из /var/lib/postgres, перемонтируйте внешний диск который сделали ранее от первой виртуальной машины ко второй и запустите PostgreSQL на второй машине так чтобы он работал с данными на внешнем диске, расскажите как вы это сделали и что в итоге получилось.
> Диск уже был размечен, нужно было только примонтировать и настроить конфиг. Таблицы перенеслись.

2 вариант:
- сделать в GCE инстанс с Ubuntu 20.04
- поставить на нем Docker Engine
> Поставил docker и docker compose 
- сделать каталог /var/lib/postgres
> Сделал
- развернуть контейнер с PostgreSQL 13 смонтировав в него /var/lib/postgres
- развернуть контейнер с клиентом postgres
- подключится из контейнера с клиентом к контейнеру с сервером и сделать таблицу с парой строк
> Сделал файлы client.sh и docker-compose.yml (выложены рядом в текущей папке).
> Запустил через docker-compose up
> pg-server_1  | 2020-11-21 12:53:14.193 UTC [1] LOG:  starting PostgreSQL 13.1 (Debian 13.1-1.pgdg100+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 8.3.0-6) 8.3.0, 64-bit
>  pg-server_1  | 2020-11-21 12:53:14.193 UTC [1] LOG:  listening on IPv4 address "0.0.0.0", port 5432
>  pg-server_1  | 2020-11-21 12:53:14.193 UTC [1] LOG:  listening on IPv6 address "::", port 5432
>  pg-server_1  | 2020-11-21 12:53:14.263 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
>  pg-server_1  | 2020-11-21 12:53:14.323 UTC [26] LOG:  database system was shut down at 2020-11-21 12:52:12 UTC
>  pg-server_1  | 2020-11-21 12:53:14.343 UTC [1] LOG:  database system is ready to accept connections
>  pg-client_1  | ok! Postgres is available!
>  pg-client_1  | CREATE TABLE
>  pg-client_1  |        List of relations
>  pg-client_1  |  Schema | Name | Type  | Owner
>  pg-client_1  | --------+------+-------+-------
>  pg-client_1  |  public | test | table | admin
>  pg-client_1  | (1 row)
>  pg-client_1  |
>  pg-client_1  | INSERT 0 1
>  pg-client_1  |    c1
>  pg-client_1  | --------
>  pg-client_1  |  hello!
>  pg-client_1  | (1 row)
>  pg-client_1  |
- подключится к контейнеру с сервером с ноутбука
> Подключиться с ноутбука удалось, настроив правило брандмауэра gcp, разрешив внешние подключения на порт 5432 для диапазона адресов 0.0.0.0/0
> DBMS: PostgreSQL (ver. 13.1 (Debian 13.1-1.pgdg100+1))
> Case sensitivity: plain=lower, delimited=exact
> Driver: PostgreSQL JDBC Driver (ver. 42.2.5, JDBC4.2)
> Ping: 64 ms
> SSL: no
- удалить контейнер с сервером
> sudo docker-compose down
- создать его заново
> sudo docker-compose up
- подключится снова из контейнера с клиентом к контейнеру с сервером
- проверить, что данные остались на месте
> да, остались, так как используем volume
- оставляйте в ЛК ДЗ комментарии что и как вы делали и как боролись с проблемами