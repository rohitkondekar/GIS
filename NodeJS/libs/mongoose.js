// Database connection is implemented and object schemas are declared
var mongoose  = require('mongoose');
var crypto 		= require('crypto');
var validator = require('validator');
var config 		= require('./config.json');
var ObjectId  = mongoose.Types.ObjectId

mongoose.connect(config.mongoose.uri);
var db = mongoose.connection;

db.on('error', function (err) {
    console.log.error('connection error:', err.message);
});

db.once('open', function callback () {
    console.log("Connected to DB!");
});

var Schema = mongoose.Schema;

var nameType = {
    type: String,
    required: true,
    trim: true
  };

var User = new Schema({
    email: {
      type: String,
      required: true,
      unique: true,
      validate: [ validator.isEmail, 'Email is not a valid address' ],
      trim: true
    },
    name: nameType,
    surname: nameType,
    photoUrl: String,
    facebook_id: String,
    facebook_access_token: String,
    facebook_refresh_token: String
});

// Virtuals

User.virtual('full_name').get(function() {
    var user = this;
    return util.format('%s %s', user.name, user.surname);
});

User.virtual('full_email').get(function() {
    var user = this;
    return util.format('%s %s <%s>', user.name, user.surname, user.email);
});

var UserModel = mongoose.model('User', User);
module.exports.UserModel = UserModel;



//--------------



var ads = new Schema({
  posted_by:{
    email   : String,
    name  : String
  },
  title       : String,
  description   : String,
  tags      : [String],
  start_date    : Date,
  end_date    : Date,
  category    : String,
  location    : {type: {type:String}, coordinates: [Number]}, //longitude,latitude
  imagedata   : Buffer,
  comments    : [
            {
              posted_by:{
                email: String,
                  name: String
              },
              text: String
            },
            ]
})

ads.index({location:'2dsphere'})
var AdsModel = mongoose.model('ads', ads);
module.exports.AdsModel = AdsModel;






