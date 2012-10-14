###
Backbone.Statemanager, v0.0.1-alpha
Copyright (c)2012 Patrick Camacho and Mark Roseboom, Crashlytics
Distributed under MIT license
http://github.com/crashlytics/backbone.statemanager
###

Backbone.StateManager = ((Backbone, _) ->

  # Set our constructor - just a hash of states and a target
  StateManager = (@target, states, @options = {}) ->
    new Error 'Target must be defined' unless @target
    @states = {}

    # Add each state into the stateManager
    if _.isObject states then _.each states, (value, key) => @addState key, value

  # Give access to Backbone's extend method if they want it
  StateManager.extend = Backbone.View.extend

  # Extend the prototype to make functionality available for instantiations
  _.extend StateManager.prototype, Backbone.Events,
    addState : (state, callbacks) -> @states[state] = callbacks
    removeState : (state) -> delete @states[state]
    getCurrentState : -> @currentState

    initialize : (options = {}) ->
      # We trigger the initial state if it is set
      if initial = _.chain(@states).keys().find((state) => @states[state].initial).value()
        @triggerState initial, options

    triggerState : (state, options = {}) ->
      # return false unless matchedState = @_matchState state
      # currentState = @currentState

    #   # Load new state if:
    #   #   there is no current state
    #   #   the strings for the states don't match exactly and they have too
    #   #   they state objs don't match
    #   if not currentState or (currentState isnt state and options.exactMatch) or @states[currentState] isnt matchedState
    #     @exitState obj, currentState, matchedState, options
    #     @enterState obj, matchedState, currentState, options
    #     @
    #   else if @options.reEnter
    #     @exitState obj, currentState, matchedState, options
    #     @enterState obj, matchedState, currentState, options
    #     @
    #   else
    #     false

    # enterState : (obj, state, options) ->
    #   return false unless @states?[state] and _.isFunction @states[state].enter

    #   obj.onBeforeStateEnter? state, options
    #   obj.trigger 'before:state:enter', state, options
    #   @states[state].enter.apply obj, options
    #   @currentState = state
    #   obj.onStateEnter? state, options
    #   obj.trigger 'state:enter', state, options
    #   obj

    # exitState : (obj, state, options) ->
    #   return false unless @states?[state] and _.isFunction @states[state].exit

    #   obj.onBeforeStateExit? state, options
    #   obj.trigger 'before:state:exit', state, options
    #   @states[state].exit.apply obj, options
    #   @previousState = state
    #   delete @currentState
    #   obj.onStateExit? state, options
    #   obj.trigger 'state:exit', state, options
    #   obj

    # _matchState : (state) ->
    #   # We want to allow states to be defined the same way as routes with splats and :params
    #   return false unless @states
    #   stateRegex = Backbone.Router.prototype state
    #   _.chain(@states).keys().find((state) -> stateRegex.test state).value()

  # Function we can use to provide StateManager capabilities to views on construct
  StateManager.addStateManager = (target, options = {}) ->
    stateManager = new Backbone.StateManager target, target.states, options
    target.triggerState = -> stateManager.triggerState.apply stateManager, arguments
    target.getCurrentState = -> stateManager.getCurrentState()

    # Initialize the state manager, unless explictly told not to
    stateManager.initialize options if options.initialize or _.isUndefined options.initialize

    # Cleanup
    delete target.states

  StateManager
)(Backbone, _)