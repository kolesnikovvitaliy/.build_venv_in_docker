ARG PYTHON_VERSION="${PYTHON_VERSION}"
###############################################
# Base Image
###############################################
FROM python:${PYTHON_VERSION}-slim-bullseye AS python-base
ENV PYTHONUNBUFFERED=1 \
    WORKDIR_PROJECT="/virtual_environment" \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_VERSION=1.7.0  \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    VENV_PATH="$WORKDIR_PROJECT/.venv"

# prepend poetry, venv to path
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

###############################################
# Builder VENV_POETRY
###############################################
LABEL maintainer="kolesnikovvitaliy <kolesnikovvitaliy@mail.ru>"

FROM python-base as builder-poetry
RUN apt-get update \
    && apt-get install -yq --no-install-recommends \
    gcc \
    curl \
    python3-dev \
    && apt-get update \
    && apt-get clean \
    && apt-get purge -y --auto-remove \ 
    && rm -rf /var/lib/apt/lists/*


# Install Poetry - respects $POETRY_VERSION & $POETRY_HOME
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -sSL https://install.python-poetry.org | POETRY_HOME=${POETRY_HOME} python3 - --version ${POETRY_VERSION} && \
    chmod a+x /opt/poetry/bin/poetry \
    && rm -rf ~/.cache/pypoetry/{cache,artifacts}

ARG NEW_LIBS="${NEW_LIBS}"
# We copy our Python requirements here to cache them
# and install only runtime deps using poetry
WORKDIR $WORKDIR_PROJECT
COPY pyproject.toml .
COPY .build_venv_in_docker/activate-venv.sh activate-venv.sh
RUN chmod +x activate-venv.sh
RUN poetry lock --no-update
RUN poetry install --only main --no-root --no-cache # respects \
    && rm -rf ~/.cache/pypoetry/{cache,artifacts} \
    && apt-get clean \
    && apt-get purge -y --auto-remove \ 
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT [ "/bin/bash", "activate-venv.sh" ]
CMD poetry add ${NEW_LIBS}