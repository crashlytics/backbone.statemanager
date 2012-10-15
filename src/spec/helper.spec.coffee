window.spec =
  helper :
    states :
      noTransitions :
        enter : ->
        exit : ->
      withInitial :
        initial : true
        enter : ->
        exit : ->
      nonMethodExit :
        enter : ->
        exit : {}
      nonMethodEnter :
        enter : {}
        exit : ->
      exitTransition :
        enter : ->
        exit : ->
        transitions :
          'onBeforeExitTo:enterTransition' : ->
          'onExitTo:enterTransition' : ->
      enterTransition :
        enter : ->
        exit : ->
        transitions :
          'onBeforeEnterFrom:exitTransition' : ->
          'onEnterFrom:enterTransition' : ->
