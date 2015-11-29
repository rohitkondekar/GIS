

conn = new Mongo();
db = conn.getDB("test1");



print('')
print('Collections:')
print(db.getCollectionNames())
print('')

// http://mygeoposition.com



// Insert Users

print(db.users.insert({
	email	: "delivery@Cafe84.com",
    name 	: "Cafe 84"
}))

print(db.users.insert({
	email 	: "delivery@Lemonade.com",
    name 	: "Lemonade"
}))

print(db.users.insert({
	email	: "delivery@habitburger.com",
    name 	: "The Habit Burger Grill"
}))

print(db.users.insert({
	email	: "delivery@pizzastudio.com",
    name 	: "Pizza Studio USC"
}))

print(db.users.insert({
	email	: "delivery@fatburger.com",
    name 	: "Fat Burger"
}))

print(db.users.insert({
	email	: "delivery@smilescafe.com",
    name 	: "Smiles Cafe"
}))


print(db.users.insert({
		email: "Radison@gmail.com",
    	name: "Radison"
	}))

print(db.users.insert({
		email: "Starbucks@gmail.com",
    	name: "Starbucks"
	}))
print(db.users.insert({
		email: "PandaExpress@gmail.com",
    	name: "PandaExpress"
	}))
print(db.users.insert({
		email: "McDonalds@gmail.com",
    	name: "McDonalds"
	}))

print(db.users.insert({
		email: "FiveGuysBurgers@gmail.com",
    	name: "FiveGuysBurgersAndFries"
	}))

print(db.users.find())


// Insert Ads

print("Dropping ads - " + db.ads.drop())
print(db.createCollection('ads'))

db.ads.insert(
{
	posted_by:{
	email 			: "delivery@habitburger.com",
    name 			: "The Habit Burger Grill"
	},
	title 			:"Great discounts on burger",
	description 	:"Get 25% off on 2nd burger",
	tags			:["burger","food","discount"],
	start_date 		: new Date("2015-11-10"),
	end_date		: new Date("2015-12-10"),
	category		:"Restaurant",
	location		: { type: "Point", coordinates: [ -118.2862147, 34.0204590 ] }, //longitude,latitude
	comments		:[
					{
						posted_by:{
							email: "rohitkondekar@gmail.com",
				    		name: "Rohit"
						},
						text:"Awesome burgers!"
					},
					],
	likes			:[]
})

db.ads.insert(
{
	posted_by:{
	email 			: "delivery@habitburger.com",
    name 			: "The Habit Burger Grill"
	},
	title 			: "Huge discounts on Sandwiches",
	description 	: "Get 30% off on all Sandwiches",
	tags			: ["Sandwiches","food","discount"],
	start_date 		: new Date("2015-11-10"),
	end_date		: new Date("2015-12-10"),
	category		: "Restaurant",
	location		: { type: "Point", coordinates: [ -118.2862147, 34.0204590 ] }, //longitude,latitude
	comments		: [
						{
							posted_by:{
								email: "rohitkondekar@gmail.com",
					    		name: "Rohit"
							},
							text:"Nice Place!"
						},
						],
	likes			:[]
})

db.ads.insert(
{
	posted_by:{
	email 	: "delivery@Lemonade.com",
    name 	: "Lemonade"
	},
	title 			: "Tasty Juices",
	description 	: "Try out our new Apple Shake",
	tags			: ["Juice","food","new"],
	start_date 		: new Date("2015-11-10"),
	end_date		: new Date("2015-12-12"),
	category		: "Restaurant",
	location		: { type: "Point", coordinates: [ -118.2857159, 34.0201877 ] }, //longitude,latitude
	comments		: [
						{
							posted_by:{
								email: "rohitkondekar@gmail.com",
					    		name: "Rohit"
							},
							text:"Tasty Juices!"
						},
						],
	likes			:[]
})


