FROM clojure:lein-2.6.1

RUN apt-get update && apt-get install -y --no-install-recommends netcat

RUN groupadd -r pithos --gid=1000 && useradd -r -g pithos --home /pithos --uid=1000 pithos

RUN mkdir /etc/pithos /pithos /pithos/data && chown pithos:pithos -R /etc/pithos /pithos

USER pithos


ADD doc/ /pithos/doc/
ADD project.clj /pithos/
COPY target/*-standalone.jar /pithos/

ADD docker/docker-entrypoint.sh /docker-entrypoint.sh

WORKDIR /pithos
CMD ["bash", "/docker-entrypoint.sh"]
