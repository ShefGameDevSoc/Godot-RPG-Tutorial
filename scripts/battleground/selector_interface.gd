class_name SelectorInterface
extends Node
## An interface for the various selectos
##
## An interface for [BattleHUD], [RandomSelector] and [ClientSelector]
## Those connect to [signal action_selection_started] and call [signal action_selected] once
## the action has been made
## This is the object passed to [BGActor] upon its creation in [BattleGround]

## Emitted when the [BattleGround] is ready for the owning [BGActor] to make its selection
signal action_selection_started(me: BGActor, allies: Array[BGActor], opponents: Array[BGActor])
## Emitted by the selector once its decision has been made
signal action_selected(target: BGActor, action: Action)
