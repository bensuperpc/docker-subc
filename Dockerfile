ARG DOCKER_IMAGE=alpine:latest
FROM $DOCKER_IMAGE AS builder

RUN apk add --no-cache gcc make musl-dev git \
	&& git clone --recurse-submodules https://github.com/bensuperpc/subc.git
WORKDIR /subc

RUN ./configure \
	&& cd src \
	&& make \
	&& make test \
	&& make ptest \
	&& make systest \
	&& make libtest \
	&& make dirs \
	&& make install \
	&& make clean


ARG DOCKER_IMAGE=alpine:latest
FROM $DOCKER_IMAGE AS runtime

LABEL author="Bensuperpc <bensuperpc@gmail.com>"
LABEL mantainer="Bensuperpc <bensuperpc@gmail.com>"

ARG VERSION="1.0.0"
ENV VERSION=$VERSION

RUN apk add --no-cache gcc make

COPY --from=builder /u /u

ARG VERSION="1.0.0"
ENV VERSION=$VERSION

ENV PATH="/u/bin:${PATH}"

ENV CC=/u/bin/scc
WORKDIR /usr/src/myapp

RUN scc -h

CMD ["scc", "-h"]

LABEL org.label-schema.schema-version="1.0" \
	  org.label-schema.build-date=$BUILD_DATE \
	  org.label-schema.name="bensuperpc/docker-subc" \
	  org.label-schema.description="build subc compiler" \
	  org.label-schema.version=$VERSION \
	  org.label-schema.vendor="Bensuperpc" \
	  org.label-schema.url="http://bensuperpc.com/" \
	  org.label-schema.vcs-url="https://github.com/Bensuperpc/docker-subc" \
	  org.label-schema.vcs-ref=$VCS_REF \
	  org.label-schema.docker.cmd="docker build -t bensuperpc/subc -f Dockerfile ."
