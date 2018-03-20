# Infrastructure takehome demo

This is our task for potential new infrastructure engineers. We expect this task to take less than a few hours of work.

Please fork this repo and make a starting commit with the message 'start'.
Commit your finished code and push to your forked repo when you are finished. Please link your hosted service endpoint here. Thanks 😄

## TODO

Implement a simple backend web api that handles a HTTP POST request and returns a json response.

**Step 1**

The api should take the following fields
- City string input
- Checkin string input
- Checkout string input

The 3 inputs will be string inputs. You can assume that these inputs are always valid.

Here's a sample request in cURL:

```
curl -X POST \
  https://your-endpoint.amazonaws.com/search \
  -H 'content-type: application/json' \
  -d '{
  "city": "Las Vegas",
  "checkin": "2018-05-27",
  "checkout": "2018-05-28"
}'

```

**Step 2**

To serve the request, the server should make **2 HTTP POST requests** in parallel to 'https://experimentation.getsnaptravel.com/interview/hotels' with the following request body

```
{
  city : city_string_input,
  checkin : checkin_string_input,
  checkout : checkout_string_input,
  provider : 'snaptravel'
}
```

1) The above returns SnapTravel rates for hotels in the city

```
{
  city : city_string_input,
  checkin : checkin_string_input,
  checkout : checkout_string_input,
  provider : 'retail'
}
```

2) The above returns Hotels.com rates for hotels in the city

The responses will be in json and each response will have an array of hotels and prices.
```
[{
  id : 12,
  hotel_name : 'Center Hilton',
  num_reviews : 209,
  address : '12 Wall Street, Very Large City',
  num_stars : 4,
  amenities : ['Wi-Fi', 'Parking'],
  image_url : 'https://images.trvl-media.com/hotels/1000000/20000/19600/19558/19558_410_b.jpg',
  price : 132.11
},
...
]
```

Note: You **must** cache these responses (assume the endpoint is expensive to call) in whatever way that seems fit using some **external datastore** that seems fit (eg, Redis, Postgres, Mongo, etc)

**Step 3**

After both these calls have returned take **only** the hotels that appear in both the responses and return a json response with the following format:

```
[{
  id : 12,
  hotel_name : 'Center Hilton',
  num_reviews : 209,
  address : '12 Wall Street, Very Large City',
  num_stars : 4,
  amenities : ['Wi-Fi', 'Parking'],
  image_url : 'https://images.trvl-media.com/hotels/1000000/20000/19600/19558/19558_410_b.jpg',
  price: {
    snaptravel : 112.33,
    retail : 132.11
  }
},
...
]
```

For example, if the first call returned hotels with id [10,12] with SnapTravel prices 192.34 and 112.33 and the second call returned hotels [12,13] with Hotels.com prices 132.11 and 321.62 respectively, you would only render hotel 12 in the list with a SnapTravel price of 112.33 and a Hotels.com price of 132.11


**Step 4**

Host this api on AWS using the given credentials. You can choose any of the services and components offered by Amazon Web Services. Optionally, if you are not fimilar with aws but like some other cloud provider, feel free to implement it there. For this take home assignment, we have created a user for you that allows you to access AWS in a specific region.

**Mandatory requirements**:

-  Be highly available (no downtime during deploys)
-  Has the ability to rollback to previous versions

**Bonus points**:
- Self Healing (automatically restart if a server is down)
- Automatic scaling based on load
- Multi-cluster/Multi-zone setup