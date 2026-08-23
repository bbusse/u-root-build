FROM golang:1.25 as builder

# Install git
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Clone u-root
WORKDIR /src
RUN git clone https://github.com/u-root/u-root.git
WORKDIR /src/u-root

# TARGETARCH is set by the builder from --platform, so GOARCH always matches
# the platform this stage runs on. That keeps the initramfs step below native:
# it executes the binary just built, which would need emulation otherwise.
ARG TARGETARCH

# Build u-root
RUN GOARCH=${TARGETARCH} GOOS=linux go build -o u-root-${TARGETARCH} .

# Build initramfs
RUN GOARCH=${TARGETARCH} GOOS=linux ./u-root-${TARGETARCH} -build=bb -o initramfs-${TARGETARCH}.cpio

FROM scratch as export-stage
ARG TARGETARCH
COPY --from=builder /src/u-root/u-root-${TARGETARCH} /u-root-${TARGETARCH}
COPY --from=builder /src/u-root/initramfs-${TARGETARCH}.cpio /initramfs-${TARGETARCH}.cpio
