extends PanelContainer
@onready var paper_swipe_rev: AudioStreamPlayer = $PaperSwipeRev

func _on_button_pressed() -> void:
	hide()
	paper_swipe_rev.play()
