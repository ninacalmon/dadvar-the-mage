extends Node

var CURRENT_MOBS_SPAWNED: int = 0
var MAXIMUM_MOBS_TO_SPAWN: int = 500
const PLAYER_Y_SPRITE_OFFSET = -65

enum Groups {
	MAIN,
	BOSS_HEALTH_BAR
}
const GROUPS_DIC = {
	Groups.MAIN: "Main",
	Groups.BOSS_HEALTH_BAR: "BossHealthBarGroup"
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

func prettify_class_name(name: String) -> String:
	var regex = RegEx.new()
	regex.compile("([a-z])([A-Z])")
	return regex.sub(name, "$1 $2", true)

func has_property(obj: Object, prop_name: String) -> bool:
	for p in obj.get_property_list():
		if p.name == prop_name:
			return true
	return false
