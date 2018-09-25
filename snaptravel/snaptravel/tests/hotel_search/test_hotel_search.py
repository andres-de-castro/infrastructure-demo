import os
import tempfile

import pytest

from snaptravel.app import create_app
from snaptravel.app import merge_search_responses

from snaptravel.tests.hotel_search.stubbed_responses import RESPONSE, MERGED


class TestHotelSearch(object):
    def test_merge_search_responses(self):
        assert merge_search_responses(RESPONSE) == MERGED


    def test_hotel_search(self):
        """ Test that hotel search works """
        test_params =  {
            'DEBUG': False,
            'TESTING': True
        }

        app = create_app(settings_override=test_params).test_client
        params = {
            "city": "Las Vegas",
            "checkin": "2018-05-27",
            "checkout": "2018-05-28"
        }

        with app() as c:
            response = c.post('/search', json=params)

        assert response.status_code == 200
        assert isinstance(response.json, list)
        assert len(response.json) > 0
