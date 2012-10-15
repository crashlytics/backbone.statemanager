describe 'Backbone.StateManager', =>

  beforeEach => @states = _.clone spec.helper.states

  afterEach => delete @states

  it 'exists under Backbone.StateManager', -> expect(Backbone.StateManager).toBeDefined()

  describe 'constructor', =>

    it 'creates a states object', =>
      stateManager = new Backbone.StateManager
      expect(stateManager.states).toBeDefined()

    it 'calls addState with passed state', =>
      spyOn Backbone.StateManager.prototype, 'addState'
      stateManager = new Backbone.StateManager @states
      expect(stateManager.addState).toHaveBeenCalledWith 'noTransitions', jasmine.any Object

  describe 'prototype', =>

    describe 'initialize', =>

      it 'calls triggerState on the first state found that has initial : true set on it', =>
        spyOn Backbone.StateManager.prototype, 'triggerState'
        stateManager = new Backbone.StateManager @states

        stateManager.initialize()
        expect(stateManager.triggerState).toHaveBeenCalledWith 'withInitial', jasmine.any Object

    describe 'addState', =>

      beforeEach =>
        @stateManager = new Backbone.StateManager
        @stateManager.states = @states

      afterEach => delete @stateManager

      it 'sets the state passed to states with the states callback', =>
        @stateManager.addState 'noTransitions', @states.noTransitions
        expect(stateManager.states.noTransitions).toEqual @states.noTransitions

      it 'triggers remove:state and passes state name', =>
        spyOn @stateManager, 'trigger'
        @stateManager.addState 'noTransitions'
        expect(stateManager.trigger).toHaveBeenCalledWith 'add:state', 'noTransitions'

    describe 'removeState', =>

      beforeEach =>
        @stateManager = new Backbone.StateManager
        @stateManager.states = @states

      afterEach => delete @stateManager

      it 'removes the state', =>
        @stateManager.removeState 'noTransitions'
        expect(@stateManager.states.noTransitions).toBeUndefined()

      it 'triggers remove:state and passes state name', =>
        spyOn @stateManager, 'trigger'
        @stateManager.removeState 'noTransitions'
        expect(stateManager.trigger).toHaveBeenCalledWith 'remove:state', 'noTransitions'

     describe 'getCurrentState', =>

      it 'returns the current state', =>
        stateManager = new Backbone.StateManager
        stateManager.currentState = @states.noTransitions
        currentState = stateManager.getCurrentState()
        expect(currentState).toEqual @states.noTransitions

  describe 'addStateManager', =>

    it 'creates a new StateManager', =>
      StateManager = Backbone.StateManager
      spy = spyOn(Backbone, 'StateManager').andCallThrough()
      spy.__proto__ = StateManager
      spy.prototype = StateManager.prototype
      target = states : @states
      Backbone.StateManager.addStateManager target
      expect(Backbone.StateManager).toHaveBeenCalledWith jasmine.any(Object), jasmine.any(Object)

    it 'binds all of targets states methods to the target', =>
      spyOn _, 'bind'
      target = states : @states
      Backbone.StateManager.addStateManager target
      expect(_.bind).toHaveBeenCalledWith jasmine.any(Function), target

    it 'allows callthrough on the target for triggerState', =>
      target = states : @states
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

    it 'does not call initialize if options.initialize is set to false(y)', =>
      spyOn Backbone.StateManager.prototype, 'initialize'

      _.each [false, null, 0], (value) ->
        Backbone.StateManager.addStateManager {}, { initialize : value }
        expect(Backbone.StateManager.prototype.initialize).not.toHaveBeenCalled()

      Backbone.StateManager.addStateManager {}, { initialize : undefined }
      expect(Backbone.StateManager.prototype.initialize).toHaveBeenCalled()