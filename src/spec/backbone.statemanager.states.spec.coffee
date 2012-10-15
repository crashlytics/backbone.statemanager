describe 'Backbone.StateManager.States', =>
  beforeEach => @_states = _.clone spec.helper.states

  afterEach => delete @_states

  describe 'constructor', =>
    it 'creates a hash', =>
      states = new Backbone.StateManager.States
      expect(states.states).toBeDefined()

    it 'adds passed in states', =>
      spyOn Backbone.StateManager.States.prototype, 'add'
      states = new Backbone.StateManager.States @_states
      expect(states.add).toHaveBeenCalled()

  describe 'prototype', =>
    beforeEach =>
      @states = new Backbone.StateManager.States @_states

    describe 'add', =>
      it 'creates a new Backbone.StateManager.State object', =>
        spyOn Backbone.StateManager, 'State'
        @states.add 'foo', {}
        expect(Backbone.StateManager.State).toHaveBeenCalledWith 'foo', {}

      it 'add the new object to states', =>
        @states.add 'foo', {}
        expect(@states.states.foo).toBeDefined()

    describe 'remove', =>
      it 'removes the reference to the provided name', =>
        @states.states.foo = {}
        @states.remove 'foo'
        expect(@states.states.foo).toBeUndefined()

    describe 'find', =>
      it 'does a regular expression check to find a state that matches the provided name', =>
        expect(@states.find 'noTransitions').toEqual jasmine.any Object

    describe 'findInitial', =>
      it 'identifies the first state who is marked as initial', =>
        expect(@states.findInitial()).toEqual jasmine.any Object