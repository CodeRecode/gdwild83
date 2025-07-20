extends Node2D

@onready var victory_screen: ColorRect = $"../VictoryScreen"
@onready var you_win_label: Label = $"../VictoryScreen/YouWinLabel"

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var narrator_death_player: AudioStreamPlayer = $NarratorDeathPlayer

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
