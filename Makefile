COMPOSE_FILE = srcs/docker-compose.yml
DIR_DATA = $(HOME)/data

all: prepare
	docker compose -f $(COMPOSE_FILE) up -d --build

prepare:
	mkdir -p $(DIR_DATA)/mariadb
	mkdir -p $(DIR_DATA)/wordpress

down:
	docker compose -f $(COMPOSE_FILE) down

clean: down
	docker system prune -af

fclean: clean
	rm -rf $(DIR_DATA)
	docker volume rm $$(docker volume ls -q) 2>/dev/null || true

re: fclean all

.PHONY: all prepare down clean fclean re
