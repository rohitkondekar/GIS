var config                  = require('./config');
var passport 				= require('passport');
var FacebookTokenStrategy   = require('passport-facebook-token').Strategy;
var BearerStrategy 			= require('passport-http-bearer').Strategy;
var User 					= require('./mongoose').UserModel;

// Facebook Stratergy
passport.use(new FacebookTokenStrategy({
    clientID: config.FACEBOOK_APP_ID,
    clientSecret: config.FACEBOOK_APP_SECRET,
    profileFields: ['id', 'displayName', 'emails', 'gender', 'name']
  },
  function(accessToken, refreshToken, profile, done) {
  	User.findOne({facebook_id: profile.id}, function(err, user){
  		if(err) { return done(error); }
  		// if no user create a new user
  		if(!user) { 
  			
  			console.log(profile);
  			user = new User({
  				email: profile.emails[0].value,
  				name: profile.name.givenName,
  				surname: profile.name.familyName,
  				facebook_id: profile.id,
  				facebook_access_token: accessToken,
  				facebook_refresh_token: refreshToken
  			});

  			user.save(function(err,user){
  				if(err) return console.log(err);
  				else console.log("New user - "+user.username);
  			});
  		}

  		return done(null,user);

  	})
  }
));

// BearerStrategy Stratergy - auth using token
passport.use(new BearerStrategy(
  function(token, done) {
    User.findOne({ facebook_access_token: token }, function (err, user) {
      if (err) { return done(err); }
      if (!user) { return done(null, false); }
      return done(null, user, { scope: 'all' });
    });
  }
));