FROM python:3.8

LABEL maintainer="yourname <yourname@co.com>"

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# System prerequisites
RUN apt-get update \
 && apt-get -y install build-essential libpq-dev \
 && rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /code

# Install Poetry
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | POETRY_HOME=/opt/poetry python && \
    cd /usr/local/bin && \
    ln -s /opt/poetry/bin/poetry && \
    poetry config virtualenvs.create false

# Copy poetry.lock* in case it doesn't exist in the repo
COPY pyproject.toml poetry.lock* /code/

# Allow installing dev dependencies to run tests
ARG INSTALL_DEV=false

# Install dependencies
RUN bash -c "if [ $INSTALL_DEV == 'true' ] ; then poetry install --no-root ; else poetry install --no-root --no-dev ; fi"

# Copy project and setup python path
COPY . /code/
ENV PYTHONPATH=/code

# Collect assets. This approach is not fully production-ready, but
# will help you experiment with Aptible Deploy before bothering with static
# files.
# Review http://go.aptible.com/assets for production-ready advice.
RUN set -a \
 && . ./.aptible.env \
 && python manage.py collectstatic

EXPOSE 8000

CMD ["gunicorn", "--access-logfile=-", "--error-logfile=-", "--bind=0.0.0.0:8000", "--workers=3", "config.wsgi:application"]
