###
Backbone.Statemanager, v0.0.1-alpha
Copyright (c)2012 Patrick Camacho and Mark Roseboom, Crashlytics
Distributed under MIT license
http://github.com/crashlytics/backbone.statemanager
###

Backbone.StateManager = ((Backbone, _) ->
  # Set our constructor - just a hash of states
  StateManager = ->
    @states = {}
    @

  # Give access to Backbone's extend method if they want it
  StateManager.extend = Backbone.View.extend

  # Extend the prototype to make functionality available for instantiations
  _.extend StateManager.prototype,
    addState : (state, callbacks) -> @states[state] = callbacks
    removeState : (state) -> delete @states[state]

    triggerState : (obj, state, options = {}) ->
      return false unless matchedState = @_matchState state
      currentState = @currentState

      # Load new state if:
      #   there is no current state
      #   the strings for the states don't match exactly and they have too
      #   they state objs don't match
      if not currentState or (currentState isnt state and options.exactMatch) or @states[currentState] isnt matchedState
        @exitState obj, currentState, matchedState, options
        @enterState obj, matchedState, currentState, options
        @
      else if @options.reEnter
        @exitState obj, currentState, matchedState, options
        @enterState obj, matchedState, currentState, options
        @
      else
        false

    enterState : (obj, state, options) ->
      return false unless @states?[state] and _.isFunction @states[state].enter

      obj.onBeforeStateEnter? state, options
      obj.trigger 'before:state:enter', state, options
      @states[state].enter.apply obj, options
      @currentState = state
      obj.onStateEnter? state, options
      obj.trigger 'state:enter', state, options
      obj

    exitState : (obj, state, options) ->
      return false unless @states?[state] and _.isFunction @states[state].exit
      obj.onBeforeStateExit? state, options
      obj.trigger 'before:state:exit', state, options
      @states[state].exit.apply obj, options
      @previousState = state
      delete @currentState
      obj.onStateExit? state, options
      obj.trigger 'state:exit', state, options
      obj

    _matchState : (state) ->
      # We want to allow states to be defined the same way as routes with splats and :params
      return false unless @states
      stateRegex = Backbone.Router.prototype state
      _.chain(@states).keys().find((state) -> stateRegex.test state).value()

  # Function we can use to provide StateManager capabilities to views on construct
  StateManager.addStateManager = (target) ->
    stateManager = new Backbone.StateManager()
    # target.stateManager = stateManager
    target.addState = -> stateManager.addState.apply stateManager, arguments
    target.removeState = -> stateManager.removeState.apply stateManager, arguments
    target.triggerState = -> stateManager.triggerState.apply stateManager, _prependArguments(target, arguments)
    target.enterState = -> stateManager.enterState.apply stateManager, _prependArguments(target, arguments)
    target.exitState = -> stateManager.exitState.apply stateManager, _prependArguments(target, arguments)
    target.getState = -> stateManager.getState()
    target.getStates = -> stateManager._states

    # Add each state into the stateManager
    if _.isObject target.states
      _.each target.states, (key, value) -> StateManager.addState.call target.stateManager, key, value
      delete target.states

    # We need to set the initial state if it is declared
    target.triggerState target.initialState if target.initialState

  # Helper functions
  _prependArguments = (val, args) -> (args = Array.prototype.slice.call args).unshift(val) and args

  StateManager
)(Backbone, _)