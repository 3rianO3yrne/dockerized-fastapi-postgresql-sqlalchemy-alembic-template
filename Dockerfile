# syntax=docker/dockerfile:1

# ---- Base ----
ARG PYTHON_VERSION=3.12
FROM python:${PYTHON_VERSION}-slim AS base

ENV POETRY_VERSION=2.2.1 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    POETRY_CACHE_DIR="/cache/pypoetry" \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv" \
    PIPX_HOME="/opt/pipx"
    
# ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$POETRY_CACHE_DIR/bin:$PATH"
ENV PATH="/root/.local/bin:${PATH}"

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    pipx \
    && rm -rf /var/lib/apt/lists/*

RUN pipx install "poetry==$POETRY_VERSION" --global

# ---- build ----
FROM base AS build

WORKDIR $PYSETUP_PATH

COPY poetry.lock pyproject.toml ./

RUN --mount=type=cache,target=$PATH \
    poetry install --no-root

COPY . .

# ---- Final Image ----
FROM python:${PYTHON_VERSION}-slim AS final

# Create a non-privileged user that the app will run under.
RUN groupadd -g 1001 appgroup && \
    useradd -u 1001 -g appgroup -m -d /home/appuser -s /bin/bash appuser

WORKDIR /app

COPY --from=build --chown=appuser:appgroup /opt/pysetup/.venv /opt/pysetup/.venv
COPY --from=build --chown=appuser:appgroup /opt/pysetup/ ./

# Switch to the non-privileged user to run the application.
USER appuser

# Copy the source code into the container.
COPY . .

ENV PATH="/app/.venv/bin:$PATH"
EXPOSE 8000
ENTRYPOINT []

CMD ["fastapi", "run",  "src/app/main.py",  "--host", "0.0.0.0",  "--port", "8000"]