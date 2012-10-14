describe 'Backbone.StateManager', ->

  it 'exists under Backbone.StateManager', -> expect(Backbone.StateManager).toBeDefined()

  describe 'addStateManager', ->

    it 'creates a new StateManager', ->
      StateManager = Backbone.StateManager
      spy = spyOn(Backbone, 'StateManager').andCallThrough()
      spy.__proto__ = StateManager
      spy.prototype = StateManager.prototype
      Backbone.StateManager.addStateManager {}
      expect(Backbone.StateManager).toHaveBeenCalled()

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

  describe 'prototype', ->
    describe 'initialize', ->

      it 'calls triggerState on the first state found that has initial : true set on it', ->
        target = {}
        states =
          foo :
            initial : true
          bar : {}

        spyOn Backbone.StateManager.prototype, 'triggerState'
        stateManager = new Backbone.StateManager target, states

        stateManager.initialize()
        expect(stateManager.triggerState).toHaveBeenCalledWith 'foo', jasmine.any Object