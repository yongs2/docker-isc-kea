# About

-   This image contains the isc-kea dhcp server  ([https://github.com/isc-projects/kea/](https://github.com/isc-projects/kea/))

-   It uses mysql db

## Build

`docker build -t isc-kea -f Dockerfile .`

## Run

`docker run --rm --name kea --network=host isc-kea`
