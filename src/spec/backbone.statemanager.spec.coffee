describe 'Backbone.StateManager', =>
  beforeEach => @states = _.clone spec.helper.states

  afterEach => delete @states

  it 'exists under Backbone.StateManager', -> expect(Backbone.StateManager).toBeDefined()

  describe 'constructor', =>
    it 'creates a states object', =>
      stateManager = new Backbone.StateManager
      expect(stateManager.states).toBeDefined()

    it 'calls addState with passed state', =>
      spyOn Backbone.StateManager.States.prototype, 'add'
      stateManager = new Backbone.StateManager @states
      expect(stateManager.states.add).toHaveBeenCalledWith 'noTransitions', jasmine.any Object

  describe 'prototype', =>
    beforeEach => @stateManager = new Backbone.StateManager @states

    afterEach => delete @stateManager

    describe 'initialize', =>
      it 'calls triggerState on the first state found that has initial : true set on it', =>
        spyOn Backbone.StateManager.prototype, 'triggerState'

        @stateManager.initialize()
        expect(@stateManager.triggerState).toHaveBeenCalledWith 'withInitial', jasmine.any Object

    describe 'addState', =>
      beforeEach => spyOn @stateManager.states, 'add'

      it 'sets the state passed to states with the states callback', =>
        @stateManager.addState 'noTransitions', @states.noTransitions
        expect(@stateManager.states.add).toHaveBeenCalled()
        expect(@stateManager.states.states.noTransitions).toEqual @states.noTransitions

      it 'triggers remove:state and passes state name', =>
        spyOn @stateManager, 'trigger'
        @stateManager.addState 'noTransitions'
        expect(@stateManager.trigger).toHaveBeenCalledWith 'add:state', 'noTransitions'

    describe 'removeState', =>
      beforeEach => spyOn @stateManager.states, 'remove'

      it 'removes the state', =>
        @stateManager.removeState 'noTransitions'
        expect(@stateManager.states.remove).toHaveBeenCalled()
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
        spyOn @stateManager, 'enterState'
        spyOn @stateManager, 'exitState'

      it 'calls exitState for the current state if it exists with new state name', =>
        @stateManager.currentState = 'bar'
        @stateManager.triggerState 'foo'
        expect(@stateManager.exitState).toHaveBeenCalledWith toState : 'foo', fromState : 'bar'

      it 'calls enterState for the new state', =>
        @stateManager.triggerState 'foo'
        expect(@stateManager.enterState).toHaveBeenCalledWith 'foo', jasmine.any Object

      describe 'the current state is the same as the new state', =>
        beforeEach => @stateManager.currentState = 'foo'

        it 'does nothing if options.reEnter is not set', =>
          expect(@stateManager.triggerState 'foo').toEqual false
          expect(@stateManager.exitState).not.toHaveBeenCalled()
          expect(@stateManager.enterState).not.toHaveBeenCalled()

        it 're-enters the state if optoins.reEnter is set', =>
          expect(@stateManager.triggerState 'foo', reEnter : true).not.toEqual false
          expect(@stateManager.exitState).toHaveBeenCalledWith jasmine.any Object
          expect(@stateManager.enterState).toHaveBeenCalledWith 'foo', jasmine.any Object


    describe 'exitState', =>
      beforeEach => spyOn @stateManager.states, 'find'

      describe 'with invalid parameters', =>

        it 'returns false if the states exit property is not a method', =>
          @stateManager.states.find.andReturn @states.nonMethodExit
          expect(@stateManager.exitState()).toBeFalsy()

        it 'returns false if the currentState does not exist', =>
          @stateManager.states.find.andReturn false
          expect(@stateManager.exitState()).toBeFalsy()

      describe 'with valid parameters', =>

        beforeEach =>
          spyOn @stateManager, 'trigger'
          spyOn @states.noTransitions, 'exit'
          @stateManager.states.find.andReturn @states.noTransitions
          @stateManager.currentState = 'noTransitions'
          @stateManager.exitState()

        afterEach => delete @stateManager.currentState

        it 'triggers before:exit:state', =>
          expect(@stateManager.trigger)
            .toHaveBeenCalledWith 'before:exit:state', 'noTransitions', @states.noTransitions, jasmine.any Object

        it 'calls the exit method on the state', =>
          expect(@states.noTransitions.exit).toHaveBeenCalledWith jasmine.any Object

        it 'triggers exit:state', =>
          expect(@stateManager.trigger)
            .toHaveBeenCalledWith 'exit:state', 'noTransitions', @states.noTransitions, jasmine.any Object

        it 'deletes the currentState', => expect(@stateManager.currentState).toBeUndefined()

      describe 'on states with transitions set', =>
        beforeEach =>
          spyOn(@states.exitTransition, 'findTransition').andReturn true
          spyOn @states.exitTransition.transitions, 'onBeforeExitTo:enterTransition'
          spyOn @states.exitTransition.transitions, 'onExitTo:enterTransition'
          @stateManager.states.find.andReturn @states.exitTransition
          @stateManager.currentState = 'exitTransition'
          @stateManager.exitState toState : 'enterTransition'

        afterEach => delete @stateManager.currentState

        it 'calls onBeforeExitTo if it exists for the state passed', =>
          expect(@states.exitTransition.findTransition).toHaveBeenCalledWith 'onBeforeExitTo', 'enterTransition'
          expect(@states.exitTransition.transitions['onBeforeExitTo:enterTransition']).toHaveBeenCalledWith jasmine.any(Object)

        it 'calls onExitTo if it exists for the state passed', =>
          expect(@states.exitTransition.findTransition).toHaveBeenCalledWith 'onExitTo', 'enterTransition'
          expect(@states.exitTransition.transitions['onExitTo:enterTransition']).toHaveBeenCalledWith jasmine.any(Object)

    describe 'enterState', =>
      beforeEach => spyOn @stateManager.states, 'find'

      describe 'with invalid parameters', =>

        it 'returns false if the states enter property is not a method', =>
          @stateManager.states.find.andReturn @states.nonMethodEnter
          expect(@stateManager.enterState 'noTransitions').toBeFalsy()

        it 'returns false if the currentState does not exist', =>
          @stateManager.states.find.andReturn false
          expect(@stateManager.enterState 'noTransitions').toBeFalsy()

      describe 'with valid parameters', =>

        beforeEach =>
          spyOn @stateManager, 'trigger'
          spyOn @states.noTransitions, 'enter'
          @stateManager.states.find.andReturn @states.noTransitions
          @stateManager.currentState = 'noTransitions'
          @stateManager.enterState 'noTransitions'

        afterEach => delete @stateManager.currentState

        it 'triggers before:enter:state', =>
          expect(@stateManager.trigger)
            .toHaveBeenCalledWith 'before:enter:state', 'noTransitions', @states.noTransitions, jasmine.any Object

        it 'calls the enter method on the state', =>
          expect(@states.noTransitions.enter).toHaveBeenCalledWith jasmine.any Object

        it 'triggers enter:state', =>
          expect(@stateManager.trigger)
            .toHaveBeenCalledWith 'enter:state', 'noTransitions', @states.noTransitions, jasmine.any Object

        it 'sets the currentState', => expect(@stateManager.currentState).toEqual 'noTransitions'

      describe 'transitions', =>


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