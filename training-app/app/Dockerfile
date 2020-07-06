FROM golang:1.11-alpine as builder
WORKDIR /tmp
RUN apk add git upx --no-cache && \
    go get github.com/pwaller/goupx
COPY training-app.go .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o training-app -ldflags="-s -w" . && \
    goupx training-app

FROM alpine:3.9
RUN apk add curl --no-cache
COPY --from=builder /tmp/training-app .
CMD ["./training-app"]

# more info
# https://docs.docker.com/develop/develop-images/multistage-build/
# https://blog.filippo.io/shrink-your-go-binaries-with-this-one-weird-trick/
