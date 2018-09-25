import os

class DefaultConfig(object):
    DEBUG = False   
    REDIS_PORT = 6379
    REDIS_DB = 0
    REDIS_MAX_CONNECTIONS = 5    
    REDIS_HOST = os.getenv('REDIS_HOST', 'localhost')
    REDIS_URL = os.getenv('REDIS_URL', 'redis://{0}:6379/{1}'.format(REDIS_HOST, REDIS_DB))

    if os.getenv('production'):
        flask_caching_config = {
            'CACHE_TYPE': 'redis',
            'CACHE_KEY_PREFIX': 'fcache',
            'CACHE_REDIS_PORT': '6379',
            'CACHE_REDIS_URL': REDIS_URL
        }
    else:
        flask_caching_config = {
            'CACHE_TYPE': 'simple'
        }
