config   = require "../config/api.json"
passport = require "passport"

BasicStrategy = require("passport-http").BasicStrategy
ClientPasswordStrategy = require("passport-oauth2-client-password").Strategy
BearerStrategy = require("passport-http-bearer").Strategy


models       = require "../models"
User         = models.User
Client       = models.Client
AccessToken  = models.AccessToken
RefreshToken = models.RefreshToken


tokenAge = (token) ->
  return Math.round (Date.now() - token.created) / 1000


passport.use new BasicStrategy (username, password, done) ->
  Client.findOne {clientId: username}, (err, client) ->
    return done err if err
    return done null, false if !client
    return done null, false if client.clientSecret != password

    return done null, client


passport.use new ClientPasswordStrategy (clientId, clientSecret, done) ->
  Client.findOne {clientId: clientId}, (err, client) ->
    return done err if err
    return done null, false if !client
    return done null, false if client.clientSecret != clientSecret

    return done null, client


passport.use new BearerStrategy (accessToken, done) ->
  AccessToken.findOne {token: accessToken}, (err, token) ->
    return done err if err
    return done null, false if !token

    if tokenAge(token) > config.tokenLife
      AccessToken.remove {token: accessToken}, (err) ->
        return done err if err

      return done null, false, {message: "Token expired"}

    User.findById token.userId, (err, user) ->
      return done err if err
      return done null, false, {message: "Unknown user"} if !user

      info =
        scope: "*"

      done null, user, info

