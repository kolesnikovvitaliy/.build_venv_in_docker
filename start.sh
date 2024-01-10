#!/bin/bash
touch .env
FILE=$(ls ../.venv/lib/ | head -1);
echo PYTHON_VERSION=${FILE//[^0-9\.]/} > .env

echo Введите названия необходимых, библиотек через пробел: 
read 
echo NEW_LIBS=${REPLY} >> .env

docker-compose up --build && \
docker-compose down -v && \
rm .env
