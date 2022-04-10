FROM node:11.9

WORKDIR /app

COPY package.json /app/
COPY package-lock.json /app/
COPY bower.json /app/
COPY .bowerrc /app/

RUN npm install -g bower gulp && bower install && npm install


COPY ./ /app/

RUN gulp
