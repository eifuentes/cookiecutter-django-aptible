# Django Aptible App Starter

A base Django application that uses [Aptible](https://www.aptible.com/deploy) as its PaaS, similar to Heroku and Render. This repo takes the liberty of setting up an opinionated structure with external plugins and packages for dev, test, and prod. See the `pyproject.toml` used by `poetry` and the `config.settings.INSTALLED_APPS` and `config.settings.MIDDLEWARE` for Django to learn more.

## Quick Start

Followed these [instructions](https://deploy-docs.aptible.com/docs/python-quickstart) from Aptible's documentation to launch this application.

Be sure to pay attention to `ALLOWED_HOSTS` and `CORS_ORIGIN_WHITELIST` in `config.settings.py` for your specific deployment topology.

### App Config Setup

Once you have the appliation and database setup, you must set these configuration settings through the aptible cli cmd `aptible config:set --app "$APP_HANDLE"` where you can replace `APP_HANDLE` with your known app name.

- `DJANGO_SECRET_KEY` a secret key you should keep safe and can generate using `python -c 'import secrets; print(secrets.token_urlsafe(38))'`
- `ALLOWED_HOSTS` a comma seperated string of allowed hosts. e.g. `".example.com,.anotherexample.com"`
- `DATABASE_URL` the full connection string for the postgresql database provided by Aptible. Find in database settings.

Below is a sample cmd assuming you have the variables above prepopulated.

```bash
aptible config:set --app "$APP_HANDLE" \
    "DATABASE_URL=$DATABASE_URL" \
    "ALLOWED_HOSTS=$ALLOWED_HOSTS" \
    "DJANGO_SECRET_KEY=$DJANGO_SECRET_KEY"
```

### Code Push

As a result of creating an Aptible application a remote git url should be provided to push your application code to for deployments. Assuming you have setup this correctly simply run the command below to setup the remote `aptible` and then deploy by pushing from your `main` branch.

```bash
git remote add aptible "$GIT_REMOTE"
git push aptible main
```

### Create Endpoint

Either using a custom domain or aptible's default configure your application to expose a public endpoint. See [this](https://deploy-docs.aptible.com/docs/expose-web-app) article to learn more. Regardless be sure to pass this domain to `ALLOWED_HOSTS` in your `config:set` cmd.

### Setup Super User

Be sure to ssh into a container as your application and run `python manage.py createsuperuser` to setup your admin user. You can use the cmd `aptible ssh --app "$APP_HANDLE"` to complete this setup step.

# Local

For local deployment, you can use the `Dockerfile.dev` and `docker-compose.yml` files to get up and running quickly.
Simply run `docker-compouse up -d --build` to download, build, and launch your django app alongside a postgresql instance to do local development. To shutdown just run `docker-compose down`. I periodically run `docker system prune` to clean up orphaned images and containers.

## Helpful Docker Compose Commands

```bash
# create migration
docker-compose exec web python manage.py makemigrations
# migrate
docker-compose exec web python manage.py migrate
# create super user
docker-compose exec web python manage.py createsuperuser
# populate dev db
docker-compose exec web python populate.py
# create passwords
docker-compose exec web python -c 'import secrets; print(secrets.token_urlsafe(38))'
# check deploy ready
docker-compose exec web python manage.py check --deploy
```

#### TODO
- convert to be a cookiecutter generator
