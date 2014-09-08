oauth2orize = require "oauth2orize"
passport    = require "passport"
crypto      = require "crypto"

models       = require("../models").users
User         = models.User
AccessToken  = models.AccessToken
RefreshToken = models.RefreshToken

config = require "../config/api.json"

# initialize the OAuth2 server
server = oauth2orize.createServer()


# Removes old tokens and generates new access/refresh tokens
generateTokens = (modelData, done) ->
  RefreshToken.remove modelData, (err) ->
    return done err if err

  AccessToken.remove modelData, (err) ->
    return done err if err

  tokenValue = crypto.randomBytes(32).toString "base64"
  refreshTokenValue = crypto.randomBytes(32).toString "base64"

  modelData.token = tokenValue
  accessToken = new AccessToken(modelData)

  modelData.token = refreshTokenValue
  refreshToken = new RefreshToken(modelData)

  refreshToken.save (err) ->
    return done err if err

  accessToken.save (err) ->
    return done err if err
    done null, tokenValue, refreshTokenValue,
      "expires_in": config.tokenLife


# Allows you to exchange a user/pass for an access token
server.exchange oauth2orize.exchange.password (client, username, password, scope, done) ->
  User.findOne {username: username}, (err, user) ->
    return done(err) if err
    if !(user and user.checkPassword password)
      return done null, false

    modelData = 
      userId: user.userId
      clientId: client.clientId

    generateTokens modelData, done


# Allows you to exchange a refresh token for a new set of tokens
server.exchange oauth2orize.exchange.refreshToken (client, refreshToken, scope, done) ->
  RefreshToken.findOne {token: refreshToken, clientId: client.clientId}, (err, token) ->
    return done err if err
    return done(null, false) if !token

    User.findById token.userId, (err, user) ->
      return done err if err
      return done null, false if !user

      modelData = 
        userId: user.userId
        clientId: client.clientId

      generateTokens modelData, done


exports.token = [
  passport.authenticate ["basic", "oauth2-client-password"], {session: false}
  server.token()
  server.errorHandler()
]


