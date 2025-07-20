extends Node2D

@onready var victory_screen: ColorRect = $"../VictoryScreen"
@onready var you_win_label: Label = $"../VictoryScreen/YouWinLabel"

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var narrator_death_player: AudioStreamPlayer = $NarratorDeathPlayer

@onready var dialog_subtitles: PanelContainer = $"../DialogSubtitles"
@onready var subtitles_label: Label = $"../DialogSubtitles/MarginContainer/SubtitlesLabel"

signal narrator_vulnerable()

func _ready() -> void:
	victory_screen.hide()
	you_win_label.modulate.a = 0
	music_player.play()

func _on_narrator_narrator_died() -> void:
	get_tree().paused = true
	victory_screen.show()
	music_player.stop()
	narrator_death_player.play()
	await get_tree().create_timer(2.0).timeout

	var tween = create_tween()
	tween.tween_property(you_win_label, "modulate:a", 1.0, 3.0)

func _on_player_dna_modified(new_value: int) -> void:
	if new_value > 10:
		narrator_vulnerable.emit()


func _on_main_menu_game_begin() -> void:
	await get_tree().create_timer(1.0).timeout
	dialog_subtitles.show()
	subtitles_label.text = "The Keplerian slime is a recent transplant to earth, but no stranger to astrobiologists."
	await get_tree().create_timer(5.0).timeout
	subtitles_label.text = "On its home planet in Kepler, it is an obligate herbivore."
	await get_tree().create_timer(5.0).timeout
	dialog_subtitles.hide()
