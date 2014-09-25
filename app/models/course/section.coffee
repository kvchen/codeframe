mongoose = require 'mongoose'
exercise = require './exercise'

Schema = mongoose.Schema

sectionSchema = new Schema
  title:
    type: String
    required: true

  exercises:
    type: [Schema.Types.ObjectId]
    ref: 'Exercise'

Section = mongoose.model 'Section', sectionSchema
module.exports = Section