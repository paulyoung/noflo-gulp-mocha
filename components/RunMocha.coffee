{Component, InPorts, OutPorts} = require 'noflo'
mocha = require 'gulp-mocha'


class RunMocha extends Component

  description: 'Equivalent to gulp-mocha'
  icon: 'coffee'

  constructor: ->
    @options = null

    @inPorts = new InPorts
      options:
        datatype: 'object'
        description: 'The options parameter to be passed to gulp-mocha'

      stream:
        datatype: 'object'
        description: 'The stream to be piped to gulp-mocha'
        required: true

    @outPorts = new OutPorts
      stream:
        datatype: 'object'
        description: 'The stream returned from piping to gulp-mocha'


    @inPorts.options.on 'data', (data) =>
      @options = data

    @inPorts.stream.on 'data', (data) =>
      stream = data.pipe mocha(@options)
      @outPorts.stream.send stream


module.exports =
  getComponent: -> new RunMocha
