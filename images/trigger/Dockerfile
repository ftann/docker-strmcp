FROM golangci/golangci-lint:v1.54.2 AS lint
WORKDIR /go/src/app
COPY . .
RUN golangci-lint run

FROM golang:1.21 as build
WORKDIR /go/src/app
COPY . .
RUN go mod download
RUN CGO_ENABLED=0 go build -trimpath -o /go/bin/trigger ./cmd/...

FROM gcr.io/distroless/static-debian12
EXPOSE 8080
COPY --from=build /go/bin/trigger /
CMD ["/trigger"]
