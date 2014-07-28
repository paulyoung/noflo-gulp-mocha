{expect} = require 'chai'
noflo = require 'noflo'
SandboxedModule = require 'sandboxed-module'
sinon = require 'sinon'


describe 'RunMocha', ->

  fakeMochaStream = null
  stub = null


  component = null

  inStream = null
  options = null

  outStream = null


  beforeEach ->
    fakeMochaStream = 'fakeMochaStream'
    stub = sinon.stub().returns fakeMochaStream

    RunMocha = SandboxedModule.require '../components/RunMocha',
      requires:
        'coffee-script': ->
        'gulp-mocha': stub


    component = RunMocha.getComponent()

    inStream = noflo.internalSocket.createSocket()
    component.inPorts.stream.attach inStream

    options = noflo.internalSocket.createSocket()
    component.inPorts.options.attach options

    outStream = noflo.internalSocket.createSocket()
    component.outPorts.stream.attach outStream


  describe 'stream (in)', ->

    it 'should be required', ->
      required = component.inPorts.stream.isRequired()
      expect(required).to.be.true

    it 'should be an object', ->
      dataType = component.inPorts.stream.getDataType()
      expect(dataType).to.equal 'object'


    context 'when sent', ->

      it 'should have the stream from gulp-mocha piped to it', ->
        fakeStream = { pipe: (stream) -> stream }
        spy = sinon.spy fakeStream, 'pipe'

        inStream.send fakeStream

        expect(spy.calledOnce).to.be.true
        expect(spy.firstCall.args[0]).to.equal fakeMochaStream


      it 'should send the stream from pipe', (done) ->
        fakePipeStream = 'fakePipeStream'
        fakeStream = { pipe: (stream) -> fakePipeStream }

        outStream.on 'data', (data) ->
          try
            expect(data).to.equal fakePipeStream
            done()
          catch e
            done e

        inStream.send fakeStream


  describe 'options', ->

    it 'should not be required', ->
      required = component.inPorts.options.isRequired()
      expect(required).to.be.false

    it 'should be an object', ->
      dataType = component.inPorts.options.getDataType()
      expect(dataType).to.equal 'object'


    context 'when not sent', ->

      it 'should pass null to gulp-mocha', ->
        fakeStream = { pipe: (stream) -> stream }
        inStream.send fakeStream

        expect(stub.calledOnce).to.be.true
        expect(stub.firstCall.args[0]).to.be.null


    context 'when sent', ->

      it 'should be passed to gulp-mocha', ->
        optionsPacket = { reporter: 'spec' }
        fakeStream = { pipe: (stream) -> stream }

        options.send optionsPacket
        inStream.send fakeStream

        expect(stub.calledOnce).to.be.true
        expect(stub.firstCall.args[0]).to.deep.equal optionsPacket


  describe 'stream (out)', ->

    it 'should not be required', ->

      required = component.outPorts.stream.isRequired()
      expect(required).to.be.false

    it 'should be an object', ->

      dataType = component.outPorts.stream.getDataType()
      expect(dataType).to.equal 'object'
