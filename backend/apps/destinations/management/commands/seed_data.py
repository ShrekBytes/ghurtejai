from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model

from apps.destinations.models import Attraction, Destination, District, Transport
from apps.experiences.models import Day, Entry, Experience
from apps.interactions.models import Comment, Vote
from apps.tags.models import Tag

User = get_user_model()


class Command(BaseCommand):
    help = "Seed the database with realistic Bangladeshi travel data"

    def handle(self, *args, **options):
        self.stdout.write("Seeding data...")

        # --- Users ---
        admin = User.objects.filter(is_superuser=True).first()
        if not admin:
            admin = User.objects.create_superuser(
                username="admin", email="admin@ghurtejai.com", password="admin123"
            )
            from apps.accounts.models import UserProfile
            UserProfile.objects.get_or_create(user=admin)

        users = []
        user_data = [
            ("rahim", "rahim@test.com", "Rahim", "Ahmed"),
            ("tasnia", "tasnia@test.com", "Tasnia", "Islam"),
            ("farhan", "farhan@test.com", "Farhan", "Hossain"),
            ("nusrat", "nusrat@test.com", "Nusrat", "Jahan"),
            ("arif", "arif@test.com", "Arif", "Rahman"),
        ]
        for uname, email, first, last in user_data:
            user, _ = User.objects.get_or_create(
                username=uname,
                defaults={
                    "email": email,
                    "first_name": first,
                    "last_name": last,
                    "role": "USER",
                },
            )
            if _:
                user.set_password("testpass123")
                user.save()
                from apps.accounts.models import UserProfile
                UserProfile.objects.get_or_create(user=user)
            users.append(user)

        self.stdout.write(f"  Created {len(users)} users")

        # --- Tags ---
        tag_names = [
            "beach", "mountain", "nature", "adventure", "food",
            "heritage", "budget", "luxury", "family", "solo",
            "photography", "hiking", "island", "river", "wildlife",
        ]
        tags = {}
        for name in tag_names:
            tag, _ = Tag.objects.get_or_create(name=name)
            tags[name] = tag
        self.stdout.write(f"  Created {len(tags)} tags")

        # --- Destinations ---
        dest_data = [
            {
                "name": "Cox's Bazar",
                "district": "Cox's Bazar",
                "description": "Home to the world's longest natural sea beach stretching 120km along the Bay of Bengal. A paradise for beach lovers with golden sand, rolling waves, and stunning sunsets.",
                "lat": "21.4272", "lng": "92.0058",
                "tags": ["beach", "nature", "photography", "family"],
                "attractions": [
                    ("PLACE", "Laboni Beach", "The main beach area in Cox's Bazar town, perfect for evening walks and sunrise views.", "Laboni Point, Cox's Bazar", ""),
                    ("PLACE", "Himchari National Park", "Lush green hills meeting the sea with waterfalls and hiking trails.", "Himchari Road, Cox's Bazar", "৳50"),
                    ("PLACE", "Inani Beach", "Quieter stretch of beach with unique rock formations and crystal-clear water.", "Inani, Cox's Bazar", ""),
                    ("FOOD", "Bhatar Ghor Seafood", "Famous for fresh grilled lobster and prawn curry. Must-try for seafood lovers.", "Kolatoli Road", "৳300-৳800"),
                    ("FOOD", "Poushee Restaurant", "Local favorite for traditional Bengali fish dishes and shutki bhorta.", "Hotel Motel Zone", "৳200-৳500"),
                    ("ACTIVITY", "Surfing at Laboni", "Beginner-friendly surfing with local instructors. Best during October-March.", "Laboni Beach", "৳500-৳1000"),
                    ("ACTIVITY", "Boat trip to St. Martin", "Day trip by ship to Bangladesh's only coral island.", "Cox's Bazar Jetty", "৳800-৳2500"),
                ],
                "transports": [
                    ("BUS", "Dhaka", "Cox's Bazar", "Shyamoli Paribahan", 1200, "10:00:00", "Kalyanpur Bus Stand", "10h"),
                    ("AC_BUS", "Dhaka", "Cox's Bazar", "Green Line", 2000, "22:00:00", "Kalyanpur Bus Stand", "9h"),
                    ("FLIGHT", "Dhaka", "Cox's Bazar", "US-Bangla Airlines", 5500, "08:00:00", "Hazrat Shahjalal Airport", "1h"),
                ],
            },
            {
                "name": "Sylhet",
                "district": "Sylhet",
                "description": "Known as the land of two leaves and a bud, Sylhet is famous for its rolling tea gardens, crystal-clear rivers, and mystical Sufi shrines.",
                "lat": "24.8949", "lng": "91.8687",
                "tags": ["nature", "heritage", "photography", "hiking"],
                "attractions": [
                    ("PLACE", "Ratargul Swamp Forest", "Bangladesh's only freshwater swamp forest. A surreal experience during monsoon when trees stand submerged in emerald water.", "Gowainghat, Sylhet", "৳100"),
                    ("PLACE", "Jaflong", "Stunning river landscape where the Dawki river flows from Meghalaya with crystal-clear water and pebble beds.", "Jaflong, Sylhet", ""),
                    ("PLACE", "Lalakhal", "Mesmerizing turquoise river surrounded by tea gardens and hills. Boat rides are a must.", "Jaintiapur, Sylhet", "৳200"),
                    ("FOOD", "Panshi Restaurant", "Iconic Sylheti restaurant famous for traditional 7-tala chai and Sylheti hatkora curry.", "Zindabazar, Sylhet", "৳150-৳400"),
                    ("FOOD", "Satkora Beef Curry", "A Sylheti specialty — beef cooked with wild citrus fruit. Available across local eateries.", "Various locations", "৳200-৳350"),
                    ("ACTIVITY", "Tea Garden Walk", "Stroll through endless rows of tea bushes in Malnicherra, the oldest tea garden in the subcontinent (est. 1854).", "Malnicherra Tea Estate", ""),
                    ("ACTIVITY", "Boat Ride at Lalakhal", "Hire a local boat for a 2-hour cruise through the turquoise Lalakhal river.", "Lalakhal Ghat", "৳800-৳1500"),
                ],
                "transports": [
                    ("BUS", "Dhaka", "Sylhet", "Ena Transport", 800, "08:00:00", "Sayedabad Bus Stand", "6h"),
                    ("AC_BUS", "Dhaka", "Sylhet", "Shyamoli NR", 1400, "23:30:00", "Fakirapul", "5h30m"),
                    ("TRAIN", "Dhaka", "Sylhet", "Parabat Express", 600, "06:40:00", "Kamalapur Railway", "7h"),
                ],
            },
            {
                "name": "Bandarban",
                "district": "Bandarban",
                "description": "The rooftop of Bangladesh. Home to the country's highest peaks, indigenous Marma and Bawm communities, and breathtaking cloud-covered hills.",
                "lat": "22.1953", "lng": "92.2184",
                "tags": ["mountain", "adventure", "hiking", "nature", "photography"],
                "attractions": [
                    ("PLACE", "Nilgiri Hills", "Highest accessible tourist spot in Bandarban at 2400ft. Above the clouds on clear mornings.", "Nilgiri, Bandarban", "৳50"),
                    ("PLACE", "Boga Lake", "Sacred lake of the Bawm tribe at 3000ft elevation. Requires a trek through dense bamboo forests.", "Ruma Upazila, Bandarban", ""),
                    ("PLACE", "Meghla Parjatan Complex", "Family-friendly park with a hanging bridge, boating lake, and mini zoo.", "Bandarban Town", "৳30"),
                    ("FOOD", "Bamboo Chicken", "Indigenous specialty — chicken cooked inside bamboo over open fire. Unique smoky flavor.", "Various tribal restaurants", "৳300-৳500"),
                    ("FOOD", "Reng Restaurant", "Popular local eatery serving Marma and Bengali fusion dishes.", "Bandarban Sadar", "৳150-৳350"),
                    ("ACTIVITY", "Trekking to Keokradong", "Multi-day trek to Bangladesh's second-highest peak at 4364ft.", "Ruma Upazila", "৳3000-৳5000"),
                    ("ACTIVITY", "Rafting on Sangu River", "White-water rafting experience through Bandarban's river valleys.", "Thanchi, Bandarban", "৳1500-৳3000"),
                ],
                "transports": [
                    ("BUS", "Dhaka", "Bandarban", "S. Alam Transport", 1000, "21:00:00", "Sayedabad Bus Stand", "9h"),
                    ("BUS", "Chattogram", "Bandarban", "Local Bus", 200, "07:00:00", "Bahaddarhat Bus Stand", "2h30m"),
                ],
            },
            {
                "name": "Sundarbans",
                "district": "Khulna",
                "description": "The largest mangrove forest in the world and home to the Royal Bengal Tiger. A UNESCO World Heritage Site offering a unique jungle and river experience.",
                "lat": "21.9497", "lng": "89.1833",
                "tags": ["nature", "wildlife", "adventure", "photography"],
                "attractions": [
                    ("PLACE", "Karamjal Wildlife Center", "Deer, crocodiles, and a boardwalk through the mangrove. Good introduction to the Sundarbans.", "Mongla, Bagerhat", "৳20"),
                    ("PLACE", "Katka Beach", "Remote wild beach inside the Sundarbans. Deer roam freely and tiger pugmarks are common.", "Deep Sundarbans", ""),
                    ("PLACE", "Harbaria Eco-Tourism Center", "Wooden walkway through dense mangrove with monkey and bird sightings.", "Sundarbans East Division", "৳150"),
                    ("FOOD", "Fresh River Fish", "Caught daily by local fishermen. Hilsa, Bhola, and Chingri prepared simply with mustard.", "Tour boats", "৳200-৳400"),
                    ("ACTIVITY", "3-Day Boat Tour", "Full Sundarbans experience — cruise through narrow creeks, spot wildlife, camp on boat.", "Mongla Port", "৳8000-৳15000"),
                    ("ACTIVITY", "Bird Watching at Jamtola", "Early morning bird watching — kingfishers, eagles, and herons in abundance.", "Jamtola Beach Area", ""),
                ],
                "transports": [
                    ("BUS", "Dhaka", "Khulna", "Eagle Paribahan", 700, "06:00:00", "Gabtoli Bus Stand", "8h"),
                    ("TRAIN", "Dhaka", "Khulna", "Sundarban Express", 500, "06:20:00", "Kamalapur Railway", "9h"),
                    ("AC_BUS", "Dhaka", "Khulna", "Shohagh Paribahan", 1100, "22:00:00", "Gabtoli Bus Stand", "7h"),
                ],
            },
            {
                "name": "Rangamati",
                "district": "Rangamati",
                "description": "The lake district of Bangladesh. Built around the massive Kaptai Lake with indigenous Chakma culture, hanging bridges, and forested islands.",
                "lat": "22.6324", "lng": "92.1710",
                "tags": ["nature", "island", "river", "photography", "solo"],
                "attractions": [
                    ("PLACE", "Kaptai Lake", "Largest artificial lake in Bangladesh, created by damming the Karnaphuli River. Stunning at sunset.", "Rangamati Town", ""),
                    ("PLACE", "Shuvolong Waterfall", "Seasonal waterfall cascading into the lake. Best visited during monsoon (June-September).", "Shuvolong, Rangamati", "৳50"),
                    ("PLACE", "Hanging Bridge", "Iconic suspension bridge over Kaptai Lake connecting Rangamati town to tribal villages.", "Rangamati Town", "৳20"),
                    ("FOOD", "Chakma Cuisine", "Try traditional Chakma dishes like bamboo shoot curry, dried fish preparations, and rice wine.", "Tribal restaurants", "৳200-৳400"),
                    ("ACTIVITY", "Island Hopping by Boat", "Hire a local boat and explore the forested islands scattered across Kaptai Lake.", "Rangamati Ghat", "৳1000-৳3000"),
                    ("ACTIVITY", "Visit Rajban Bihar", "Ancient Buddhist temple complex with golden pagoda and peaceful monastery.", "Rajban Bihar, Rangamati", ""),
                ],
                "transports": [
                    ("BUS", "Dhaka", "Rangamati", "S. Alam Transport", 900, "21:30:00", "Sayedabad Bus Stand", "8h"),
                    ("BUS", "Chattogram", "Rangamati", "Local Bus", 150, "08:00:00", "Oxygen Bus Stand", "2h"),
                ],
            },
            {
                "name": "Sajek Valley",
                "district": "Rangamati",
                "description": "Called the Queen of Hills, Sajek sits at 1800ft with panoramic views of cloud-covered hills, indigenous Lushai villages, and spectacular sunrises.",
                "lat": "23.3838", "lng": "92.2937",
                "tags": ["mountain", "nature", "photography", "adventure", "solo"],
                "attractions": [
                    ("PLACE", "Konglak Hill", "The higher viewpoint of Sajek at 1800ft. Sunrise here with clouds below is unforgettable.", "Sajek Union", ""),
                    ("PLACE", "Ruilui Para", "Lushai tribal village where you can experience indigenous culture and buy handmade crafts.", "Sajek Valley", ""),
                    ("PLACE", "Helicopter Landing Zone", "Wide open hilltop with 360-degree views. Popular camping spot.", "Sajek Valley", ""),
                    ("FOOD", "Bamboo Chicken & BBQ", "The signature Sajek experience — chicken cooked in bamboo paired with campfire BBQ.", "Resort restaurants", "৳400-৳700"),
                    ("ACTIVITY", "Sunrise Trek", "Early morning hike to Konglak viewpoint for the famous sea of clouds.", "Sajek Valley", ""),
                    ("ACTIVITY", "Camping Under Stars", "Set up camp at the helipad area for a night of stargazing and bonfire.", "Helicopter Zone", "৳500-৳1000"),
                ],
                "transports": [
                    ("BUS", "Dhaka", "Khagrachhari", "Shanti Paribahan", 800, "22:00:00", "Sayedabad Bus Stand", "7h"),
                    ("OTHER", "Khagrachhari", "Sajek Valley", "Chander Gari (Jeep)", 3500, "08:00:00", "Khagrachhari Stand", "3h"),
                ],
            },
            {
                "name": "Srimangal",
                "district": "Moulvibazar",
                "description": "The tea capital of Bangladesh. Endless rolling tea gardens, the Lawachara rainforest with hoolock gibbons, and the famous seven-layer tea.",
                "lat": "24.3065", "lng": "91.7296",
                "tags": ["nature", "food", "photography", "hiking", "wildlife"],
                "attractions": [
                    ("PLACE", "Lawachara National Park", "Tropical rainforest home to the endangered hoolock gibbon. Guided jungle walks available.", "Kamalganj Road, Srimangal", "৳100"),
                    ("PLACE", "Madhabpur Lake", "Peaceful lake surrounded by tea gardens. Row boats available for hire.", "Kamalganj, Moulvibazar", "৳50"),
                    ("PLACE", "Baikka Beel Wetland", "Freshwater wetland sanctuary with migratory birds from Siberia in winter.", "Srimangal", "৳50"),
                    ("FOOD", "Nilkantha Tea Cabin", "The birthplace of the famous seven-layer tea. Each layer has a distinct flavor.", "Srimangal Town", "৳80-৳120"),
                    ("FOOD", "Lemon & Pineapple Farms", "Visit local farms and taste fresh tropical fruits straight from the garden.", "Srimangal outskirts", "৳100-৳200"),
                    ("ACTIVITY", "Tea Garden Cycling", "Rent a bicycle and ride through kilometers of scenic tea estates.", "Srimangal Town", "৳200-৳400"),
                    ("ACTIVITY", "Gibbon Spotting Trek", "Early morning guided trek in Lawachara to spot hoolock gibbons in their natural habitat.", "Lawachara NP", "৳500-৳800"),
                ],
                "transports": [
                    ("TRAIN", "Dhaka", "Srimangal", "Upaban Express", 350, "06:30:00", "Kamalapur Railway", "5h"),
                    ("BUS", "Dhaka", "Srimangal", "Hanif Enterprise", 600, "07:00:00", "Sayedabad Bus Stand", "5h"),
                ],
            },
            {
                "name": "Saint Martin's Island",
                "district": "Cox's Bazar",
                "description": "Bangladesh's only coral island. Crystal-clear water, coconut palms, fresh seafood, and a laid-back island vibe. Best visited November-March.",
                "lat": "20.6271", "lng": "92.3234",
                "tags": ["beach", "island", "nature", "solo", "photography"],
                "attractions": [
                    ("PLACE", "Chera Dwip", "Tiny island connected to Saint Martin at low tide. Walk across and explore tide pools.", "Southern tip, Saint Martin", ""),
                    ("PLACE", "West Beach", "The main beach with calm water for swimming and snorkeling. Bioluminescence at night in season.", "Saint Martin", ""),
                    ("FOOD", "Fresh Coconut & Seafood", "Coconut water sipped on the beach, followed by grilled fish and lobster for dinner.", "Beach shacks", "৳200-৳600"),
                    ("FOOD", "Dried Fish (Shutki)", "The island's specialty. Try it as a spicy bhorta with steaming rice.", "Local restaurants", "৳100-৳250"),
                    ("ACTIVITY", "Snorkeling", "Explore coral formations and tropical fish in the shallow reef areas.", "West Beach", "৳300-৳500"),
                    ("ACTIVITY", "Stargazing", "Zero light pollution makes Saint Martin one of the best stargazing spots in Bangladesh.", "Any beach", ""),
                ],
                "transports": [
                    ("OTHER", "Teknaf", "Saint Martin", "Ship (Green Line Marine)", 800, "09:00:00", "Teknaf Ghat", "2h"),
                    ("OTHER", "Cox's Bazar", "Teknaf", "Local Bus", 150, "06:00:00", "Cox's Bazar Bus Stand", "2h"),
                ],
            },
        ]

        from datetime import timedelta

        for d in dest_data:
            district = District.objects.filter(name=d["district"]).first()
            dest, created = Destination.objects.get_or_create(
                name=d["name"],
                defaults={
                    "description": d["description"],
                    "district": district,
                    "latitude": d.get("lat"),
                    "longitude": d.get("lng"),
                    "status": "APPROVED",
                    "submitted_by": admin,
                },
            )
            if created:
                for tag_name in d.get("tags", []):
                    if tag_name in tags:
                        dest.tags.add(tags[tag_name])

                for atype, aname, anotes, aaddr, aprice in d.get("attractions", []):
                    Attraction.objects.create(
                        destination=dest,
                        type=atype,
                        name=aname,
                        notes=anotes,
                        address=aaddr,
                        price_range=aprice,
                        status="APPROVED",
                        submitted_by=admin,
                    )

                for ttype, tfrom, tto, top, tcost, ttime, tstart, tdur in d.get("transports", []):
                    import re
                    h_match = re.search(r"(\d+)h", tdur)
                    m_match = re.search(r"(\d+)m", tdur)
                    hours = int(h_match.group(1)) if h_match else 0
                    minutes = int(m_match.group(1)) if m_match else 0
                    Transport.objects.create(
                        destination=dest,
                        type=ttype,
                        from_location=tfrom,
                        to_location=tto,
                        operator=top,
                        cost=tcost,
                        departure_time=ttime,
                        start_point=tstart,
                        duration=timedelta(hours=hours, minutes=minutes) if (hours or minutes) else None,
                        status="APPROVED",
                        submitted_by=admin,
                    )

        destinations = list(Destination.objects.filter(status="APPROVED"))
        self.stdout.write(f"  Created {len(destinations)} destinations")

        # --- Experiences ---
        experience_data = [
            {
                "title": "3 Days in Cox's Bazar — The Ultimate Beach Trip",
                "description": "My first time visiting the longest beach in the world. We covered Laboni, Himchari, Inani and even took a day trip to Saint Martin. The seafood was incredible and the sunsets were unreal.",
                "dest": "Cox's Bazar",
                "author": users[0],
                "tags": ["beach", "family", "food"],
                "user_cost": 12000,
                "days": [
                    [
                        ("Arrive at Cox's Bazar", "10:00", 0, "Took the Green Line overnight bus from Dhaka"),
                        ("Check in to Hotel Sea Crown", "11:00", 3000, "Nice hotel right on Kolatoli road"),
                        ("Lunch at Bhatar Ghor", "13:00", 500, "Grilled lobster was amazing"),
                        ("Laboni Beach sunset walk", "17:00", 0, "The golden hour here is something else"),
                        ("Dinner at Poushee", "19:30", 400, "Traditional Bengali fish thali"),
                    ],
                    [
                        ("Breakfast at hotel", "08:00", 200, ""),
                        ("Himchari National Park", "09:30", 50, "The waterfall was flowing nicely"),
                        ("Inani Beach", "12:00", 0, "The rock formations are unique"),
                        ("Lunch — beach side grilled fish", "13:30", 350, "Fresh catch cooked on the spot"),
                        ("Surfing lessons at Laboni", "15:30", 700, "First time surfing! Instructor was great"),
                        ("Night market shopping", "19:00", 500, "Bought dried fish and shells"),
                    ],
                    [
                        ("Early morning beach walk", "06:00", 0, "Sunrise at Cox's Bazar is a must-see"),
                        ("Checkout and pack", "10:00", 0, ""),
                        ("Last lunch — prawn curry feast", "12:00", 600, "Had the best prawn curry of my life"),
                        ("Bus back to Dhaka", "14:00", 2000, "Green Line AC bus"),
                    ],
                ],
            },
            {
                "title": "Sylhet Tea Trail — 4 Day Adventure",
                "description": "Explored the tea gardens of Srimangal, the magical Ratargul swamp forest, and the crystal-clear waters of Jaflong and Lalakhal. Sylhet is a nature lover's paradise.",
                "dest": "Sylhet",
                "author": users[1],
                "tags": ["nature", "photography", "hiking"],
                "user_cost": 9500,
                "days": [
                    [
                        ("Train from Dhaka — Parabat Express", "06:40", 600, "Beautiful scenic route through haor areas"),
                        ("Arrive Sylhet, check in", "13:30", 2000, "Hotel in Zindabazar area"),
                        ("7-tala chai at Panshi", "15:00", 80, "The famous seven-layer tea!"),
                        ("Hazrat Shah Jalal Mazar", "16:30", 0, "Beautiful Sufi shrine, very peaceful"),
                        ("Dinner — Sylheti hatkora curry", "19:00", 350, "The citrus flavor is unique to Sylhet"),
                    ],
                    [
                        ("Drive to Ratargul Swamp Forest", "07:00", 500, "Hired a CNG auto from Sylhet"),
                        ("Boat ride through Ratargul", "09:00", 300, "Surreal — trees standing in emerald water"),
                        ("Jaflong — crystal clear river", "12:00", 0, "You can see the bottom of the river from the bridge"),
                        ("Lunch near Jaflong", "13:30", 250, "Simple but delicious local food"),
                        ("Back to Sylhet", "17:00", 500, ""),
                    ],
                    [
                        ("Lalakhal boat trip", "08:00", 1200, "Turquoise water surrounded by hills and tea gardens"),
                        ("Tea garden walk", "13:00", 0, "Walked through endless rows of tea bushes"),
                        ("Malnicherra Tea Estate", "15:00", 0, "Oldest tea garden in the subcontinent"),
                        ("Evening at hotel, rest", "18:00", 0, ""),
                    ],
                    [
                        ("Breakfast and checkout", "08:00", 200, ""),
                        ("Last tea stop", "09:30", 100, "One more 7-layer chai for the road"),
                        ("Bus back to Dhaka", "10:30", 1400, "Shyamoli NR AC bus"),
                    ],
                ],
            },
            {
                "title": "Bandarban — Trekking the Roof of Bangladesh",
                "description": "An adrenaline-packed trip to the Chittagong Hill Tracts. Nilgiri above the clouds, trekking through bamboo forests, and tasting bamboo chicken around a campfire.",
                "dest": "Bandarban",
                "author": users[2],
                "tags": ["mountain", "adventure", "hiking"],
                "user_cost": 8000,
                "days": [
                    [
                        ("Overnight bus from Dhaka", "21:00", 1000, "S. Alam Transport to Bandarban"),
                        ("Arrive Bandarban, freshen up", "06:00", 0, ""),
                        ("Breakfast — local paratha and dal", "07:30", 100, ""),
                        ("Nilgiri Hills trip", "09:00", 1500, "Chander gari rental. Above the clouds!"),
                        ("Lunch at Nilgiri resort", "13:00", 400, "Mountain view dining"),
                        ("Meghla Parjatan Complex", "16:00", 30, "Hanging bridge and boating lake"),
                        ("Dinner — Bamboo Chicken", "19:00", 400, "The smoky flavor from the bamboo is incredible"),
                    ],
                    [
                        ("Trek to Boga Lake starts", "06:00", 3000, "Guide + porter for the trek"),
                        ("Pass through Ruma bazaar", "08:30", 100, "Bought snacks and water"),
                        ("Dense bamboo forest section", "11:00", 0, "The hardest part of the trek"),
                        ("Arrive Boga Lake", "15:00", 0, "Sacred lake of the Bawm tribe. Stunning."),
                        ("Camp by the lake", "18:00", 0, "Campfire dinner and stargazing"),
                    ],
                    [
                        ("Sunrise at Boga Lake", "05:30", 0, "Mist rising from the lake at dawn"),
                        ("Trek back to Ruma", "07:00", 0, "Downhill is easier"),
                        ("Lunch at Ruma", "12:00", 200, ""),
                        ("Back to Bandarban town", "15:00", 300, "Local jeep"),
                        ("Evening bus to Dhaka", "18:00", 1000, "Exhausted but happy"),
                    ],
                ],
            },
            {
                "title": "Sundarbans — Into the Mangrove",
                "description": "A 3-day boat expedition through the world's largest mangrove forest. We spotted deer, crocodiles, and countless birds. Didn't see a tiger but the pugmarks were fresh!",
                "dest": "Sundarbans",
                "author": users[3],
                "tags": ["nature", "wildlife", "adventure"],
                "user_cost": 15000,
                "days": [
                    [
                        ("Bus to Khulna from Dhaka", "06:00", 700, "Eagle Paribahan"),
                        ("Arrive Khulna, transfer to Mongla", "14:00", 200, "CNG to Mongla port"),
                        ("Board the tour boat", "16:00", 12000, "3-day all-inclusive tour package"),
                        ("Cruise into the Sundarbans", "17:00", 0, "Watching the mangrove close in around us"),
                        ("Dinner on the boat", "19:30", 0, "Fresh river fish — hilsa and prawns"),
                    ],
                    [
                        ("Wake up to bird calls", "05:30", 0, "Kingfishers and eagles everywhere"),
                        ("Karamjal Wildlife Center", "08:00", 20, "Deer and crocodile breeding center"),
                        ("Deep creek exploration", "11:00", 0, "Narrow waterways through dense mangrove"),
                        ("Harbaria boardwalk", "14:00", 150, "Monkeys swinging in the trees above"),
                        ("Sunset from the boat deck", "17:30", 0, "Golden light on the water"),
                    ],
                    [
                        ("Katka Beach early morning", "06:00", 0, "Tiger pugmarks on the beach!"),
                        ("Bird watching at Jamtola", "09:00", 0, "Spotted a white-bellied sea eagle"),
                        ("Return journey begins", "12:00", 0, ""),
                        ("Arrive Mongla, bus to Dhaka", "17:00", 700, ""),
                    ],
                ],
            },
            {
                "title": "Sajek — Weekend Above the Clouds",
                "description": "Quick 2-day escape to Sajek Valley. The sunrise from Konglak hill with clouds below your feet is something everyone needs to experience at least once.",
                "dest": "Sajek Valley",
                "author": users[4],
                "tags": ["mountain", "photography", "solo"],
                "user_cost": 6000,
                "days": [
                    [
                        ("Night bus to Khagrachhari", "22:00", 800, "Shanti Paribahan from Dhaka"),
                        ("Arrive Khagrachhari, hire Chander Gari", "05:00", 3500, "Shared jeep to Sajek"),
                        ("Bumpy ride through hills", "06:00", 0, "The road is an adventure itself"),
                        ("Arrive Sajek, check into resort", "09:00", 1500, "Room with valley view"),
                        ("Explore Ruilui Para village", "11:00", 0, "Bought handmade Lushai crafts"),
                        ("Lunch — Bamboo Chicken BBQ", "13:00", 500, "The signature Sajek meal"),
                        ("Sunset at Helipad viewpoint", "17:00", 0, "360-degree views, absolute silence"),
                        ("Campfire and stargazing", "20:00", 0, "No light pollution — Milky Way visible"),
                    ],
                    [
                        ("Sunrise trek to Konglak", "04:30", 0, "Sea of clouds below — breathtaking"),
                        ("Breakfast at resort", "07:30", 200, ""),
                        ("Last walk around the valley", "09:00", 0, ""),
                        ("Chander Gari back to Khagrachhari", "11:00", 0, "Included in round trip"),
                        ("Bus to Dhaka", "14:00", 800, ""),
                    ],
                ],
            },
            {
                "title": "Srimangal on a Budget — Tea, Gibbons & Seven Layers",
                "description": "A budget-friendly 2-day trip to the tea capital. The seven-layer tea at Nilkantha is real magic, and hearing gibbons call in Lawachara was a highlight of my year.",
                "dest": "Srimangal",
                "author": users[0],
                "tags": ["nature", "budget", "food", "wildlife"],
                "user_cost": 4500,
                "days": [
                    [
                        ("Train from Dhaka — Upaban Express", "06:30", 350, "Scenic ride through haor and tea gardens"),
                        ("Arrive Srimangal", "11:30", 0, ""),
                        ("Seven-layer tea at Nilkantha", "12:00", 80, "Each layer tastes different — how?!"),
                        ("Rent bicycle, tea garden ride", "13:30", 200, "Cycling through tea estates is so peaceful"),
                        ("Lawachara National Park", "15:30", 100, "Spotted a hoolock gibbon family!"),
                        ("Dinner at local eatery", "19:00", 150, "Simple dal-rice-fish, perfect"),
                        ("Budget hotel stay", "20:30", 800, "Clean and decent"),
                    ],
                    [
                        ("Madhabpur Lake", "08:00", 50, "Rowboat on the lake, tea gardens reflecting in water"),
                        ("Baikka Beel Wetland", "11:00", 50, "Winter migratory birds from Siberia"),
                        ("Pineapple & lemon farm visit", "13:00", 150, "Tasted the freshest pineapple ever"),
                        ("Lunch and pack up", "14:30", 200, ""),
                        ("Train back to Dhaka", "16:00", 350, ""),
                    ],
                ],
            },
        ]

        for exp_d in experience_data:
            dest = Destination.objects.filter(name=exp_d["dest"]).first()
            if not dest:
                continue

            exp, created = Experience.objects.get_or_create(
                title=exp_d["title"],
                defaults={
                    "description": exp_d["description"],
                    "destination": dest,
                    "author": exp_d["author"],
                    "user_cost": exp_d.get("user_cost"),
                    "status": "PUBLISHED",
                    "visibility": "PUBLIC",
                },
            )
            if not created:
                continue

            for tag_name in exp_d.get("tags", []):
                if tag_name in tags:
                    exp.tags.add(tags[tag_name])

            for day_idx, entries in enumerate(exp_d["days"]):
                day = Day.objects.create(experience=exp, position=day_idx)
                for entry_idx, (ename, etime, ecost, enotes) in enumerate(entries):
                    Entry.objects.create(
                        day=day,
                        name=ename,
                        time=etime if etime else None,
                        cost=ecost if ecost else None,
                        notes=enotes,
                        position=entry_idx,
                    )

            exp.compute_estimated_cost()

        experiences = list(Experience.objects.filter(status="PUBLISHED"))
        self.stdout.write(f"  Created {len(experiences)} experiences")

        # --- Votes (upvotes) ---
        import random
        for exp in experiences:
            voters = random.sample(users, k=random.randint(1, len(users)))
            for voter in voters:
                if voter != exp.author:
                    Vote.objects.get_or_create(
                        user=voter, experience=exp, defaults={"value": 1}
                    )

        # --- Comments ---
        comments_data = [
            "Amazing guide! Saved this for my next trip.",
            "The bamboo chicken tip is gold. Thanks for sharing!",
            "How was the weather when you visited?",
            "Great budget breakdown. Very helpful for planning.",
            "I went last month and can confirm — the sunrise is unreal!",
            "Which hotel would you recommend for families?",
            "Been wanting to go here forever. This convinced me!",
            "The transport info is super useful, thanks!",
            "Did you face any safety issues during the trek?",
            "Beautiful photos would have made this even better. Still a great guide!",
        ]

        for exp in experiences:
            num_comments = random.randint(2, 5)
            for i in range(num_comments):
                commenter = random.choice([u for u in users if u != exp.author])
                comment = Comment.objects.create(
                    experience=exp,
                    author=commenter,
                    text=random.choice(comments_data),
                )
                if random.random() > 0.5:
                    replier = random.choice([u for u in users if u != commenter])
                    Comment.objects.create(
                        experience=exp,
                        author=replier,
                        text=random.choice([
                            "Totally agree!",
                            "I had a similar experience.",
                            "Thanks for the tip!",
                            "You should visit during winter, it's even better.",
                            "Great question — I'd like to know too!",
                        ]),
                        parent=comment,
                    )

        self.stdout.write(self.style.SUCCESS("Seeding complete!"))
