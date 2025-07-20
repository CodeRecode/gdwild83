extends PanelContainer

@onready var options_menu: PanelContainer = $"../OptionsMenu"
@onready var credits_menu: PanelContainer = $"../CreditsMenu"
@onready var paper_swipe: AudioStreamPlayer = $PaperSwipe

signal game_begin()

func _ready() -> void:
	get_tree().paused = true

func _on_start_game_button_pressed() -> void:
	hide()
	get_tree().paused = false
	game_begin.emit()

func _on_options_button_pressed() -> void:
	options_menu.show()
	paper_swipe.play()

func _on_credits_button_pressed() -> void:
	credits_menu.show()
	paper_swipe.play()
