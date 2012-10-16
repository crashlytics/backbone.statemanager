# Backbone.StateManager

Simple, powerful state management for Backbone.js

## About StateManager

Backbone.StateManager is a module for Backbone.js that adds the ability to easily
manage and utilize states in any scale JavaScript applications. It can be used as
a stand alone object or in conjunction with a target object through it's addStateManager
method.

### Key Benefits

* Modular definitions of states
* Sub/pub architecture with Backbone.Events
* Support for transition events between states
* RegExp matching for states and transitions
* Easy to attach to any object

## Compatibility and Requirements

Backbone.StateManager currently has the following dependencies:

* [Underscore](http://underscorejs.org) v1.4.2
* [Backbone](http://backbonejs.org) v0.9.2

## Source Code and Downloads

Backbone.StateManager is written in CoffeeScript. You can download the raw source code
from the "src" folder or download the JavaScript build in the main directory.

The latest stable releases can be found at the links below:

### Builds

* Development: [backbone.statemanager.js](https://raw.github.com/crashlytics/backbone.statemanager/master/backbone.statemanager.js)

* Production: [backbone.statemanager.min.js](https://raw.github.com/crashlytics/backbone.statemanager/master/backbone.statemanager.min.js)

### StateManager's Pieces

StateManager is compromised of three primary pieces:

* StateManager: A management object that tracks the current state, handles state requests, and publishes events
* States: A collection object that manages an array of states
* State: An individual state object that is responsible for exiting, entering, and transitioning

### Getting Started


### [Github Issues](//github.com/crashlytics/backbone.statemanager/issues)