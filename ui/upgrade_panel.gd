extends PanelContainer

@onready var upgrade_1_button: Button = $MarginContainer/VBoxContainer/HBoxContainer2/Upgrade1Button
@onready var upgrade_2_button: Button = $MarginContainer/VBoxContainer/HBoxContainer2/Upgrade2Button

signal evolution_chosen(choice: int)

func _ready() -> void:
	hide()

func _on_player_evolution_triggered(name1: String, name2: String) -> void:
	upgrade_1_button.text = name1
	upgrade_2_button.text = name2
	show()


func _on_upgrade_1_button_pressed() -> void:
	evolution_chosen.emit(1)
	hide()


func _on_upgrade_2_button_pressed() -> void:
	evolution_chosen.emit(2)
	hide()
