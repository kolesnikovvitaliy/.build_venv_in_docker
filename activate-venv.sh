#!/bin/sh

set -e

# activate our virtual environment here
. /virtual_environment/.venv/bin/activate
# Evaluating passed command:
exec "$@"