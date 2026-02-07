extends Node

var CURRENT_MOBS_SPAWNED: int = 0
var MAXIMUM_MOBS_TO_SPAWN: int = 500
const PLAYER_Y_SPRITE_OFFSET = -65

enum Groups {
	MAIN
}
const GROUPS_DIC = {
	Groups.MAIN: "Main"
}

enum AudioBus {
	MASTER,
	MUSIC,
	SOUND_EFFECTS
}

const AUDIO_BUS_DIC = {
	AudioBus.MASTER: "Master",
	AudioBus.MUSIC: "Music",
	AudioBus.SOUND_EFFECTS: "SoundEffects"
}
