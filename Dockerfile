FROM golang:1.17 AS builder
RUN go install -v -trimpath github.com/grpc-ecosystem/grpc-health-probe@v0.4.6
COPY . /build
WORKDIR /build
RUN make

FROM debian:bullseye
USER 0
COPY --from=builder /go/bin/grpc-health-probe /usr/bin/
COPY --from=builder /build/.bin/k8sxds /opt/k8sxds
RUN apt-get update \
	&& apt-get install -y ca-certificates tini \
	&& rm -rf /var/lib/apt/lists/* \
	&& useradd -M -u 1000 -s /bin/false app
USER 1000
WORKDIR /
CMD ["/opt/k8sxds"]
