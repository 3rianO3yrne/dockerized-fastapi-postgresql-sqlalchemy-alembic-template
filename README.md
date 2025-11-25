# dockerized-fastapi-postgresql-sqlalchemy-alembic-template
Starter template for creating a Dockerized, FastApi, PostgreSQL project utilizing SQLAlchemy and Alembic DB migrations


### Requirements

* Docker Desktop
* Connection to the internet

### Running the application

* clone repo
Install dependencies and start server with docker compose.

See [README.Docker.md](README.Docker.md) for more information.

Install dependencies and start server:

```bash
docker compose up --build
```

Run server with hot reloading:

```bash
docker compose up --watch
```

* visit the server: [http://0.0.0.0:8000/](http://0.0.0.0:8000/)
