FROM buildpack-deps:buster as builder

RUN curl https://bazel.build/bazel-release.pub.gpg | apt-key add - \
    && echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list

RUN apt-get update && apt-get install -y \
    bazel \
    libgflags-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV CC=/usr/bin/gcc

ARG GRPC_VERSION="v1.31.0"
RUN git clone -b $GRPC_VERSION https://github.com/grpc/grpc \
    && cd grpc \
    && git submodule update --init \
    && bazel build //test/cpp/util:grpc_cli

FROM debian:buster-slim

COPY --from=builder /grpc/bazel-bin/test/cpp/util/grpc_cli /usr/local/bin/grpc_cli

ENTRYPOINT ["grpc_cli"]
