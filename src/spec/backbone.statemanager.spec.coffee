describe 'Backbone.StateManager', ->

  it 'exists under Backbone.StateManager', -> expect(Backbone.StateManager).toBeDefined()

  describe 'constructor', ->

    it 'creates a states object', ->
      stateManager = new Backbone.StateManager
      expect(stateManager.states).toBeDefined()

    it 'calls addState with passed state', ->
      spyOn Backbone.StateManager.prototype, 'addState'
      stateManager = new Backbone.StateManager foo : ->
      expect(stateManager.addState).toHaveBeenCalledWith 'foo', jasmine.any(Function)

  describe 'prototype', ->

    describe 'initialize', ->

      it 'calls triggerState on the first state found that has initial : true set on it', ->
        states =
          foo :
            initial : true
          bar : {}

        spyOn Backbone.StateManager.prototype, 'triggerState'
        stateManager = new Backbone.StateManager states

        stateManager.initialize()
        expect(stateManager.triggerState).toHaveBeenCalledWith 'foo', jasmine.any Object

    describe 'addState', ->

      it 'sets the state passed to states with the states callback', ->
        stateManager = new Backbone.StateManager
        stateManager.addState 'foo', bar = ->
        expect(stateManager.states.foo).toEqual bar

    describe 'removeState', ->

      it 'removes the state', ->
        stateManager = new Backbone.StateManager
        stateManager.states = foo : ->
        stateManager.removeState 'foo'
        expect(stateManager.states.foo).toBeUndefined()

     describe 'getCurrentState', ->

      it 'returns the current state', ->
        stateManager = new Backbone.StateManager
        stateManager.currentState = foo = {}
        currentState = stateManager.getCurrentState()
        expect(currentState).toEqual foo

  describe 'addStateManager', ->

    it 'creates a new StateManager', ->
      StateManager = Backbone.StateManager
      spy = spyOn(Backbone, 'StateManager').andCallThrough()
      spy.__proto__ = StateManager
      spy.prototype = StateManager.prototype
      target = states : foo : 'bar'
      Backbone.StateManager.addStateManager target
      expect(Backbone.StateManager).toHaveBeenCalledWith jasmine.any(Object), jasmine.any(Object)

    it 'binds all of targets states methods to the target', ->
      spyOn _, 'bind'
      target = states : foo : ->
      Backbone.StateManager.addStateManager target
      expect(_.bind).toHaveBeenCalledWith jasmine.any(Function), target

    it 'allows callthrough on the target for triggerState', ->
      target = foo : 'bar'
      spyOn Backbone.StateManager.prototype, 'triggerState'

      Backbone.StateManager.addStateManager target
      expect(target.triggerState).toBeDefined()

      target.triggerState 'foo'
      expect(Backbone.StateManager.prototype.triggerState).toHaveBeenCalledWith 'foo'

    it 'allows callthrough on the target for getCurrentState', ->
      target = {}
      spyOn Backbone.StateManager.prototype, 'getCurrentState'

      Backbone.StateManager.addStateManager target
      expect(target.getCurrentState).toBeDefined()

      target.getCurrentState()
      expect(Backbone.StateManager.prototype.getCurrentState).toHaveBeenCalled()

    it 'calls initialize on the state manager', ->
      spyOn Backbone.StateManager.prototype, 'initialize'

      Backbone.StateManager.addStateManager {}
      expect(Backbone.StateManager.prototype.initialize).toHaveBeenCalled()

    it 'does not call initialize if options.initialize is set to false(y)', ->
      spyOn Backbone.StateManager.prototype, 'initialize'

      _.each [false, null, 0], (value) ->
        Backbone.StateManager.addStateManager {}, { initialize : value }
        expect(Backbone.StateManager.prototype.initialize).not.toHaveBeenCalled()

      Backbone.StateManager.addStateManager {}, { initialize : undefined }
      expect(Backbone.StateManager.prototype.initialize).toHaveBeenCalled()


