extends Node2D

@onready var victory_screen: ColorRect = $"../VictoryScreen"
@onready var you_win_label: Label = $"../VictoryScreen/YouWinLabel"

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var narrator_death_player: AudioStreamPlayer = $NarratorDeathPlayer

@onready var dialog_subtitles: PanelContainer = $"../DialogSubtitles"
@onready var subtitles_label: Label = $"../DialogSubtitles/MarginContainer/SubtitlesLabel"

signal narrator_vulnerable()

var playing = false
var current_line = 0
var lines_to_play: Array[String] = []

func _ready() -> void:
	victory_screen.hide()
	you_win_label.modulate.a = 0
	music_player.play()

func _process(_delta: float) -> void:
	if not playing and current_line < lines_to_play.size():
		_play_line()

func _on_narrator_narrator_died() -> void:
	get_tree().paused = true
	victory_screen.show()
	music_player.stop()
	narrator_death_player.play()
	await get_tree().create_timer(2.0).timeout

	var tween = create_tween()
	tween.tween_property(you_win_label, "modulate:a", 1.0, 3.0)

func _on_player_dna_modified(new_value: int) -> void:
	pass


func _on_main_menu_game_begin() -> void:
	await get_tree().create_timer(1.0).timeout
	lines_to_play.append("The Keplerian slime is a recent transplant to earth, but no stranger to astrobiologists.")

	lines_to_play.append("On its home planet in Kepler, it is an obligate herbivore.")
	
func _play_line() -> void:
	playing = true
	dialog_subtitles.show()
	subtitles_label.text = lines_to_play[current_line]
	
	await get_tree().create_timer(5.0).timeout
	
	current_line += 1
	if current_line >= lines_to_play.size():
		dialog_subtitles.hide()
	playing = false


func _on_player_evolution_complete(new_level: int) -> void:
	match new_level:
		1:
			lines_to_play.append("It looks like our slime has undergone some sort of metamorphosis.")
			lines_to_play.append("The process is very taxing, however, so it will likely hibernate soon.")
		2:
			lines_to_play.append("Another metamorphosis so soon?")
			lines_to_play.append("Although dangerous-looking, its new weapons are strictly for self-defense.")
		3:
			lines_to_play.append("The slime, tired from the activities of the day, will go to sleep.")
			narrator_vulnerable.emit()
		4:
			lines_to_play.append("I think we may be in some trouble.")
	
