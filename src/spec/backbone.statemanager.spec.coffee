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

    beforeEach => @stateManager = new Backbone.StateManager @states

    afterEach => delete @stateManager

    describe 'initialize', =>

      it 'calls triggerState on the first state found that has initial : true set on it', =>
        spyOn Backbone.StateManager.prototype, 'triggerState'

        @stateManager.initialize()
        expect(@stateManager.triggerState).toHaveBeenCalledWith 'withInitial', jasmine.any Object

    describe 'addState', =>

      it 'sets the state passed to states with the states callback', =>
        @stateManager.addState 'noTransitions', @states.noTransitions
        expect(@stateManager.states.noTransitions).toEqual @states.noTransitions

      it 'triggers remove:state and passes state name', =>
        spyOn @stateManager, 'trigger'
        @stateManager.addState 'noTransitions'
        expect(@stateManager.trigger).toHaveBeenCalledWith 'add:state', 'noTransitions'

    describe 'removeState', =>

      it 'removes the state', =>
        @stateManager.removeState 'noTransitions'
        expect(@stateManager.states.noTransitions).toBeUndefined()

      it 'triggers remove:state and passes state name', =>
        spyOn @stateManager, 'trigger'
        @stateManager.removeState 'noTransitions'
        expect(@stateManager.trigger).toHaveBeenCalledWith 'remove:state', 'noTransitions'

     describe 'getCurrentState', =>

      it 'returns the current state', =>
        @stateManager.currentState = @states.noTransitions
        expect(@stateManager.getCurrentState()).toEqual @states.noTransitions

    describe 'triggerState', =>

      beforeEach =>
        spyOn(@stateManager, '_matchState').andReturn true
        spyOn @stateManager, 'enterState'
        spyOn @stateManager, 'exitState'

      it 'checks that the state exists', =>
        @stateManager.triggerState 'foo'
        expect(@stateManager._matchState).toHaveBeenCalledWith 'foo'

      it 'aborts if the state does not exist', =>
        @stateManager._matchState.andReturn false
        expect(@stateManager.triggerState 'foo').toEqual false
        expect(@stateManager._matchState).toHaveBeenCalledWith 'foo'
        expect(@stateManager.exitState).not.toHaveBeenCalled()
        expect(@stateManager.enterState).not.toHaveBeenCalled()

      it 'calls exitState for the current state if it exists', =>
        @stateManager.currentState = 'bar'
        @stateManager.triggerState 'foo'
        expect(@stateManager.exitState).toHaveBeenCalledWith 'bar', jasmine.any Object

      it 'calls enterState for the new state if it exists', =>
        @stateManager.triggerState 'foo'
        expect(@stateManager.enterState).toHaveBeenCalledWith 'foo', jasmine.any Object

      describe 'the current state is the same as the new state', =>

        it 'does nothing unless options.reEnter is set', =>
          @stateManager._matchState.andReturn @states.noTransitions
          @stateManager.currentState = 'noTransitions'
          expect(@stateManager.triggerState 'noTransitions').toEqual false
          expect(@stateManager._matchState).toHaveBeenCalledWith 'noTransitions'
          expect(@stateManager.exitState).not.toHaveBeenCalled()
          expect(@stateManager.enterState).not.toHaveBeenCalled()

          expect(@stateManager.triggerState 'noTransitions', reEnter : true).not.toEqual false
          expect(@stateManager._matchState).toHaveBeenCalledWith 'noTransitions'
          expect(@stateManager.exitState).toHaveBeenCalledWith 'noTransitions', jasmine.any Object
          expect(@stateManager.enterState).toHaveBeenCalledWith 'noTransitions', jasmine.any Object




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