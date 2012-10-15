describe 'Backbone.StateManager.States', =>
  beforeEach => @_states = _.clone spec.helper.states

  afterEach => delete @_states

  describe 'constructor', =>
    it 'creates a regexp of the name', =>
      state = new Backbone.StateManager.State 'foo', {}
      expect(state.regExpName).toBeDefined()

  describe 'prototype', =>