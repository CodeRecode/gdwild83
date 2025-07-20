extends PanelContainer
@onready var paper_swipe_rev: AudioStreamPlayer = $PaperSwipeRev
@onready var button: Button = $MarginContainer/VBoxContainer/Button
@onready var main_menu: PanelContainer = $"../MainMenu"

func do_show() -> void:
	show()
	button.grab_focus()
	

func _on_button_pressed() -> void:
	hide()
	paper_swipe_rev.play()
	main_menu.do_focus()
