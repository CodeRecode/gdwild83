extends PanelContainer

@onready var button: Button = $MarginContainer/VBoxContainer/Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()

func _on_player_player_died() -> void:
	show()
	button.grab_focus()

func _on_button_pressed() -> void:
	hide()
	get_tree().paused = false
	get_tree().reload_current_scene()
