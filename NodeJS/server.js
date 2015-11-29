var express 		= require('express');
var bodyParser 		= require('body-parser');
var morgan 			= require('morgan');
var methodOverride 	= require('method-override');
var config 			= require('./libs/config.json');
var mongooseLib 	= require('./libs/mongoose');
var auth 			= require('./libs/auth')
var passport 		= require('passport');
var ObjectId 		= require('mongoose').Types.ObjectId
var AdsModel 		= require('./libs/mongoose').AdsModel;

var mile			= 1609.34


// Create our Express application
var app = express();

// To Support Json data

// Use the body-parser package in our application
app.use(bodyParser.urlencoded({
  extended: true
}));
app.use(bodyParser.json());

app.use(morgan('combined'));

// override with different headers; last one takes precedence
app.use(methodOverride('X-HTTP-Method'))          // Microsoft
app.use(methodOverride('X-HTTP-Method-Override')) // Google/GData
app.use(methodOverride('X-Method-Override'))      // IBM

app.use(passport.initialize());

passport.serializeUser(function(user, done) {
  done(null, user);
});

passport.deserializeUser(function(user, done) {
  done(null, user);
});


var router = express.Router();

router.get('/',function(req,res) {
	res.json({ message: 'Api is running.' });
});




app.post('/api/ads/within', function (req, res){

	var latitude 	= req.body.latitude
	var longitude 	= req.body.longitude
	var distance 	= req.body.distance
	var type 		= req.body.category

	AdsModel.geoNear(
		{
			type: "Point",
			coordinates: [longitude,latitude]
		},{
		query : { 
			category : type
		},
		spherical : true,
		lean: true,
		maxDistance : distance

	}, function(err, ads){

		// Form everything in one json
		for(var i=0; i < ads.length; i++){
			ads[i].obj.distance = ads[i].dis
			ads[i] = ads[i].obj
		}

		if(err){
			console.log("***Error****"+err)
		}

		console.log(ads)
		res.json(ads)
	})


});


app.post('/api/ads/restaurant/sortdistance', function (req, res){

	var latitude 	= req.body.latitude
	var longitude 	= req.body.longitude

	AdsModel.geoNear(
		{
			type: "Point",
			coordinates: [longitude,latitude]
		},{
		query : { 
			category : "Restaurant"
		},
		spherical : true,
		lean: true,
		maxDistance : mile,

	}, function(err, ads){

		for(var i=0; i < ads.length; i++){
			ads[i].obj.distance = ads[i].dis
			ads[i] = ads[i].obj
		}

		if(err){
			console.log("***Error****"+err)
		}

		//console.log(ads)
		res.json(ads)
	})

	// var query = AdsModel.find()
	
	// query.where('location').near({
	// 	center : {
	// 		type: "Point",
	// 		coordinates: [longitude,latitude]
	// 	},
	// 	maxDistance: mile
	// })
	// query.exec(function(err, ads){
	// 	console.log(ads)
	// 	console.log(err)
	// 	res.json(ads)
	// })
});


app.post('/api/ads/restaurant/sortrating', function (req, res){
	var query = AdsModel.find({category:'Restaurant'})

	query.sort({
			likes_count : -1
	})

	query.exec(function(err, ads){
		console.dir(ads)
		console.dir(err)
		res.json(ads)
	})

});



app.post('/api/ads/restaurant', function (req, res){
	AdsModel.find({category:'Restaurant'}, function(err, ads){
		res.json(ads)
	})
});




app.post('/api/ads/restaurant/like', function(req,res){

	AdsModel.collection.update({_id: new ObjectId(req.body.id)},{$addToSet: {likes: req.body.email}}, function(err, numAffected){
		if(err != null) {
			console.error(err)
		}
		
		console.dir("Number of Affected Documents : "+numAffected.result.nModified)
		if(numAffected.result.nModified != 0){
			AdsModel.collection.update({_id: new ObjectId(req.body.id)},{$inc: {likes_count: 1}}, function(err, nums){
				console.dir("Count Increased by : "+ nums.result.nModified)
			})
		}
	})
	res.sendStatus(200);
})


app.post('/api/ads/restaurant/unlike', function(req,res){
	
	AdsModel.collection.update({_id: new ObjectId(req.body.id)},{$pull: {likes: req.body.email}}, function(err, numAffected){
		if(err != null) {
			console.error(err)
		}
		
		console.dir("Number of Affected Documents : "+numAffected.result.nModified)
		if(numAffected.result.nModified != 0){
			AdsModel.collection.update({_id: new ObjectId(req.body.id)},{$inc: {likes_count: -1}}, function(err, nums){
				console.dir("Count Decreased by : "+ nums.result.nModified)
			})
		}
	})
	res.sendStatus(200);
})


app.get('/api/ads',function(req,res){
	res.send("This is not implemented now");
});

app.post('/api/ads',function(req,res){
	res.send("This is not implemented now");
});

app.get('/api/ads/:id', function(req, res) {
    res.send('This is not implemented now');
});

app.put('/api/ads/:id', function (req, res){
    res.send('This is not implemented now');    
});

app.delete('/api/ads/:id', function (req, res){
    res.send('This is not implemented now');
});

app.post('/api/auth/facebook',
	passport.authenticate('facebook-token',{ scope : 'email'}),
	function (req, res) {
	    
	    console.log('request came in')

	    if(!req.user){
	    	res.status(401).json({access_token:""});
	    }
	    else {
	    	res.status(200).json({access_token:req.user.facebook_access_token});
	    }
	}
);

app.use('/api',router)

app.listen(config.port, function(){
    console.log('Express server listening on port '+ config.port);
});
