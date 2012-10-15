// Generated by CoffeeScript 1.3.3
(function() {
  var _this = this;

  describe('Backbone.StateManager', function() {
    beforeEach(function() {
      return _this.states = _.clone(spec.helper.states);
    });
    afterEach(function() {
      return delete _this.states;
    });
    it('exists under Backbone.StateManager', function() {
      return expect(Backbone.StateManager).toBeDefined();
    });
    describe('constructor', function() {
      it('creates a states object', function() {
        var stateManager;
        stateManager = new Backbone.StateManager;
        return expect(stateManager.states).toBeDefined();
      });
      return it('calls addState with passed state', function() {
        var stateManager;
        spyOn(Backbone.StateManager.prototype, 'addState');
        stateManager = new Backbone.StateManager(_this.states);
        return expect(stateManager.addState).toHaveBeenCalledWith('noTransitions', jasmine.any(Object));
      });
    });
    describe('prototype', function() {
      beforeEach(function() {
        return _this.stateManager = new Backbone.StateManager(_this.states);
      });
      afterEach(function() {
        return delete _this.stateManager;
      });
      describe('initialize', function() {
        return it('calls triggerState on the first state found that has initial : true set on it', function() {
          spyOn(Backbone.StateManager.prototype, 'triggerState');
          _this.stateManager.initialize();
          return expect(_this.stateManager.triggerState).toHaveBeenCalledWith('withInitial', jasmine.any(Object));
        });
      });
      describe('addState', function() {
        it('sets the state passed to states with the states callback', function() {
          _this.stateManager.addState('noTransitions', _this.states.noTransitions);
          return expect(_this.stateManager.states.noTransitions).toEqual(_this.states.noTransitions);
        });
        return it('triggers remove:state and passes state name', function() {
          spyOn(_this.stateManager, 'trigger');
          _this.stateManager.addState('noTransitions');
          return expect(_this.stateManager.trigger).toHaveBeenCalledWith('add:state', 'noTransitions');
        });
      });
      describe('removeState', function() {
        it('removes the state', function() {
          _this.stateManager.removeState('noTransitions');
          return expect(_this.stateManager.states.noTransitions).toBeUndefined();
        });
        return it('triggers remove:state and passes state name', function() {
          spyOn(_this.stateManager, 'trigger');
          _this.stateManager.removeState('noTransitions');
          return expect(_this.stateManager.trigger).toHaveBeenCalledWith('remove:state', 'noTransitions');
        });
      });
      describe('getCurrentState', function() {
        return it('returns the current state', function() {
          _this.stateManager.currentState = _this.states.noTransitions;
          return expect(_this.stateManager.getCurrentState()).toEqual(_this.states.noTransitions);
        });
      });
      describe('triggerState', function() {
        beforeEach(function() {
          spyOn(_this.stateManager, '_matchState').andReturn(true);
          spyOn(_this.stateManager, 'enterState');
          return spyOn(_this.stateManager, 'exitState');
        });
        it('checks that the state exists', function() {
          _this.stateManager.triggerState('foo');
          return expect(_this.stateManager._matchState).toHaveBeenCalledWith('foo');
        });
        it('aborts if the state does not exist', function() {
          _this.stateManager._matchState.andReturn(false);
          expect(_this.stateManager.triggerState('foo')).toEqual(false);
          expect(_this.stateManager._matchState).toHaveBeenCalledWith('foo');
          expect(_this.stateManager.exitState).not.toHaveBeenCalled();
          return expect(_this.stateManager.enterState).not.toHaveBeenCalled();
        });
        it('calls exitState for the current state if it exists', function() {
          _this.stateManager.currentState = 'bar';
          _this.stateManager.triggerState('foo');
          return expect(_this.stateManager.exitState).toHaveBeenCalledWith('bar', jasmine.any(Object));
        });
        it('calls enterState for the new state if it exists', function() {
          _this.stateManager.triggerState('foo');
          return expect(_this.stateManager.enterState).toHaveBeenCalledWith('foo', jasmine.any(Object));
        });
        return describe('the current state is the same as the new state', function() {
          return it('does nothing unless options.reEnter is set', function() {
            _this.stateManager._matchState.andReturn(_this.states.noTransitions);
            _this.stateManager.currentState = 'noTransitions';
            expect(_this.stateManager.triggerState('noTransitions')).toEqual(false);
            expect(_this.stateManager._matchState).toHaveBeenCalledWith('noTransitions');
            expect(_this.stateManager.exitState).not.toHaveBeenCalled();
            expect(_this.stateManager.enterState).not.toHaveBeenCalled();
            expect(_this.stateManager.triggerState('noTransitions', {
              reEnter: true
            })).not.toEqual(false);
            expect(_this.stateManager._matchState).toHaveBeenCalledWith('noTransitions');
            expect(_this.stateManager.exitState).toHaveBeenCalledWith('noTransitions', jasmine.any(Object));
            return expect(_this.stateManager.enterState).toHaveBeenCalledWith('noTransitions', jasmine.any(Object));
          });
        });
      });
      return describe('_matchState', function() {
        it('aborts if the passed in state is not a string', function() {
          return expect(_this.stateManager._matchState({})).toEqual(false);
        });
        it('converts passed in string to RegEx', function() {
          spyOn(window, 'RegExp').andCallThrough();
          _this.stateManager._matchState('foo:bar*splat');
          return expect(window.RegExp).toHaveBeenCalledWith('^foo([^/]+)(.*?)$');
        });
        return it('checks RegEx against all the states', function() {
          expect(_this.stateManager._matchState('no*splat')).toEqual('noTransitions');
          return expect(_this.stateManager._matchState('foo bar')).toBeFalsy();
        });
      });
    });
    return describe('addStateManager', function() {
      it('creates a new StateManager', function() {
        var StateManager, spy, target;
        StateManager = Backbone.StateManager;
        spy = spyOn(Backbone, 'StateManager').andCallThrough();
        spy.__proto__ = StateManager;
        spy.prototype = StateManager.prototype;
        target = {
          states: _this.states
        };
        Backbone.StateManager.addStateManager(target);
        return expect(Backbone.StateManager).toHaveBeenCalledWith(jasmine.any(Object), jasmine.any(Object));
      });
      it('binds all of targets states methods to the target', function() {
        var target;
        spyOn(_, 'bind');
        target = {
          states: _this.states
        };
        Backbone.StateManager.addStateManager(target);
        return expect(_.bind).toHaveBeenCalledWith(jasmine.any(Function), target);
      });
      it('allows callthrough on the target for triggerState', function() {
        var target;
        target = {
          states: _this.states
        };
        spyOn(Backbone.StateManager.prototype, 'triggerState');
        Backbone.StateManager.addStateManager(target);
        expect(target.triggerState).toBeDefined();
        target.triggerState('foo');
        return expect(Backbone.StateManager.prototype.triggerState).toHaveBeenCalledWith('foo');
      });
      it('allows callthrough on the target for getCurrentState', function() {
        var target;
        target = {};
        spyOn(Backbone.StateManager.prototype, 'getCurrentState');
        Backbone.StateManager.addStateManager(target);
        expect(target.getCurrentState).toBeDefined();
        target.getCurrentState();
        return expect(Backbone.StateManager.prototype.getCurrentState).toHaveBeenCalled();
      });
      it('calls initialize on the state manager', function() {
        spyOn(Backbone.StateManager.prototype, 'initialize');
        Backbone.StateManager.addStateManager({});
        return expect(Backbone.StateManager.prototype.initialize).toHaveBeenCalled();
      });
      return it('does not call initialize if options.initialize is set to false(y)', function() {
        spyOn(Backbone.StateManager.prototype, 'initialize');
        _.each([false, null, 0], function(value) {
          Backbone.StateManager.addStateManager({}, {
            initialize: value
          });
          return expect(Backbone.StateManager.prototype.initialize).not.toHaveBeenCalled();
        });
        Backbone.StateManager.addStateManager({}, {
          initialize: void 0
        });
        return expect(Backbone.StateManager.prototype.initialize).toHaveBeenCalled();
      });
    });
  });

}).call(this);
