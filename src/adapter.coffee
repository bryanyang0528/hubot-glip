try
  { Adapter, TextMessage, User } = require 'hubot'
catch
  prequire = require('parent-require')
  { Adapter, TextMessage, User } = prequire 'hubot'

GlipClient = require './bot'


class GlipAdapter extends Adapter

  constructor: ->
    super
    @robot.logger.info "Constructor"

    @client = new GlipClient({
      host: 'glip.com',
      port: 443,
      user: process.env.HUBOT_GLIP_EMAIL,
      password: process.env.HUBOT_GLIP_PASSWORD
    })

    @client.on 'message', (type, data) =>
      @robot.logger.info type + ' : ' + JSON.stringify(data, null, 4)
      if (type == @client.type_ids.TYPE_ID_POST && data.text)
        user = new User data.group_id, name: 'Sample User'
        message = new TextMessage user, data.text, 'MSG-' + data._id
        @robot.receive message

  send: (envelope, strings...) ->
    @robot.logger.info 'send ' + JSON.stringify(envelope, null, 4) + '\n\n' + strings.join('\n\n')
    for str in strings
      @client.post envelope.user.id, str

  reply: (envelope, strings...) ->
    @robot.logger.info 'reply ' + JSON.stringify(envelope, null, 4) + '\n\n' + strings.join('\n\n')
    for str in strings
      @client.post envelope.user.id, str

  run: ->
    @robot.logger.info "Run"

    @client.start()

    @client.on 'started', =>
      @emit "connected"


module.exports = GlipAdapter
