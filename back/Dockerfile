FROM python:3.6

COPY requirements/* /app/requirements/


RUN apt-get update

RUN pip install --upgrade pip \
    && pip install -r /app/requirements/dev.txt

WORKDIR /app
COPY . /app

ENV FLASK_APP="app_file:app" \
    FLASK_ENV=production \
    SUPERSET_PORT=5888

RUN chmod go+w /app

COPY ./docker/run-server.sh /usr/bin/
RUN chmod a+x /usr/bin/run-server.sh

RUN groupadd -g 999 appuser && \
    useradd -r -u 999 -g appuser appuser

RUN chmod go+x /app/docker/*

USER appuser

EXPOSE 5888

CMD /app/docker/docker-ci.sh