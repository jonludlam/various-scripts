FROM ocaml/opam:ubuntu

RUN sudo apt-get update

RUN mkdir tmp/
RUN mkdir tmp/src/

COPY opam _tags Makefile update_xs_yum.install tmp/
COPY src/update_xs_yum.ml tmp/src/

# update the opam-repository
WORKDIR ./opam-repository
RUN git pull
RUN opam update

WORKDIR ../tmp

# check the OPAM-related files for errors
RUN opam lint

RUN opam pin add --no-action update_xs_yum .

RUN opam depext -y update_xs_yum

RUN opam install -y update_xs_yum
