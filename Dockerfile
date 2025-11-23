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
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    pipx \
    && rm -rf /var/lib/apt/lists/*

RUN pipx install "poetry==$POETRY_VERSION"

# ---- build ----
FROM base AS build

WORKDIR $PYSETUP_PATH

COPY poetry.lock pyproject.toml ./

RUN --mount=type=cache,target=/root/.cache/pypoetry \
    poetry install --no-root

COPY . .

# ---- Final Image ----
FROM python:${PYTHON_VERSION}-slim AS final

ENV VENV_PATH="/opt/pysetup/.venv" \
    PATH="/opt/pysetup/.venv/bin:$PATH"

# Create a non-privileged user that the app will run under.
RUN groupadd -g 1001 appgroup && \
    useradd -u 1001 -g appgroup -m -d /home/appuser -s /bin/bash appuser

COPY --from=build --chown=appuser:appgroup /opt/pysetup/.venv /opt/pysetup/.venv
COPY --from=build --chown=appuser:appgroup /opt/pysetup/ ./

# Switch to the non-privileged user to run the application.
USER appuser

# Copy the source code into the container.
COPY . .

# Expose the port that the application listens on.
EXPOSE 8000

# Run the application.
# ENTRYPOINT ["/bin/bash", "-c", "echo 'hello'; sleep infinity"]

# ENTRYPOINT ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]

CMD ["python", "-m", "fastapi", "run", "app/main.py", "--host", "0.0.0.0", "--port", "8000" ]