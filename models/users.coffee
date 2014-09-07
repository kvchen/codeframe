bcrypt   = require "bcrypt"
mongoose = require "mongoose"


Schema = mongoose.Schema

userSchema = new Schema
  username:
    type: String
    unique: true
    required: true

  passwordHash:
    type: String
    required: true

  created:
    type: Date
    default: Date.now


userSchema.methods.authenticate = (plainText) ->
  bcrypt.compare plainText, this.passwordHash, (err, res) ->
    return res


userSchema.methods.encryptPassword = (password) ->
  bcrypt.hash password, 10, (err, hash) ->
    return hash

userSchema.virtual "password"
  .set (password) ->
    this.passwordHash = this.encryptPassword password


User = mongoose.model "User", userSchema


clientSchema = new Schema
  name:
    type: String
    unique: true
    required: true
  
  clientId:
    type: String
    unique: true
    required: true

  clientSecret:
    type: String
    required: true


Client = mongoose.model "Client", clientSchema


accessTokenSchema = new Schema
  userId:
    type: String
    required: true

   clientId:
    type: String
    required: true
  
  token:
    type: String
    unique: true
    required: true
  
  created:
    type: Date,
    default: Date.now


AccessToken = mongoose.model "AccessToken", accessTokenSchema


refreshTokenSchema = new Schema
  userId:
    type: String
    required: true

  clientId:
    type: String
    required: true

  token:
    type: String
    unique: true
    required: true

  created:
    type: Date
    default: Date.now


RefreshToken = mongoose.model "RefreshToken", refreshTokenSchema

module.exports.User = User
module.exports.Client = Client
module.exports.AccessToken = AccessToken
module.exports.RefreshToken = RefreshToken