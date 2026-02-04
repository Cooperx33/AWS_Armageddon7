# Lab1A/1a_user_data.sh
# User data script for EC2 instance in Lab 1A.
  # Simple Flask app that uses Secrets Manager for DB credentials and reads/writes to RDS.
  # Endpoints:
  #   /init
  #   /add?note=...
  #   /list
  app_user_data = <<-EOT
    #!/bin/bash
    set -euo pipefail

    dnf update -y
    dnf install -y python3 python3-pip mysql

    mkdir -p /opt/labapp
    cat > /opt/labapp/app.py <<'PY'
    import json
    import os
    from datetime import datetime

    import boto3
    import pymysql
    from flask import Flask, request

    REGION = os.environ.get("AWS_REGION", "us-east-2")
    SECRET_ID = os.environ.get("SECRET_ID", "lab/rds/mysql")

    app = Flask(__name__)

    def get_secret():
      client = boto3.client("secretsmanager", region_name=REGION)
      resp = client.get_secret_value(SecretId=SECRET_ID)
      return json.loads(resp["SecretString"])

    def get_conn():
      s = get_secret()
      return pymysql.connect(
        host=s["host"],
        user=s["username"],
        password=s["password"],
        database=s["dbname"],
        port=int(s["port"]),
        connect_timeout=5,
        autocommit=True,
      )

    @app.get("/")
    def home():
      return (
        "EC2 → RDS Integration Lab\\n"
        "Try:\\n"
        "  /init\\n"
        "  /add?note=cloud_labs_are_real\\n"
        "  /list\\n"
      ), 200, {"Content-Type": "text/plain; charset=utf-8"}

    @app.get("/init")
    def init_db():
      with get_conn() as conn:
        with conn.cursor() as cur:
          cur.execute(
            "CREATE TABLE IF NOT EXISTS notes ("
            " id INT AUTO_INCREMENT PRIMARY KEY,"
            " note VARCHAR(255) NOT NULL,"
            " created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
            ")"
          )
      return "OK: initialized", 200, {"Content-Type": "text/plain; charset=utf-8"}

    @app.get("/add")
    def add_note():
      note = request.args.get("note", "").strip()
      if not note:
        return "ERROR: provide ?note=...", 400, {"Content-Type": "text/plain; charset=utf-8"}
      with get_conn() as conn:
        with conn.cursor() as cur:
          cur.execute("INSERT INTO notes(note) VALUES (%s)", (note,))
      return f"OK: inserted '{note}'", 200, {"Content-Type": "text/plain; charset=utf-8"}

    @app.get("/list")
    def list_notes():
      with get_conn() as conn:
        with conn.cursor() as cur:
          cur.execute("SELECT id, note, created_at FROM notes ORDER BY id DESC LIMIT 50")
          rows = cur.fetchall()
      out = ["id\\tnote\\tcreated_at"]
      for r in rows:
        out.append(f"{r[0]}\\t{r[1]}\\t{r[2]}")
      return "\\n".join(out) + "\\n", 200, {"Content-Type": "text/plain; charset=utf-8"}

    if __name__ == "__main__":
      app.run(host="0.0.0.0", port=80)
    PY

    pip3 install --no-cache-dir flask pymysql boto3

    cat > /etc/systemd/system/labapp.service <<'UNIT'
    [Unit]
    Description=EC2 RDS Integration Lab App (Flask)
    After=network-online.target
    Wants=network-online.target

    [Service]
    Type=simple
    Environment=AWS_REGION=${var.aws_region}
    Environment=SECRET_ID=lab/rds/mysql
    ExecStart=/usr/bin/python3 /opt/labapp/app.py
    Restart=always
    RestartSec=2

    [Install]
    WantedBy=multi-user.target
    UNIT

    systemctl daemon-reload
    systemctl enable --now labapp
  EOT
--- IGNORE ---