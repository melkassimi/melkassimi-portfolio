# FROM ubuntu:18.04
#
# # apt-get and system utilities
# RUN apt-get update && apt-get install -y \
#     curl apt-utils apt-transport-https debconf-utils gcc build-essential g++\
#     && rm -rf /var/lib/apt/lists/*
#
# RUN apt-get update \
#     && apt-get upgrade -y \
#     && apt-get install -y \
#     build-essential \
#     ca-certificates \
#     gcc \
#     git \
#     libpq-dev \
#     make \
#     python-pip \
#     python3.6\
#     ssh \
#     && apt-get autoremove \
#     && apt-get clean
#
# COPY requirements/* /app/requirements/
#
# RUN pip install --upgrade pip
# RUN pip install -r /app/requirements/dev.txt
#
# RUN apt-get update \
#     && DEBIAN_FRONTEND=noninteractive apt-get install -y locales \
#     && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
#     && dpkg-reconfigure --frontend=noninteractive locales \
#     && update-locale LANG=en_US.UTF-8
# ENV LANG en_US.UTF-8
# ENV LC_ALL en_US.UTF-8
#
# WORKDIR /app
# COPY . /app
#
# RUN chmod go+w /app
#
# RUN groupadd -g 999 appuser && \
#     useradd -r -u 999 -g appuser appuser
# USER appuser
#
# EXPOSE 5001


FROM python:3.6

COPY requirements/* /app/requirements/

RUN apt-get update

RUN pip install --upgrade pip \
    && pip install -r /app/requirements/dev.txt

WORKDIR /app
COPY . /app

ENV FLASK_APP="webapp_cv.app_file:app" \
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

# CMD ["gunicorn", "-b", "0.0.0.0:5888", "webapp_cv.app_file:app",  "-t", "6000"]
CMD /app/docker/docker-ci.sh