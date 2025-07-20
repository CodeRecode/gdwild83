extends PanelContainer

@onready var options_menu: PanelContainer = $"../OptionsMenu"
@onready var credits_menu: PanelContainer = $"../CreditsMenu"
@onready var paper_swipe: AudioStreamPlayer = $PaperSwipe
@onready var start_game_button: Button = $MarginContainer/VBoxContainer/VBoxContainer/StartGameButton

signal game_begin()

func _ready() -> void:
	get_tree().paused = true
	do_focus()
	
func do_focus() -> void:
	start_game_button.grab_focus()

func _on_start_game_button_pressed() -> void:
	hide()
	get_tree().paused = false
	game_begin.emit()

func _on_options_button_pressed() -> void:
	options_menu.show()
	paper_swipe.play()

func _on_credits_button_pressed() -> void:
	credits_menu.do_show()
	paper_swipe.play()
