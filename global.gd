extends Node

var CURRENT_MOBS_SPAWNED: int = 0
var MAXIMUM_MOBS_TO_SPAWN: int = 350
const PLAYER_Y_SPRITE_OFFSET = -65

enum Groups {
	MAIN
}
const GROUPS_DIC = {
	Groups.MAIN: 'Main'
}
