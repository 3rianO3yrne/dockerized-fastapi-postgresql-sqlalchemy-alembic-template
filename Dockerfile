# syntax=docker/dockerfile:1

# ============================
# Python Base Stage
# ============================
ARG PYTHON_VERSION=3.12
FROM python:${PYTHON_VERSION}-slim AS python-base

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    POETRY_VERSION=2.2.1 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv" 

ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# ============================
# Dependencies Base Stage
# ============================
FROM python-base AS dependencies-base

# Install dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get --no-install-recommends install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# use official poetry install method - respects $POETRY_VERSION & $POETRY_HOME
RUN curl -sSL https://install.python-poetry.org | python3 -

RUN poetry --version

# ============================
# Build Stage
# ============================
FROM dependencies-base AS build

WORKDIR $PYSETUP_PATH

COPY poetry.lock pyproject.toml ./

RUN --mount=type=cache,target=/root/.cache/pypoetry \
    poetry install --no-root

# ============================
# Final Stage
# ============================
FROM python-base AS final

WORKDIR /code

# Create a non-privileged user that the app will run under.
ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

# Copy virtual environment from build stage
COPY --from=build --chown=appuser:appgroup $PYSETUP_PATH $PYSETUP_PATH

# Switch to the non-privileged user to run the application.
USER appuser

# Copy the source code into the container.
COPY . .

EXPOSE 8000
ENTRYPOINT []

CMD ["fastapi", "run",  "app/main.py",  "--host", "0.0.0.0",  "--port", "8000"]