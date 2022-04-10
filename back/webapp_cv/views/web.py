from flask import Blueprint


web = Blueprint('web', __name__, static_folder='../../../front')


@web.route('/index')
def home():
    return web.send_static_file('index.html')
