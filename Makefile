.PHONY: build
build:
	docker build --target builder -t isc-kea-builder .
	docker build -t isc-kea -f Dockerfile .

.PHONY: run
run:
	docker run --rm --name kea --network=host isc-kea || :

.PHONY: exec
exec:
	docker exec -it kea /bin/bash

.PHONY: stop
stop:
	docker stop kea || :

.PHONY: logs
logs:
	docker logs -f kea || :
