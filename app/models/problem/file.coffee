mongoose = require "mongoose"
Schema = mongoose.Schema


fileSchema = new Schema
  name:
    type: String
    required: true

  contents:
    type: String
    required: true

  created:
    type: Date
    default: Date.now


File = mongoose.model 'File', fileSchema
module.exports = File