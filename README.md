## 🚀 **Simple App Lifecycle with Docker**

We'll create a basic **Python Flask app**, containerize it using Docker, and walk through its lifecycle.

### **1️⃣ Development: Create the Application**

First, create a simple `app.py`:

```python
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello, Docker!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

And a `requirements.txt` file:

```
flask
```

---

### **2️⃣ Create a Dockerfile**

This defines how the app will be containerized.

```dockerfile
# Use an official Python image
FROM python:3.9

# Set working directory
WORKDIR /app

# Copy project files
COPY requirements.txt .
COPY app.py .

# Install dependencies
RUN pip install -r requirements.txt

# Expose the port the app runs on
EXPOSE 5000

# Run the application
CMD ["python", "app.py"]
```

---

### **3️⃣ Build the Docker Image**

Run the following command to build the Docker image:

```sh
docker build -t flask-app .
```

This creates an image named `flask-app`.

---

### **4️⃣ Run the Application in a Container**

Start a container from the image:

```sh
docker run -d -p 5000:5000 --name my-container flask-app
```

* `-d` → Runs in detached mode (in the background).
* `-p 5000:5000` → Maps container's port `5000` to host's port `5000`.
* `--name my-container` → Assigns a name to the running container.

Now, visit **[http://localhost:5000](http://localhost:5000)** in your browser. 🎉

---

### **5️⃣ Stop and Restart the Container**

To **stop** the running container:

```sh
docker stop my-container
```

To **restart** it:

```sh
docker start my-container
```

To **check running containers**:

```sh
docker ps
```

To **check all containers (including stopped ones)**:

```sh
docker ps -a
```

---

### **6️⃣ Remove the Container and Image (Cleanup)**

To remove the container:

```sh
docker rm my-container
```

To remove the image:

```sh
docker rmi flask-app
```

To remove all stopped containers:

```sh
docker container prune
```

---

## 🔄 **Full Lifecycle Recap**

1. **Develop** → Write the Python Flask app (`app.py`).
2. **Dockerize** → Create a `Dockerfile`.
3. **Build** → `docker build -t flask-app .`
4. **Run** → `docker run -d -p 5000:5000 --name my-container flask-app`
5. **Stop/Restart** → `docker stop/start my-container`
6. **Cleanup** → `docker rm my-container && docker rmi flask-app`

---

That's it! 🚀 This is a simple Docker-based **app lifecycle**.