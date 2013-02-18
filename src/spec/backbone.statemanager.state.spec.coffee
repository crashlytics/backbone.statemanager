describe 'Backbone.StateManager.State', =>
  beforeEach => @_states = _.clone spec.helper.states

  afterEach => delete @_states

  describe 'constructor', =>
    it 'creates a regexp of the name', =>
      state = new Backbone.StateManager.State 'foo', {}
      expect(state.regExpName).toBeDefined()

  describe 'prototype', =>

    describe 'matchName', =>
      it 'creates a regular expression out of the name', =>
        test = new Backbone.StateManager.State 'foo', @_states[0]
        spyOn test.regExpName, 'test'
        test.matchName 'foo'
        expect(test.regExpName.test).toHaveBeenCalledWith 'foo'


    describe 'findTransition', =>
      describe 'straight match', =>
        it 'finds functions who have a key matching the type and name', =>
          test = new Backbone.StateManager.State 'foo', { transitions : 'onFoo:Bar*splat' : -> }
          expect(test.findTransition 'onFoo', 'Bar123').toEqual jasmine.any Function

      describe 'not match', =>
        it 'finds functions who have a key that does not match the name', =>

          transitions =
            'onFoo:Bar*splat' : -> 'bar match'
            'onFoo:not:Bar*splat' : -> 'not bar match'

          test = new Backbone.StateManager.State 'foo', { transitions : transitions }
          expect(test.findTransition('onFoo', 'Baz123')()).toEqual 'not bar match'