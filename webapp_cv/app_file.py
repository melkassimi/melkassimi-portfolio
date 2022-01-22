from flask import Flask, render_template
import logging
from flask_migrate import Migrate
from pathlib import Path

from config import portefolio
logger = logging.getLogger(__name__)


def create_flask_app() -> Flask:

    new_app = Flask(__name__, static_url_path="")

    try:
        new_app.config.from_object(portefolio)
        return new_app

    except Exception as ex:
        logger.exception("Failed to create app")
        raise ex


app = create_flask_app()

# app.run(host='0.0.0.0', port=5888)


@app.route('/index')
def index():
    return render_template('index.html')