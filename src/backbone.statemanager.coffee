###
Backbone.Statemanager, v0.0.1-alpha
Copyright (c)2012 Patrick Camacho and Mark Roseboom, Crashlytics
Distributed under MIT license
http://github.com/crashlytics/backbone.statemanager
###

Backbone.StateManager = ((Backbone, _) ->

  # Set our constructor - just a States object
  StateManager = (states, @options = {}) ->
    @states = new StateManager.States states
    @

  # Give access to Backbone's extend method if they want it
  StateManager.extend = Backbone.View.extend

  # Extend the prototype to make functionality available for instantiations
  _.extend StateManager.prototype, Backbone.Events,

    getCurrentState : -> @currentState

    addState : (name, callbacks) ->
      @states.add name, callbacks
      @trigger 'add:state', name

    removeState : (name) ->
      @states.remove name
      @trigger 'remove:state', name

    initialize : (options = {}) ->
      # We trigger the initial state if it is set
      @triggerState initial, options if initial = @states.findInitial()

    triggerState : (state, options = {}) ->
      unless state is @currentState and not options.reEnter
        @exitState options if @currentState
        @enterState state, options
      else
        false

    enterState : (state, options = {}) ->
      return false unless (matchedState = @states.find @currentState) and _.isFunction matchedState.enter
      @trigger 'before:enter:state', state, matchedState, options
      matchedState.enter options
      @trigger 'enter:state', @currentState, matchedState, options
      @currentState = state
      @

    exitState : (options = {}) ->
      return false unless (matchedState = @states.find @currentState) and _.isFunction matchedState.exit
      @trigger 'before:exit:state', @currentState, matchedState, options
      matchedState.exit options
      @trigger 'exit:state', @currentState, matchedState, options
      delete @currentState
      @

  # Setup our states object
  StateManager.States = (states) ->
    @states = {}
    if states and _.isObject states then _.each states, (value, key) => @add key, value
    @

  _.extend StateManager.States.prototype,
    add : (name, callbacks) ->
      return false unless _.isString(name) and _.isObject callbacks
      callbacks.regExp = StateManager.States._regExpStateConversion name
      @states[name] = callbacks

    remove : (name) ->
      return false unless _.isString name
      delete @states[name]

    find : (name) ->
      return false unless _.isString name
      _.chain(@states).find((state) -> state.regExp?.test name).value()

    findInitial : -> _.find @states, (value, name) => value.initial

  # Helper to convert state names into RegExp for matching
  StateManager.States._regExpStateConversion = (name) ->
    name = name.replace(/[-[\]{}()+?.,\\^$|#\s]/g, '\\$&')
                   .replace(/:\w+/g, '([^\/]+)')
                   .replace(/\*\w+/g, '(.*?)')
    new RegExp "^#{ name }$"

  # Function we can use to provide StateManager capabilities to views on construct
  StateManager.addStateManager = (target, options = {}) ->
    new Error 'Target must be defined' unless target
    _deepBindAll target.states, target
    stateManager = new Backbone.StateManager target.states, options
    target.triggerState = -> stateManager.triggerState.apply stateManager, arguments
    target.getCurrentState = -> stateManager.getCurrentState()

    # Initialize the state manager, unless explictly told not to
    stateManager.initialize options if options.initialize or _.isUndefined options.initialize

    # Cleanup
    delete target.states

  # Recursively finds methods in an object and binds them to target
  _deepBindAll = (obj) ->
    target = _.last arguments
    _.each obj, (value, key) ->
      if _.isFunction value
        obj[key] = _.bind value, target
      else if _.isObject value
        obj[key] = _deepBindAll(value, target)
    obj

  StateManager
)(Backbone, _)