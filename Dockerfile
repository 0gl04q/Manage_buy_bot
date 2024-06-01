###########
# BUILDER #
###########

FROM python:3.11.0-alpine

LABEL authors='0gl04q'

WORKDIR /home

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apk update
RUN apk add postgresql-dev gcc python3-dev musl-dev
RUN pip install --upgrade pip

COPY ./requirements.txt ./
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /home/wheels -r requirements.txt

#########
# FINAL #
#########

FROM python:3.11.0-alpine

RUN mkdir -p /home/manager

RUN addgroup -S manager && adduser -S manager -G manager

ENV HOME=/home/manager
ENV APP_HOME=/home/manager/web

RUN mkdir $APP_HOME
RUN mkdir $APP_HOME/static
RUN mkdir $APP_HOME/media

WORKDIR $APP_HOME

RUN apk update && add libpq
COPY --from=builder /home/wheels /wheels
COPY --from=builder /home/requirements.txt .
RUN pip install --no-cache /wheels/*

COPY ./entrypoint.prod.sh $APP_HOME

COPY . $APP_HOME

RUN chown -R manager:manager $APP_HOME

USER lending

RUN chmod +x /home/manager/web/entrypoint.prod.sh
ENTRYPOINT ["/home/manager/web/entrypoint.prod.sh"]