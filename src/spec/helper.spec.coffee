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