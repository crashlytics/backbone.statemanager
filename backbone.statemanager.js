// Generated by CoffeeScript 1.3.3

/*
Backbone.Statemanager, v0.0.1-alpha
Copyright (c)2012 Patrick Camacho and Mark Roseboom, Crashlytics
Distributed under MIT license
http://github.com/crashlytics/backbone.statemanager
*/


(function() {

  Backbone.StateManager = (function(Backbone, _) {
    var StateManager, _deepBindAll;
    StateManager = function(states, options) {
      this.options = options != null ? options : {};
      this.states = new StateManager.States(states);
      return this;
    };
    StateManager.extend = Backbone.View.extend;
    _.extend(StateManager.prototype, Backbone.Events, {
      getCurrentState: function() {
        return this.currentState;
      },
      addState: function(name, callbacks) {
        this.states.add(name, callbacks);
        return this.trigger('add:state', name);
      },
      removeState: function(name) {
        this.states.remove(name);
        return this.trigger('remove:state', name);
      },
      initialize: function(options) {
        var initial;
        if (options == null) {
          options = {};
        }
        if (initial = this.states.findInitial()) {
          return this.triggerState(initial, options);
        }
      },
      triggerState: function(state, options) {
        if (options == null) {
          options = {};
        }
        if (!(state === this.currentState && !options.reEnter)) {
          if (this.currentState) {
            this.exitState(options);
          }
          return this.enterState(state, options);
        } else {
          return false;
        }
      },
      enterState: function(state, options) {
        var matchedState;
        if (options == null) {
          options = {};
        }
        if (!((matchedState = this.states.find(this.currentState)) && _.isFunction(matchedState.enter))) {
          return false;
        }
        this.trigger('before:enter:state', state, matchedState, options);
        matchedState.enter(options);
        this.trigger('enter:state', this.currentState, matchedState, options);
        this.currentState = state;
        return this;
      },
      exitState: function(options) {
        var matchedState;
        if (options == null) {
          options = {};
        }
        if (!((matchedState = this.states.find(this.currentState)) && _.isFunction(matchedState.exit))) {
          return false;
        }
        this.trigger('before:exit:state', this.currentState, matchedState, options);
        matchedState.exit(options);
        this.trigger('exit:state', this.currentState, matchedState, options);
        delete this.currentState;
        return this;
      }
    });
    StateManager.States = function(states) {
      var _this = this;
      this.states = {};
      if (states && _.isObject(states)) {
        _.each(states, function(value, key) {
          return _this.add(key, value);
        });
      }
      return this;
    };
    _.extend(StateManager.States.prototype, {
      add: function(name, callbacks) {
        if (!(_.isString(name) && _.isObject(callbacks))) {
          return false;
        }
        callbacks.regExp = StateManager.States._regExpStateConversion(name);
        return this.states[name] = callbacks;
      },
      remove: function(name) {
        if (!_.isString(name)) {
          return false;
        }
        return delete this.states[name];
      },
      find: function(name) {
        if (!_.isString(name)) {
          return false;
        }
        return _.chain(this.states).find(function(state) {
          var _ref;
          return (_ref = state.regExp) != null ? _ref.test(name) : void 0;
        }).value();
      },
      findInitial: function() {
        var _this = this;
        return _.find(this.states, function(value, name) {
          return value.initial;
        });
      }
    });
    StateManager.States._regExpStateConversion = function(name) {
      name = name.replace(/[-[\]{}()+?.,\\^$|#\s]/g, '\\$&').replace(/:\w+/g, '([^\/]+)').replace(/\*\w+/g, '(.*?)');
      return new RegExp("^" + name + "$");
    };
    StateManager.addStateManager = function(target, options) {
      var stateManager;
      if (options == null) {
        options = {};
      }
      if (!target) {
        new Error('Target must be defined');
      }
      _deepBindAll(target.states, target);
      stateManager = new Backbone.StateManager(target.states, options);
      target.triggerState = function() {
        return stateManager.triggerState.apply(stateManager, arguments);
      };
      target.getCurrentState = function() {
        return stateManager.getCurrentState();
      };
      if (options.initialize || _.isUndefined(options.initialize)) {
        stateManager.initialize(options);
      }
      return delete target.states;
    };
    _deepBindAll = function(obj) {
      var target;
      target = _.last(arguments);
      _.each(obj, function(value, key) {
        if (_.isFunction(value)) {
          return obj[key] = _.bind(value, target);
        } else if (_.isObject(value)) {
          return obj[key] = _deepBindAll(value, target);
        }
      });
      return obj;
    };
    return StateManager;
  })(Backbone, _);

}).call(this);
