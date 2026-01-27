extends Node

const DEFAULT_LOW_VOLUME_DB_FADE = -40
const DEFAULT_MAIN_TRACK_VOLUME_DB = -25
var time_main_track_stopped

@onready var main_soundtrack: AudioStreamPlayer = %MainGameStreamPlayer
@onready var boss_fight_soundtrack: AudioStreamPlayer = %BossFightStreamPlayer

func start_main_track(fade_in_time: float):
	self.main_soundtrack.play(self.time_main_track_stopped)
	var fade_time_for_each_track = fade_in_time / 2

	var tween = create_tween()
	tween.tween_property(
		self.boss_fight_soundtrack,
		"volume_db", 
		self.DEFAULT_LOW_VOLUME_DB_FADE, 
		fade_time_for_each_track
	)
	tween.tween_property(
		self.main_soundtrack,
		"volume_db",
		DEFAULT_MAIN_TRACK_VOLUME_DB,
		fade_time_for_each_track
	)

	await tween.finished
	
	self.boss_fight_soundtrack.stop()

func start_boss_track(audio_track: AudioStream, last_soundtrack_fade_out_time: int, volume_to_play: int = 0) -> void:
	if audio_track == null:
		return

	var tween = create_tween()
	tween.tween_property(
		self.main_soundtrack, 
		"volume_db", 
		self.DEFAULT_LOW_VOLUME_DB_FADE, 
		last_soundtrack_fade_out_time
	)

	await tween.finished

	time_main_track_stopped = self.main_soundtrack.get_playback_position()
	self.main_soundtrack.stop()

	self.boss_fight_soundtrack.stop()
	self.boss_fight_soundtrack.stream = audio_track
	self.boss_fight_soundtrack.volume_db = volume_to_play
	self.boss_fight_soundtrack.play()
