# Stellar Bridge Docker image

This is a simple docker image for [Stellar Bridge](https://github.com/stellar/bridge-server) application for Stellar network.

It is meant to be used in Helm chart-managed Kubernetes deployment.

## How to get it

It is a public image. Run the following command to get it locally:

```shell
docker pull mobiusnetwork/stellar-brigde:0.0.31
```

## How to use

This is a very basic image of Stellar Bridge server. No `confd` or other templating engines are embedded into it. So, basically, you should provide it with a valid config file.

The config file should be placed to `/etc/bridge.cfg` inside a container by default. You can change the location by passing `BRIDGE_CONFIG_FILE` variable to the container.

Example(let's assume it is called `bridge.cfg`):

```
# Bridge server bridge.cfg example

port = 8006
horizon = "https://horizon-testnet.stellar.org"
network_passphrase = "Test SDF Network ; September 2015"
api_key = ""
mac_key = ""

[[assets]]
code="USD"
issuer="GCOGCYU77DLEVYCXDQM7F32M5PCKES6VU3Z5GURF6U6OA5LFOVTRYPOX"

[[assets]]
code="EUR"
issuer="GCOGCYU77DLEVYCXDQM7F32M5PCKES6VU3Z5GURF6U6OA5LFOVTRYPOX"

#Listen for XLM Payments
[[assets]]
code="XLM"

[database]
type = "mysql"
url = "root:@/gateway_test?parseTime=true"

[accounts]
authorizing_seed = "SDMRITVCFY6IIK6H5DXIVUOL342YFVE3VFOGVF3D7XXHGITPX4ABMYXR" # GCAW3TYUYGCNODKO4QKMD6PSH5GP3KES4GWGVFCKZ6DD6EJUDUQ77BO
receiving_account_id = "GAJBUSUTGTS3MAU2KP6MWJFJACDN4ZJ5YCET23U6XYZZ7WUD2OYQQUR2"

[callbacks]
receive = "http://localhost:8002/receive"
error = "http://localhost:8002/error"
```

Spinning up a container is as simple as:

```shell
docker run -v ./bridge.cfg:/etc/bridge.cfg mobiusnetwork/stellar-bridge:0.0.31
```

## DB initialization

This image can automatically run DB migrations for PostgreSQL DB.

Running automatic migrations for MySQL is not supported because MySQL client does not accept [DSN style connection string](https://github.com/go-sql-driver/mysql#dsn-data-source-name) as in Bridge server's config file. To fix that we need to parse it or use custom go-based MySQL client and this is out of scope for this image for now.

You can still use MySQL db with this image if you disable automatic DB migration by setting variable `BRIDGE_SKIP_DB_INIT=true`
