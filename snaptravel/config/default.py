import os

class DefaultConfig(object):
    REDIS_HOST = 'redis'
    DEBUG = False
    if os.getenv('REDIS_URL'):
        REDIS_URL = os.env('REDIS_URL')
    REDIS_PORT = 6379
    REDIS_DB = 0
    REDIS_MAX_CONNECTIONS = 5
    SECRET_KEY = os.getenv('SECRET_KEY', b'\x07X\x1e\x9bjE!\xcd\x1c\x7f\x82P\x87\xc5+\x11\xdd\x96\x1a!\xc3\t\r\xad')
    
    REDIS_HOST = 'localhost'
    REDIS_URL = 'redis://{0}:6379/{1}'.format(REDIS_HOST, REDIS_DB)

    if os.getenv('production'):
        flask_caching_config = {
            'CACHE_TYPE': 'redis',
            'CACHE_KEY_PREFIX': 'fcache',
            'CACHE_REDIS_HOST': REDIS_HOST,
            'CACHE_REDIS_PORT': '6379',
            'CACHE_REDIS_URL': REDIS_URL
        }
    else:
        flask_caching_config = {
            'CACHE_TYPE': 'simple'
        }
