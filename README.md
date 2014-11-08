# Backbone.StateManager

Simple, powerful state management for Backbone.js

## About StateManager

Backbone.StateManager is a module for Backbone.js that adds the ability to easily
manage and utilize states in any size JavaScript application. It can be used as
a stand alone object or in conjunction with a target object through its `addStateManager`
method.

### Key Benefits

* Modular definitions of states
* Sub/pub architecture with Backbone.Events
* Support for transition events between states
* RegExp matching for states and transitions
* Easy to attach to any object

## Compatibility and Requirements

Backbone.StateManager currently has the following dependencies:

* [Underscore](http://underscorejs.org) v1.7.0
* [Backbone](http://backbonejs.org) v1.1.2

## Source Code and Downloads

Backbone.StateManager is written in CoffeeScript. You can download the raw source code
from the "src" folder or download the JavaScript build in the main directory.

The latest stable releases can be found at the links:

* Development: [backbone.statemanager.js](https://raw.github.com/crashlytics/backbone.statemanager/master/backbone.statemanager.js)

* Production: [backbone.statemanager.min.js](https://raw.github.com/crashlytics/backbone.statemanager/master/backbone.statemanager.min.js)

## Getting Started

Backbone.StateManager constructor takes two arguments, a state object and an options object, but neither is required. Passed in states will be automatically added and the options are set as an instance property.

```coffee
  stateManager = new Backbone.StateManager
  # or
  states =
    foo :
      enter : -> console.log 'enter bar'
      exit : -> console.log 'exit foo'
    bar :
      enter : -> console.log 'enter bar'
      exit : -> console.log 'exit bar'

  stateManager = new Backbone.StateManager states
```

### Defining a State

A state is intended to be as modular as possible, so each state is expected to contain `enter` and `exit` methods that are used when entering or leaving that state. A state definition can also have a transitions property that contains several methods to be used when moving between specified states.

```coffee
  {
    enter : -> console.log 'enter'
    exit : -> console.log 'exit'
    transitions :
      'onBeforeExitTo:anotherState' : -> # method to be called before exit to `anotherState`
      'onExitTo:anotherState' : -> # method to be called on exit to `anotherState`
      'onBeforeEnterFrom:anotherState' : -> # method to be called before entering from `anotherState`
      'onEnterFrom:anotherState' : -> # method to be called on entering from `anotherState`
  }
```

### Defining State Transitions

Transitions are used to execute additional functionality when moving between specified states. There are 4 types of transitions that Backbone.StateManager will defaultly look for: `onBeforeExitTo`, `onExitTo`, `onBeforeEnterFrom`, and `onEnterFrom`. Each transition is a key value pair, where the value is a method and the key defines the transition type and the specified state (e.g. `onEnterFrom:specifiedState`).

### Adding a State

New states can be added individually using `addState` and passing the name of the state and a state object as defined above.

```coffee
  stateManager.addState name, definition
```

### Triggering a State

A state is triggered using `triggerState` and passing the name of the state and options. If the requested state is already the currentState, no methods will be executed. This can be overriden by passing in the option `reEnter : true` to the method.

```coffee
  stateManager.triggerState name, options
```
### Removing a State

A states can be added using `removeState` and passing in the name of the state.

```coffee
  stateManager.removeState name
```

### Using with Objects

StateManager provides an easy method to painlessly add a StateManager to any object. `StateManager.addStateManager` takes a target object and an optional set of options, reads in any states defined on the target, and creates a new StateManager. It also sets a number of methods on target, including `triggerState`, `getCurrentState`, and a reference to the StateManager at `target.stateManager`.

```coffee

View = Backbone.View.extend
  states :
    foo :
      enter : -> console.log 'enter bar'
      exit : -> console.log 'exit foo'
      transitions :
        'onExitTo:bar' : -> 'just exited and bar is about to be entered'
    bar :
      enter : -> console.log 'enter bar'
      exit : -> console.log 'exit bar'

  initialize : -> Backbone.StateManager.addStateManager @

```

**Note:** Similar to Backbone.js' `defaults` attribute, the `states` object will be shared among all instances of this state-managed view. Instead, define `states` as a function that returns an object consisting of your state definitions.

### [Github Issues](//github.com/crashlytics/backbone.statemanager/issues)

Development
---
```shell
# From the project's dir
npm install && bower install
```

Build tool
---
This project uses Gulp.js for it's build tool

To build:
```shell
gulp build
```

To run tests:
```shell
gulp test
```

To build, run tests, and watch for changes:
```shell
gulp
```