db.ads.insert(
{
	posted_by:{
	email 	: "delivery@Lemonade.com",
    name 	: "Lemonade"
	},
	title 			: "Tasty Juices",
	description 	: "Try out our new Vegetable Shake",
	tags			: ["Juice","food","new"],
	start_date 		: new Date("2015-11-10"),
	end_date		: new Date("2015-12-12"),
	category		: "Restaurant",
	location		: { type: "Point", coordinates: [ -118.2857159, 34.0201877 ] }, //longitude,latitude
	comments		: [
						{
							posted_by:{
								email: "rohitkondekar@gmail.com",
					    		name: "Rohit"
							},
							text:"They have really Tasty Juices!"
						},
						],
	likes			:[]
})


db.ads.insert(
{
	posted_by:{
	email	: "delivery@Cafe84.com",
    name 	: "Cafe 84"
	},
	title 			: "Great Discounts on Salads",
	description 	: "10% off on all Salads",
	tags			: ["Salads","food","Discounts"],
	start_date 		: new Date("2015-11-10"),
	end_date		: new Date("2015-12-9"),
	category		: "Restaurant",
	location		: { type: "Point", coordinates: [ -118.2879635, 34.0247584 ] }, //longitude,latitude
})


db.ads.insert(
{
	posted_by:{
	email	: "delivery@pizzastudio.com",
    name 	: "Pizza Studio USC"
	},
	title 			: "25% discount on all Pizzas",
	description 	: "25% discount on all Pizzas",
	tags			: ["Juice","food","new"],
	start_date 		: new Date("2015-11-10"),
	end_date		: new Date("2015-12-12"),
	category		: "Restaurant",
	location		: { type: "Point", coordinates: [ -118.2857159, 34.0201877 ] }, //longitude,latitude
	comments		: [
						{
							posted_by:{
								email: "rohitkondekar@gmail.com",
					    		name: "Rohit"
							},
							text:"They have really Tasty Pizzas!"
						},
						],
	likes			:[]
})



db.ads.insert(
{
	posted_by:{
	email	: "delivery@fatburger.com",
    name 	: "Fat Burger"
	},
	title 			: "Buy 1 burger get 2nd free",
	description 	: "Buy 1 burger get 2nd free",
	tags			: ["Burger","food","new"],
	start_date 		: new Date("2015-11-10"),
	end_date		: new Date("2015-12-12"),
	category		: "Restaurant",
	location		: { type: "Point", coordinates: [ -118.2782110, 34.0241404 ] }, //longitude,latitude
	comments		: [
						{
							posted_by:{
								email: "rohitkondekar@gmail.com",
					    		name: "Rohit"
							},
							text:"Awesome Place"
						},
						],
	likes			:[]
})


db.ads.insert(
{
	posted_by:{
	email	: "delivery@smilescafe.com",
    name 	: "Smiles Cafe"
	},
	title 			: "Come enjoy USC!",
	description 	: "Great discounts for USC students",
	tags			: ["Burger","food","new"],
	start_date 		: new Date("2015-11-10"),
	end_date		: new Date("2015-12-12"),
	category		: "Restaurant",
	location		: { type: "Point", coordinates: [ -118.2831141, 34.0248784 ] }, //longitude,latitude,
	likes			:[]
})

db.ads.insert(
{
	posted_by:{
		email: "Radison@gmail.com",
    	name: "Radison"
	},
	title:"Great discounts on burger",
	description:"Get 25% off on 2nd burger",
	tags:["burger","food","discount"],
	start_date: new Date("2015-11-10"),
	end_date: new Date("2015-12-10"),
	category:"Restaurant",
	location: {
		type: "Point", 
		coordinates: [ -118.2814297, 34.0190806 ] 
	}, //longitude,latitude
	comments:[
		{
			posted_by:{
				email: "rohitkondekar@gmail.com",
    			name: "Rohit"
			},
			text:"Awesome burgers!"
		},
	],
	likes			:[]
})

db.ads.insert(
{
	posted_by:{
		email: "Starbucks@gmail.com",
    	name: "Starbucks"
	},
	title:"Great discounts on coffee",
	description:"Get 2nd coffee for free",
	tags:["burger","food","discount"],
	start_date: new Date("2015-11-1"),
	end_date: new Date("2015-12-10"),
	category:"Restaurant",
	location: {
		type: "Point", 
		coordinates: [ -118.2814941, 34.0187694 ] 
	}, //longitude,latitude
	comments:[
		{
			posted_by:{
				email: "rohitkondekar@gmail.com",
    			name: "Rohit"
			},
			text:"Perfect coffee!"
		},
	],
	likes			:[]
})

