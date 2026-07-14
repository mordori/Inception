COMPOSE_FILE = srcs/docker-compose.yml
DIR_DATA = $(HOME)/data

# -f = file; up = create and start networks, volumes, and containers; -d = detached, terminal control;
# --build = build images from scratch instead of using caches
all: prepare
	docker compose -f $(COMPOSE_FILE) up -d --build

prepare:
	mkdir -p $(DIR_DATA)/mariadb
	mkdir -p $(DIR_DATA)/wordpress

# down = stops and removes running containers and temporary networks they use. Does not delete volumes
down:
	docker compose -f $(COMPOSE_FILE) down

# -f = force; -a = all; prune = delete unused containers, networks, and images
clean: down
	docker system prune -af

# Deletes data directory from the host machine and tells docker to forget them with a list command substitution
# || true is needed in the case there are no volumes to delete. rm would exit with a failure and crash make
fclean: clean
	rm -rf $(DIR_DATA)
	docker volume rm $$(docker volume ls -q) 2>/dev/null || true

re: fclean all

.PHONY: all prepare down clean fclean re
