#!/usr/bin/env bash
set -e

wait_for_mongo() {
  local host="$1"
  local port="$2"
  local attempt

  for attempt in {1..60}; do
    if mongosh --host "$host" --port "$port" --quiet --eval 'db.adminCommand({ ping: 1 }).ok' >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done

  echo "Timed out waiting for MongoDB at ${host}:${port}" >&2
  return 1
}

wait_for_primary() {
  local host="$1"
  local port="$2"
  local attempt

  for attempt in {1..60}; do
    if mongosh --host "$host" --port "$port" --quiet --eval 'db.hello().isWritablePrimary' 2>/dev/null | grep -q '^true$'; then
      return 0
    fi
    sleep 2
  done

  echo "Timed out waiting for primary at ${host}:${port}" >&2
  return 1
}

wait_for_mongo configSrv 27017
mongosh --host configSrv --port 27017 <<'EOF'
rs.initiate(
  {
    _id : "config_server",
       configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27017" }
    ]
  }
);
EOF
wait_for_primary configSrv 27017

wait_for_mongo shard1 27018
wait_for_mongo shard1-replica2 27021
wait_for_mongo shard1-replica3 27022
mongosh --host shard1 --port 27018 <<'EOF'
rs.initiate(
    {
      _id : "shard1",
      members: [
        { _id : 0, host : "shard1:27018" },
        { _id : 1, host : "shard1-replica2:27021" },
        { _id : 2, host : "shard1-replica3:27022" }
      ]
    }
);
EOF
wait_for_primary shard1 27018

wait_for_mongo shard2 27019
wait_for_mongo shard2-replica2 27023
wait_for_mongo shard2-replica3 27024
mongosh --host shard2 --port 27019 <<'EOF'
rs.initiate(
  {
    _id : "shard2",
    members: [
      { _id : 0, host : "shard2:27019" },
      { _id : 1, host : "shard2-replica2:27023" },
      { _id : 2, host : "shard2-replica3:27024" }
    ]
  }
);
EOF
wait_for_primary shard2 27019

wait_for_mongo mongos_router 27020
mongosh --host mongos_router --port 27020 <<'EOF'
sh.addShard( "shard1/shard1:27018,shard1-replica2:27021,shard1-replica3:27022");
sh.addShard( "shard2/shard2:27019,shard2-replica2:27023,shard2-replica3:27024");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )

use somedb

for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})

db.helloDoc.countDocuments()
EOF
