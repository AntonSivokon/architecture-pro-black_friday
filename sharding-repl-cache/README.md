# sharding-repl-cache

## Как запустить

Запускаем mongodb и приложение. 
В `compose.yaml` сервис `mongo-init` инициализирует конфигурацию MongoDB, шарды и тестовые данные.
Поэтому для запуска нужно выполнить только:

```shell
docker compose up -d
```

## Проверка

После запуска можно проверить состав реплик и состояние шарда:

```shell
docker exec -it shard1 mongosh --port 27018
rs.status()
exit
```

```shell
docker exec -it shard2 mongosh --port 27019
rs.status()
exit
```

Проверить тестовые данные через роутер:

```shell
docker exec -it mongos_router mongosh --port 27020
use somedb
db.helloDoc.countDocuments()
exit
```

Получить список пользователей через API. Повторный вызов обращается к `redis` и выполняется за ~ 10 ms.

```shell
curl --include http://localhost:8080/helloDoc/users
```