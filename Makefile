APP_NAME=flask-app
PORT=5000
IMAGE_NAME=$(APP_NAME):latest
CONTAINER_NAME=$(APP_NAME)-container

.PHONY: build run stop clean logs

# 🏗️ Build the Docker image
build:
	docker build -t $(IMAGE_NAME) .

# 🚀 Run the Flask app in Docker
run:
	docker run -d -p $(PORT):5000 --name $(CONTAINER_NAME) $(IMAGE_NAME)

# ⏹️ Stop the running container
stop:
	docker stop $(CONTAINER_NAME) || true
	docker rm $(CONTAINER_NAME) || true

# 🗑️ Remove the Docker image
clean: stop
	docker rmi $(IMAGE_NAME) || true

# 📜 View logs from the container
logs:
	docker logs -f $(CONTAINER_NAME)
