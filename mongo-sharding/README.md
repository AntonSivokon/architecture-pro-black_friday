# mongo-sharding

## Как запустить

Запускаем mongodb и приложение. 
В [compose.yaml](../mongo-sharding/compose.yaml) также был добавлен `mongo-init` сервис для инициализации конфигурации, шардов и заполнения тестовыми данными. 
Поэтому для запуска нужно выполнить только:

```shell
docker compose up -d
```

## Проверка

После запуска можно проверить шарды следующими командами:

```shell
docker exec -it shard1 mongosh --port 27018
 > use somedb;
 > db.helloDoc.countDocuments();
 > exit();
 ```

```shell
docker exec -it shard2 mongosh --port 27019
 > use somedb;
 > db.helloDoc.countDocuments();
 > exit();
 ```