
FROM debian:buster as builder

# Build tk4 docker with jcc and rdrprep installed
RUN apt-get update && apt-get install -yq git build-essential
WORKDIR /
RUN git clone --depth 1 https://github.com/mvslovers/jcc.git
RUN git clone --depth 1 https://github.com/mvslovers/rdrprep.git
WORKDIR rdrprep
RUN make && make install


# Deploy
FROM debian:buster
LABEL version="0.1"
LABEL description="Current jcc and rdrprep"
WORKDIR /
RUN apt-get update && apt-get install -yq curl netcat git make
WORKDIR /
COPY --from=builder /jcc/ /jcc/
COPY --from=builder /usr/local/bin/rdrprep /usr/local/bin/rdrprep
ENV PATH="/jcc:${PATH}"
WORKDIR /
ADD test.c /jcc
ADD jccc /jcc/jccc
RUN chmod +x /jcc/jccc
RUN jcc -I/jcc/include -o /jcc/test.c
VOLUME ["/project"]
