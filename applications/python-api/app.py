from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from datetime import datetime
import os

app = Flask(__name__)
CORS(app)

# Rate limiting
limiter = Limiter(
    app,
    key_func=get_remote_address,
    default_limits=["100 per minute"]
)

@app.route('/')
def home():
    return jsonify({
        'message': 'Hello World from Python Flask API!',
        'version': '1.0.0',
        'technology': 'Python Flask',
        'timestamp': datetime.utcnow().isoformat()
    })

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'version': '1.0.0'
    })

@app.route('/api/hello', methods=['GET'])
def hello_get():
    name = request.args.get('name', 'World')
    return jsonify({
        'message': f'Hello, {name}!',
        'technology': 'Python Flask',
        'timestamp': datetime.utcnow().isoformat()
    })

@app.route('/api/hello', methods=['POST'])
def hello_post():
    data = request.get_json() or {}
    name = data.get('name', 'World')
    return jsonify({
        'message': f'Hello, {name}! (POST request)',
        'technology': 'Python Flask',
        'timestamp': datetime.utcnow().isoformat(),
        'received': data
    })

@app.errorhandler(404)
def not_found(error):
    return jsonify({
        'error': 'Not Found',
        'message': 'The requested resource was not found',
        'path': request.path
    }), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({
        'error': 'Internal Server Error',
        'message': 'Something went wrong!'
    }), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5001))
    debug = os.environ.get('FLASK_ENV') == 'development'
    app.run(host='0.0.0.0', port=port, debug=debug)