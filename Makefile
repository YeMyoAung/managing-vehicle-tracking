run:
	docker compose up -d

stop:
	docker compose down

create_user:
	cd auth-service && make create_user;

test:
	cd auth-service && make test;
	cd common && make test;
	cd tracking-service && make test;
	cd vehicle-service && make test;

.PHONY: run stop
