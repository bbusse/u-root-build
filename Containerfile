FROM golang:1.25 as builder

# Install git
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Clone u-root
WORKDIR /src
RUN git clone https://github.com/u-root/u-root.git
WORKDIR /src/u-root

# Build u-root for arm64
RUN GOARCH=arm64 GOOS=linux go build -o u-root-arm64 .

# Build initramfs
RUN GOARCH=arm64 GOOS=linux ./u-root-arm64 -build=bb -o initramfs-arm64.cpio

FROM scratch as export-stage
COPY --from=builder /src/u-root/u-root-arm64 /u-root-arm64
COPY --from=builder /src/u-root/initramfs-arm64.cpio /initramfs-arm64.cpio
