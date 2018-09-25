import os
import tempfile

import pytest

from snaptravel.app import create_app


class TestHealthCheck(object):
    def test_health_check(self):
        """Test that the health check endpoint works"""
        test_params =  {
            'DEBUG': False,
            'TESTING': True
        }

        app = create_app(settings_override=test_params).test_client

        with app() as c:
            response = c.get('/hc')
        print(response)
        assert response.status_code == 200
        assert response.json == 'OK !'