db.ads.insert(
{
	posted_by:{
		email: "PandaExpress@gmail.com",
    	name: "PandaExpress"
	},
	title:"Great offers on Appetizers",
	description:"Buy 2 and get 1 for free",
	tags:["burger","food","discount"],
	start_date: new Date("2015-11-5"),
	end_date: new Date("2015-12-10"),
	category:"Restaurant",
	location: {
		type: "Point", 
		coordinates: [ -118.2862362, 34.0204767 ] 
	}, //longitude,latitude
	comments:[
		{
			posted_by:{
				email: "rohitkondekar@gmail.com",
    			name: "Rohit"
			},
			text:"Decent food!"
		},
	],
	likes			:[]
})

db.ads.insert(
{
	posted_by:{
		email: "McDonalds@gmail.com",
    	name: "McDonalds"
	},
	title:"Burger",
	description:"50% discount on burgers",
	tags:["burger","food","discount"],
	start_date: new Date("2015-11-15"),
	end_date: new Date("2015-12-10"),
	category:"Restaurant",
	location: {
		type: "Point", 
		coordinates: [ -118.2768914, 34.0260877 ] 
	}, //longitude,latitude
	comments:[
		{
			posted_by:{
				email: "rohitkondekar@gmail.com",
    			name: "Rohit"
			},
			text:"Great Burgers!"
		},
	],
	likes			:[]
})

db.ads.insert(
{
	posted_by:{
		email: "FiveGuysBurgers@gmail.com",
    	name: "FiveGuysBurgersAndFries"
	},
	title:"Burger",
	description:"70% discount on burgers",
	tags:["burger","food","discount"],
	start_date: new Date("2015-11-18"),
	end_date: new Date("2015-12-10"),
	category:"Restaurant",
	location: {
		type: "Point", 
		coordinates: [ -118.2761404, 34.0269591 ] 
	}, //longitude,latitude
	comments:[
		{
			posted_by:{
				email: "rohitkondekar@gmail.com",
    			name: "Rohit"
			},
			text:"Great discounts on Burgers!"
		},
	],
	likes			:[]
})

db.ads.insert(
{
	posted_by:{
		email: "SabinasEuropean@food.com",
    	name: "Sabina's European"
	},
	title:"MeatBowl",
	description:"Great discounts on meatbowlsoups",
	tags:["food","discount"],
	start_date: new Date("2015-11-19"),
	end_date: new Date("2015-12-9"),
	category:"Food",
	location: {
		type: "Point", 
		coordinates: [ -118.3278608, 34.0941025 ] 
	}, //longitude,latitude
	comments:[
		{
			posted_by:{
				email: "rohitkondekar@gmail.com",
    			name: "Rohit"
			},
			text:"Best hungarian food"
		},
	]
})

db.ads.insert(
{
	posted_by:{
		email: "LaNumeroUno@food.com",
    	name: "La Numero Uno"
	},
	title:"MexicanDelicacies",
	description:"Awesome offers on Mexican food",
	tags:["food","discount"],
	start_date: new Date("2015-11-19"),
	end_date: new Date("2015-12-9"),
	category:"Food",
	location: {
		type: "Point", 
		coordinates: [-118.3269221, 34.0938449 ] 
	}, //longitude,latitude
	comments:[
		{
			posted_by:{
				email: "rohitkondekar@gmail.com",
    			name: "Rohit"
			},
			text:"Best Mexican food"
		},
	]
})

db.ads.insert(
{
	posted_by:{
		email: "TacoBell@food.com",
    	name: "Taco Bell"
	},
	title:"Tacos",
	description:"Buy 1 Get 1 Free Tacos",
	tags:["food","discount"],
	start_date: new Date("2015-11-19"),
	end_date: new Date("2015-12-9"),
	category:"Food",
	location: {
		type: "Point", 
		coordinates: [-118.3262944, 34.0923611 ] 
	}, //longitude,latitude
	comments:[
		{
			posted_by:{
				email: "rohitkondekar@gmail.com",
    			name: "Rohit"
			},
			text:"Great Tacos"
		},
	]
})

