FROM python:3.8.11-alpine3.14 as base

ENV PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONHASHSEED=random \
    RUN_PRESTART=0

# Builder step with dependencies compilation
FROM base as builder

ENV PIP_DEFAULT_TIMEOUT=100 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 
#    POETRY_VERSION=1.1.8

RUN apk add --no-cache gcc g++ libffi-dev musl-dev postgresql-dev openssl-dev python3-dev cargo
#RUN pip install poetry==$POETRY_VERSION
RUN python -m venv /venv

#COPY pyproject.toml poetry.lock ./
COPY requirements.txt ./
#RUN poetry export -f requirements.txt | /venv/bin/pip install -r /dev/stdin
RUN /venv/bin/pip install -r requirements.txt

# Final build
FROM base as final

WORKDIR /app

RUN apk add --no-cache libffi libpq openssl

COPY --from=builder /venv /venv

COPY . /app

ENTRYPOINT ["/venv/bin/uvicorn", "--host", "0.0.0.0", "docker_multiarch_builds:app"]

