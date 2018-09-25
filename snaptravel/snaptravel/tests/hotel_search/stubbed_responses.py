RESPONSE = [{
    "hotels": [{
        "id": 12,
        "hotel_name": "Center Hilton",
        "num_reviews": 209,
        "address": "12 Wall Street, Very Large City",
        "num_stars": 4,
        "amenities": ["Wi-Fi", "Parking"],
        "image_url": "https://images.trvl-media.com/hotels/1000000/20000/19600/19558/19558_410_b.jpg",
        "price": 185.99
    }, {
        "id": 4,
        "hotel_name": "The Cosmopolitan Multinationtional Hotel",
        "num_reviews": 1955,
        "address": "141 West 65th Street, Very Large City",
        "num_stars": 4,
        "amenities": ["Wi-Fi", "Parking", "Pool"],
        "image_url": "https://images.trvl-media.com/hotels/2000000/1860000/1857300/1857289/011c64fe_z.jpg",
        "price": 77.02
    }, {
        "id": 81,
        "hotel_name": "Famous Lucky Dragon Hotel",
        "num_reviews": 1398,
        "address": "132 Sunvale Ave, Very Large City",
        "num_stars": 1,
        "amenities": ["Parking"],
        "image_url": "https://images.trvl-media.com/hotels/1000000/10000/7700/7611/7611_103_b.jpg",
        "price": 150.99
    }, {
        "id": 90,
        "hotel_name": "The Marriot Fruit Tree Hotel",
        "num_reviews": 1293,
        "address": "12 Wall Street, Very Large City",
        "num_stars": 3,
        "amenities": ["Wi-Fi", "Breakfast"],
        "image_url": "https://images.trvl-media.com/hotels/1000000/470000/460500/460434/460434_73_b.jpg",
        "price": 121.99
    }, {
        "id": 39,
        "hotel_name": "The Colorado Overlook Hotel",
        "num_reviews": 6,
        "address": "132 Long Alley Rd, Very Large City",
        "num_stars": 2,
        "amenities": [],
        "image_url": "https://images.trvl-media.com/hotels/1000000/10000/1500/1443/d73823db_b.jpg",
        "price": 187.99
    }, {
        "id": 22,
        "hotel_name": "The Grand Budapest Hotel",
        "num_reviews": 1372,
        "address": "231 Boylston St, Very Large City",
        "num_stars": 5,
        "amenities": ["Parking", "Pool"],
        "image_url": "https://images.trvl-media.com/hotels/1000000/910000/904900/904821/904821_178_b.jpg",
        "price": 185.99
    }]
}, {
    "hotels": [{
        "id": 66,
        "hotel_name": "The Pennsylvanian Factory Hotel",
        "num_reviews": 4491,
        "address": "32 West 33rd Street, Very Large City",
        "num_stars": 3,
        "amenities": ["Wi-Fi", "Pool", "Breakfast"],
        "image_url": "https://images.trvl-media.com/hotels/2000000/1070000/1062900/1062879/1062879_24_b.jpg",
        "price": 291.99
    }, {
        "id": 87,
        "hotel_name": "The Seven Seasons Hotel",
        "num_reviews": 338,
        "address": "12 Main Street, Very Large City",
        "num_stars": 5,
        "amenities": ["Wi-Fi", "Pool", "Breakfast"],
        "image_url": "https://images.trvl-media.com/hotels/1000000/50000/41300/41245/8640cd6f_b.jpg",
        "price": 101
    }, {
        "id": 81,
        "hotel_name": "Famous Lucky Dragon Hotel",
        "num_reviews": 1398,
        "address": "132 Sunvale Ave, Very Large City",
        "num_stars": 1,
        "amenities": ["Parking"],
        "image_url": "https://images.trvl-media.com/hotels/1000000/10000/7700/7611/7611_103_b.jpg",
        "price": 205.99
    }, {
        "id": 71,
        "hotel_name": "Nishiyama Oden Keiunka",
        "num_reviews": 900,
        "address": "133 Sunvale Ave, Very Large City",
        "num_stars": 4,
        "amenities": ["Pool", "Breakfast"],
        "image_url": "https://images.trvl-media.com/hotels/1000000/20000/19900/19837/19837_123_b.jpg",
        "price": 321.11
    }, {
        "id": 90,
        "hotel_name": "The Marriot Fruit Tree Hotel",
        "num_reviews": 1293,
        "address": "12 Wall Street, Very Large City",
        "num_stars": 3,
        "amenities": ["Wi-Fi", "Breakfast"],
        "image_url": "https://images.trvl-media.com/hotels/1000000/470000/460500/460434/460434_73_b.jpg",
        "price": 594.99
    }, {
        "id": 51,
        "hotel_name": "The Main Continental Hotel",
        "num_reviews": 12,
        "address": "11 Dundas Street North, Very Large City",
        "num_stars": 5,
        "amenities": ["Wi-Fi"],
        "image_url": "https://images.trvl-media.com/hotels/2000000/1770000/1770000/1769973/a842d02c_b.jpg",
        "price": 124.99
    }]
}]

MERGED = [{
    'id': 81,
    'hotel_name': 'Famous Lucky Dragon Hotel',
    'num_reviews': 1398,
    'address': '132 Sunvale Ave, Very Large City',
    'num_stars': 1,
    'amenities': ['Parking'],
    'image_url': 'https://images.trvl-media.com/hotels/1000000/10000/7700/7611/7611_103_b.jpg',
    'price': {
        'snaptravel': 150.99,
        'retail': 205.99
    }
}, {
    'id': 90,
    'hotel_name': 'The Marriot Fruit Tree Hotel',
    'num_reviews': 1293,
    'address': '12 Wall Street, Very Large City',
    'num_stars': 3,
    'amenities': ['Wi-Fi', 'Breakfast'],
    'image_url': 'https://images.trvl-media.com/hotels/1000000/470000/460500/460434/460434_73_b.jpg',
    'price': {
        'snaptravel': 121.99,
        'retail': 594.99
    }
}]