db.ads.insert(
{
	posted_by:{
		email: "Grub@food.com",
    	name: "Grub"
	},
	title:"AmericanCuisine",
	description:"AmericanCuisine. Discounts on sandwiches",
	tags:["food","discount"],
	start_date: new Date("2015-11-19"),
	end_date: new Date("2015-12-9"),
	category:"Food",
	location: {
		type: "Point", 
		coordinates: [-118.3333433, 34.0876164 ] 
	}, //longitude,latitude
	comments:[
		{
			posted_by:{
				email: "rohitkondekar@gmail.com",
    			name: "Rohit"
			},
			text:"Holy Grail of Sandwiches"
		},
	]
})

db.ads.insert(
{
	posted_by:{
		email: "MudHenTavern@food.com",
    	name: "Mud Hen Tavern"
	},
	title:"Seasonal Dishes",
	description:"10% off on food stuff",
	tags:["food"],
	start_date: new Date("2015-11-20"),
	end_date: new Date("2015-12-8"),
	category:"Food",
	location: {
		type: "Point", 
		coordinates: [-118.3383107, 34.0847197 ] 
	}, //longitude,latitude
	comments:[
		{
			posted_by:{
				email: "rohitkondekar@gmail.com",
    			name: "Rohit"
			},
			text:"Global cuisines available"
		},
	]
})

db.ads.insert(
{
	posted_by:{
		email: "PCC@food.com",
    	name: "Pioneer Cash & Carry"
	},
	title:"IndianFoodStuff",
	description:"Discounts on South asian groceries and processed foods",
	tags:["food"],
	start_date: new Date("2015-11-20"),
	end_date: new Date("2015-12-8"),
	category:"Food",
	location: {
		type: "Point", 
		coordinates: [-118.0840222, 33.8649571 ] 
	}, //longitude,latitude
	comments:[
		{
			posted_by:{
				email: "rohitkondekar@gmail.com",
    			name: "Rohit"
			},
			text:"Awesome Indian Cuisines and other food stuff available all day"
		},
	]
})

db.ads.insert(
{
	posted_by:{
		email: "PBP@food.com",
    	name: "Paradise Biryani Pointe"
	},
	title:"Biryani",
	description:"Discounts on Indian chain of biryani, kebabs, curries",
	tags:["food"],
	start_date: new Date("2015-11-20"),
	end_date: new Date("2015-12-8"),
	category:"Food",
	location: {
		type: "Point", 
		coordinates: [-118.0840222, 33.8649571 ] 
	}, //longitude,latitude
	comments:[
		{
			posted_by:{
				email: "rohitkondekar@gmail.com",
    			name: "Rohit"
			},
			text:"Awesome Biryani"
		},
	]
})

db.ads.insert(
{
	posted_by:{
		email: "udupi@food.com",
    	name: "Udupi Palace"
	},
	title:"Dosas, Uthapam",
	description:"Discounts on South Indian food",
	tags:["food"],
	start_date: new Date("2015-11-20"),
	end_date: new Date("2015-12-8"),
	category:"Food",
	location: {
		type: "Point", 
		coordinates: [-118.0823593, 33.8617588 ] 
	}, //longitude,latitude
	comments:[
		{
			posted_by:{
				email: "rohitkondekar@gmail.com",
    			name: "Rohit"
			},
			text:"Awesome Dosas"
		},
	]
})

db.ads.insert(
{
	posted_by:{
		email: "bhimas@food.com",
    	name: "Bhimas Pure Vegeterian"
	},
	title:"Authentic South Indian food",
	description:"Discounts on South Indian food",
	tags:["food"],
	start_date: new Date("2015-11-20"),
	end_date: new Date("2015-12-8"),
	category:"Food",
	location: {
		type: "Point", 
		coordinates: [-118.0816619, 33.8604225 ] 
	}, //longitude,latitude
	comments:[
		{
			posted_by:{
				email: "rohitkondekar@gmail.com",
    			name: "Rohit"
			},
			text:"Awesome Pongal"
		},
	]
})


db.ads.createIndex({location:"2dsphere"})
