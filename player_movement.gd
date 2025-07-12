extends CharacterBody2D

@export var speed = 5000.0

func _ready() -> void:
	# top down motion mode
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir.normalized() * speed * delta
	
	move_and_slide()
