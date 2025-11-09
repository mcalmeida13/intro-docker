from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello, Docker! Estou criando aqui um app em Flask para aprender Docker. Testando meu container. Agora testando Makefile. Quero ver a agora a versão 2.0"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
