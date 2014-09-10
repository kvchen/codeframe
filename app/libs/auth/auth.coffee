config   = require "../config/api.json"
passport = require "passport"

BasicStrategy = require("passport-http").BasicStrategy
ClientPasswordStrategy = require("passport-oauth2-client-password").Strategy
BearerStrategy = require("passport-http-bearer").Strategy


models       = require("../models").users
User         = models.User
Client       = models.Client
AccessToken  = models.AccessToken
RefreshToken = models.RefreshToken


tokenAge = (token) ->
  return Math.round (Date.now() - token.created) / 1000


###
BasicStrategy & ClientPasswordStrategy

These strategies are used to authenticate registered OAuth clients.  They are
employed to protect the `token` endpoint, which consumers use to obtain
access tokens.  The OAuth 2.0 specification suggests that clients use the
HTTP Basic scheme to authenticate.  Use of the client password strategy
allows clients to send the same credentials in the request body (as opposed
to the `Authorization` header).  While this approach is not recommended by
the specification, in practice it is quite common.
###

passport.use new BasicStrategy (username, password, done) ->
  Client.findOne {clientID: username}, (err, client) ->
    return done err if err
    return done null, false if !client
    return done null, false if client.clientSecret != password

    return done null, client


passport.use new ClientPasswordStrategy (clientID, clientSecret, done) ->
  Client.findOne {clientID: clientID}, (err, client) ->
    return done err if err
    return done null, false if !client
    return done null, false if client.clientSecret != clientSecret

    return done null, client


###
BearerStrategy

This strategy is used to authenticate users based on an access token (aka a
bearer token).  The user must have previously authorized a client
application, which is issued an access token to make requests on behalf of
the authorizing user.
###

passport.use new BearerStrategy (accessToken, done) ->
  AccessToken.findOne {token: accessToken}, (err, token) ->
    return done err if err
    return done null, false if !token

    if Math.round((Date.now() - token.created) / 1000) > config.tokenLife
      AccessToken.remove {token: accessToken}, (err) ->
        return done err if err

      return done null, false, {message: "Token expired"}

    User.findByID token.userID, (err, user) ->
      return done err if err
      return done null, false, {message: "Unknown user"} if !user

      info =
        scope: "*"

      done null, user, info

