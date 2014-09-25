mongoose = require 'mongoose'
section = require './section'

Schema = mongoose.Schema

courseSchema = new Schema
  title:
    type: String
    required: true

  sections:
    type: [Schema.Types.ObjectId]
    ref: 'Section'

Course = mongoose.model 'Course', courseSchema
module.exports = Course