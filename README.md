# Задания 1- 6

На [итоговой схеме](mobile_world_black_friday.drawio) показано:
1. шардирование и репликация узлов MongoDb;
2. взаимодействие сервиса с кэшом Redis;
3. маршрутизация через API-Gateway;
4. использование CDN для получения статического контента пользователем.

Итоговый docker-compose расположен в директории `sharding-repl-cache`.

## Как запустить

Запустить [compose.yaml](sharding-repl-cache/compose.yaml).

В `compose.yaml` сервис `mongo-init` инициализирует конфигурацию MongoDB, шарды и тестовые данные.
Поэтому для запуска нужно выполнить только:

```shell
docker compose up -d
```

## Как проверить

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

# Задания 7 - 10

Задания описаны [единым архитектурным документом](mobile_world_architecture_solutions.md) в формате Markdown.