from flask import Flask
import logging

from webapp_cv.config import portefolio
from webapp_cv.views import web

logger = logging.getLogger(__name__)


def create_flask_app() -> Flask:
    new_app = Flask(__name__, static_folder='../front/assets')
    try:
        new_app.config.from_object(portefolio)
        return new_app
    except Exception as ex:
        logger.exception("Failed to create app")
        raise ex


app = create_flask_app()
app.register_blueprint(web.web)
