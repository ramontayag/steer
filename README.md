# Steer

Lightning Network routing node management tool

## Prerequisites

- A LND node with gRPC port available
- [Elixir](https://elixir-lang.org/install.html#gnulinux)
- [npm](https://linuxconfig.org/install-npm-on-linux)
- A clone of this repository

### Certificates

Make sure you have a `~/.lnd` folder containing

- A certificate `~/.lnd/tls.cert`
- A readonly macaroon `~/.lnd/readonly.macaroon`

## Execution

From the project's root folder...

### Prepare the app and the database

```bash
mix deps.get
mix ecto.create
mix ecto.migrate
```

### Install assets

```bash
npm i --prefix assets
```

### Start steer

Usually LND's gRPC port is available from port 10009, so if running on
`localhost`, do that command to start Steer

```bash
NODE=localhost:10009 mix phx.server
```

### Run from sources

Browse port 4001 from the machine running Steer... can be accessed remotely.

If attempting to reach it from the same machine, simply browse to:

`http://localhost:4001`

## Production build

### Build

create a secret

```bash
mix phx.gen.secret
```

create a `.env` file in the root folder and make sure that those variables are configured

```ini
PORT=4000
MIX_ENV=prod
NODE=localhost:10009
SECRET_KEY_BASE=*** the secret created in the previous step ***
```

then, run this command.

```bash
export $(cat .env | xargs) && mix release
```

### Deploy

Copy file to the production server

```bash
scp _build/prod/steer-x.y.ztar.gz steer@prod-server:.
```

Then unpack the tarball wherever you like, such as /opt/steer-x.y.z and run this command

```bash
/opt/steer-x.y.z/bin/steer start
```