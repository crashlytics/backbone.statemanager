###
Backbone.Statemanager, v /* @echo VERSION */
Copyright (c)/* @echo YEAR */ /* @echo AUTHOR */
Distributed under /* @echo LICENSE */ license
/* @echo REPO */
###

factory = (Backbone, _) ->
  throw new ReferenceError('Backbone required') unless Backbone
  throw new ReferenceError('Underscore required') unless _

  # Set our constructor - just a States object
  StateManager = (states, @options = {}) ->
    @states = new StateManager.States states
    @

  # Give access to Backbone's extend method if they want it
  StateManager.extend = Backbone.View.extend

  # Extend the prototype to make functionality available for instantiations
  _.extend StateManager.prototype, Backbone.Events,

    getCurrentState : -> @currentState

    addState : (name, definition) ->
      @states.add name, definition
      @trigger 'add:state', name

    removeState : (name) ->
      @states.remove name
      @trigger 'remove:state', name

    initialize : (options = {}) ->
      # We trigger the initial state if it is set
      @triggerState initial, options if initial = @states.findInitial()

    triggerState : (name, options = {}) ->
      unless name is @currentState and not options.reEnter
        _.extend options, toState : name, fromState : @currentState
        @exitState options if @currentState
        @enterState name, options
      else
        false

    enterState : (name, options = {}) ->
      unless (state = @states.find name) and _.isFunction state.enter
        return false

      @trigger 'before:enter:state', name, state, options

      # Find the the state we will be transitioning to and if it has a
      # onBeforeEnterFrom method, call it
      state.findTransition('onBeforeEnterFrom', options.fromState)? options

      state.enter options

      state.findTransition('onEnterFrom', options.fromState)? options

      @trigger 'enter:state', name, state, options

      @currentState = name
      @

    exitState : (options = {}) ->
      unless (state = @states.find @currentState) and _.isFunction state.exit
        return false

      @trigger 'before:exit:state', @currentState, state, options

      state.findTransition('onBeforeExitTo', options.toState)? options

      state.exit options

      state.findTransition('onExitTo', options.toState)? options

      @trigger 'exit:state', @currentState, state, options
      delete @currentState
      @

  # Setup our states object
  StateManager.States = (states) ->
    @states = {}
    if states and _.isObject states
      _.each states, (value, key) => @add key, value
    @

  _.extend StateManager.States.prototype,
    add : (name, definition) ->
      return false unless _.isString(name) and _.isObject definition
      @states[name] = new StateManager.State name, definition

    remove : (name) ->
      return false unless _.isString name
      delete @states[name]

    find : (name) ->
      return false unless _.isString name
      _.chain(@states).find((state) -> state.matchName name).value()

    findInitial : -> (_.find @states, (value, name) -> value.initial)?.name

  # Setup our State object
  StateManager.State = (@name, options) ->
    _.extend @, options
    @regExpName = StateManager.State._regExpStateConversion @name
    @

  _.extend StateManager.State.prototype,
    matchName : (name) -> @regExpName.test name

    findTransition : (type, name) ->
      return false unless @transitions and _.isString(name) and _.isString type
      _.find @transitions, (value, key) ->
        if key.indexOf("#{ type }:") is 0
          if inverse = key.indexOf(':not:') is type.length
            key = key.slice type.length + 5
          else
            key = key.slice type.length + 1

          StateManager.State._regExpStateConversion(key).test(name) isnt inverse


  # Helper to convert state names into RegExp for matching
  StateManager.State._regExpStateConversion = (name) ->
    name = name.replace(/[-[\]{}()+?.,\\^$|#\s]/g, '\\$&')
                .replace(/:\w+/g, '([^\/]+)')
                .replace(/\*\w+/g, '(.*?)')
    new RegExp "^#{ name }$"

  # Function we can use to provide StateManager capabilities to
  # views on construct
  StateManager.addStateManager = (target, options = {}) ->
    new Error 'Target must be defined' unless target
    # Allow statest to be a method (helpful for prototype definitions that get
    # mutated with _.bind)
    states = _.result target, 'states'

    _deepBindAll states, target
    stateManager = new Backbone.StateManager states, options
    target.stateManager = stateManager

    target.triggerState = _.bind stateManager.triggerState, stateManager
    target.getCurrentState = -> stateManager.getCurrentState()

    # Initialize the state manager, unless explictly told not to
    if options.initialize or _.isUndefined options.initialize
      stateManager.initialize options

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

  Backbone.StateManager = StateManager

((root, factory) ->
  # Set up Backbone.Statemanager appropriately for the environment.
  # Start with AMD.
  if typeof define is 'function' and define.amd
    define ['backbone', 'underscore'], (Backbone, _) ->
      factory Backbone, _

  # Next for Node.js or CommonJS
  else if typeof exports isnt 'undefined'
    Backbone = require 'backbone'
    _ = require 'underscore'

    StateManager = factory Backbone, _

    if typeof module isnt 'undefined' and module.exports
      module.exports = StateManager
    else
      exports.StateManger = StateManager

  # Finally, as a browser global.
  else
    root.StateManager = factory root.Backbone, root._
)(@, factory)
