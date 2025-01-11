all: build up

re: down all

#nuke:
#	docker stop $(docker ps -qa); docker rm $(docker ps -qa); docker rmi -f $(docker images -qa); \
#	   	docker volume rm $(docker volume ls -q); docker network rm $(docker network ls -q) 
#reclaim: 
#	docker system prune -a --volumes

build:
	mkdir -p ${HOME}/.docker/OWM/{DB,PBF,MOD}
	@docker-compose -f srcs/compose.yaml build --progress plain 
up:
	@docker-compose -f srcs/compose.yaml up -d --remove-orphans
down:
	@docker-compose -f srcs/compose.yaml down
ps:
	@docker-compose -f srcs/compose.yaml ps -a 
log:
	@make ps | docker-compose -f srcs/compose.yaml logs  
