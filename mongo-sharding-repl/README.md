# mongo-sharding-repl

Кластер состоит из двух шардов (`shard1`, `shard2`), каждый из трех реплик MongoDB.

## Как запустить

Запускаем mongodb и приложение. 
В [compose.yaml](../mongo-sharding/compose.yaml) также был добавлен `mongo-init` сервис для инициализации конфигурации, шардов и заполнения тестовыми данными. 
Поэтому для запуска нужно выполнить только:

```shell
docker compose up -d
```

## Проверка

После запуска можно проверить состав реплик и состояние шарда:

```shell
docker exec -it shard1 mongosh --port 27018
 > rs.status();
 > exit();
 ```

```shell
docker exec -it shard2 mongosh --port 27019
 > rs.status();
 > exit();
 ```

Проверить тестовые данные через роутер:

```shell
docker exec -it mongos_router mongosh --port 27020
 > use somedb;
 > db.helloDoc.countDocuments();
 > exit();
 ```