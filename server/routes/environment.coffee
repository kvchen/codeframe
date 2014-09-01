container   = require "../libs/container"
fs          = require "fs-extra"
path        = require "path"
sanitize    = require "sanitize-filename"
uuid        = require "node-uuid"
winston     = require "winston"

exports.run = (req, res, next) ->
    env = req.body

    volume = path.join path.dirname(require.main.filename), 'uploads', uuid.v4()
    fs.ensureDirSync volume

    for file in env.files
        filename = sanitize file.name
        code = file.code

        fs.writeFileSync path.join(volume, filename), file.code

    container.run env.language, env.entrypoint, volume, (err, output) ->
        if err
            res.json
                status: "failure"
                reason: err
        else
            res.json
                status: "success"
                output: output