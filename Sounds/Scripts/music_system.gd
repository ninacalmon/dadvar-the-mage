extends Node
class_name MusicSystem

const DEFAULT_LOW_VOLUME_DB_FADE = -40
const DEFAULT_MAIN_TRACK_VOLUME_DB = -25
var time_main_track_stopped = 0

@onready var main_soundtrack: AudioStreamPlayer = %MainGameStreamPlayer
@onready var boss_fight_soundtrack: AudioStreamPlayer = %BossFightStreamPlayer

var currently_playing_soundtrack: AudioStream

func start_main_track(fade_in_time: float):
	self.main_soundtrack.play(self.time_main_track_stopped)
	self.currently_playing_soundtrack = self.main_soundtrack.stream

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

func start_boss_track(audio_track_list: Array[AudioStream], last_soundtrack_fade_out_time: int, volume_to_play: int = 0) -> void:
	if audio_track_list == null or audio_track_list.size() == 0:
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

	var playlist: AudioStreamPlaylist = AudioStreamPlaylist.new()

	playlist.set_stream_count(audio_track_list.size())
	playlist.loop = true
	playlist.shuffle = false
	playlist.fade_time = 0.2

	for i in audio_track_list.size():
		var audio_track = audio_track_list[i]
		playlist.set_list_stream(i, audio_track)

	self.boss_fight_soundtrack.stream = playlist
	self.boss_fight_soundtrack.volume_db = volume_to_play
	self.boss_fight_soundtrack.play()

	self.currently_playing_soundtrack = self.boss_fight_soundtrack.stream
