mongoose = require "mongoose"
Schema = mongoose.Schema

exerciseSchema = new Schema
  title:
    type: String
    required: true

  language:
    type: String
    required: true

  summary:
    type: String
    required: true

  instructions:
    type: String
    required: true

  files: 
    type: [Schema.Types.ObjectId]
    ref: 'File'

  entrypoint:
    type: Schema.Types.ObjectId
    ref: 'File'

  correctness:
    type: String

Exercise = mongoose.model 'Exercise', exerciseSchema
module.exports = Exercise