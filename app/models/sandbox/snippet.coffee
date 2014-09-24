mongoose = require 'mongoose'
shortId = require 'shortid'

Schema = mongoose.Schema

snippetSchema = new Schema
  _id: 
    type: String
    unique: true
    default: shortId.generate

  contents:
    type: String
    required: true

  created:
    type: Date
    default: Date.now

  private:
    type: Boolean
    default: false
    required: true

Snippet = mongoose.model "Snippet", snippetSchema
module.exports = Snippet