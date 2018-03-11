# Infrastructure takehome demo

This is our task for potential new infrastructure engineers. We expect this task to take less than a few hours of work.

Please fork this repo and make a starting commit with the message 'start'.
Commit your finished code and push to your forked repo when you are finished. Thanks 😄

## TODO

Implement a simple backend web api that serves json. Please note that you must make a web server (eg, Express, Flask, Rails, etc), not just a pure front-end (browser based) app.

**Step 1**

The api should be designed to have the following fields
- City string input
- Checkin string input
- Checkout string input

The 3 inputs will be string inputs. You can assume that these inputs are always valid.

**Step 2**

To serve the request the server should make **2 HTTP POST requests** in parallel to 'https://experimentation.getsnaptravel.com/interview/hotels' with the following request body

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

Make sure to cache these responses in the server (assume the endpoint is expensive to call) in whatever way that seems fit using some external datastore that seems fit.

**Step 3**

After both these calls have returned take **only** the hotels that appear in both the responses and return a json response with the data. You can structure the data in anyway you wish as long as the data can be used to display the following table by the client. (You do NOT have to implement any html and table display logic)

For example, if the first call returned hotels with id [10,12] with SnapTravel prices 192.34 and 112.33 and the second call returned hotels [12,13] with Hotels.com prices 132.11 and 321.62 respectively, you would only render hotel 12 in the list with a SnapTravel price of 112.33 and a Hotels.com price of 132.11

![](https://i.imgur.com/fqT65hx.png)

**Step 4**

Host this api on AWS using the given credentials. You can choose any of services and components offered by amazon web services. Optionally, if you are not fimilar with aws but like some other cloud provider, feel free to implement it there. 

The api deployment must:

-  Be highly available
-  Has ability to rollback versions