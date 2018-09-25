from flask import Flask, Response, jsonify, render_template, request
from config import default
from flask_caching import Cache

import grequests

cache = Cache(
    config=default.DefaultConfig.flask_caching_config
)


def create_app(settings_override=None):
    """
    Create a Flask application using the app factory pattern.
    :param settings_override: Override settings
    :return: Flask app
    """
    app = Flask(
        __name__,
        instance_relative_config=True,
    )
    app.config.from_object('config.default.DefaultConfig')
    cache.init_app(app)

    @app.route('/hc', methods=['GET'])
    def hc():
        """
        Parse the request parameters for search,
        pass them to the nested cached function and merge them.
        :return: Merged json response
        """
        return jsonify('OK !')

    @app.route('/search', methods=['POST'])
    def search():
        """
        Parse the request parameters for search,
        pass them to the nested cached function and merge them.
        :return: Merged json response
        """
        request_json = request.get_json()
        city = request_json['city']
        checkin = request_json['checkin']
        checkout = request_json['checkout']


        @cache.memoize(timeout=300)
        def _search(city, checkin, checkout): 
            """
            Setup a gen expression to be mapped by grequests,
            :return: Union of id of responses with snaptravel prices
            """
            rs = (
                    grequests.post('https://experimentation.getsnaptravel.com/interview/hotels',
                    data={
                        'city': city,
                        'checkin': checkin,
                        'checkout': checkout,
                        'provider': provider,
                    }
                ) for provider in ['snaptravel', 'retail']
            )
            responses = grequests.map(rs)
            responses = [response.json() for response in responses]
            merged_response = merge_search_responses(responses)
            return merged_response

        response = _search(city, checkin, checkout)
        return jsonify(response)

    return app


def merge_search_responses(responses):
    """
    Union two hotel search responses, the first of which is 
    from snaptravel, the other which is a third party response.
    :return: Union of responses
    """
    snaptravel_hotels = responses[0]['hotels']
    retail_hotels = responses[1]['hotels']
    snaptravel_hotel_map = {i['id']:i for i in snaptravel_hotels}
    retail_hotel_map = {i['id']:i for i in retail_hotels}
    common_ids = {i for i in snaptravel_hotel_map if i in retail_hotel_map}

    our_response = []
    for hotel_id in common_ids:
        price_object = {
            'snaptravel': snaptravel_hotel_map[hotel_id]['price'],
            'retail': retail_hotel_map[hotel_id]['price'],
        }
        this_hotel = snaptravel_hotel_map[hotel_id]
        this_hotel['price'] = price_object
        our_response.append(this_hotel)
    return our_response
