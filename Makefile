all:
	bundle install

docker:
	docker build . -t gen_temp_tower 
	docker run -v `pwd`/profiles:/root/profiles -v `pwd`/temp_tower_output:/root/temp_tower_output gen_temp_tower
