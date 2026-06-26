"""
App de demostración del laboratorio Linux + AWS.

Sirve los mensajes almacenados en PostgreSQL (en db-server, DB remota y segmentada).
Las credenciales se leen de variables de entorno; NUNCA se escriben en el código.
"""
import os
import psycopg2
from flask import Flask, render_template

app = Flask(__name__)


def get_db_connection():
    """Abre una conexión a PostgreSQL usando variables de entorno."""
    return psycopg2.connect(
        host=os.environ.get("DB_HOST", "10.10.10.30"),
        port=os.environ.get("DB_PORT", "5432"),
        dbname=os.environ.get("DB_NAME", "labapp"),
        user=os.environ.get("DB_USER", "appuser"),
        password=os.environ["DB_PASSWORD"],  # obligatorio: sin valor por defecto
    )


@app.route("/")
def index():
    """Página principal: lista los mensajes de la base de datos."""
    try:
        conn = get_db_connection()
        with conn.cursor() as cur:
            cur.execute("SELECT id, texto, creado FROM mensajes ORDER BY id;")
            mensajes = cur.fetchall()
        conn.close()
        return render_template("index.html", mensajes=mensajes, error=None)
    except Exception as exc:
        # Si la DB no responde, mostramos el error en vez de romper la app.
        return render_template("index.html", mensajes=[], error=str(exc))


@app.route("/health")
def health():
    """Endpoint de salud para monitorización / balanceadores."""
    return {"status": "ok"}, 200


if __name__ == "__main__":
    # Solo para desarrollo local. En producción lo ejecuta gunicorn.
    app.run(host="127.0.0.1", port=8000)
