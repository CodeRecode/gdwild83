extends Animal
class_name Narrator

@export var instance_health: int = 5
@export var speed: float = 7000.0

var can_be_attacked: bool = false
var flee_vector: Vector2 = Vector2.ZERO

signal narrator_died()


func _ready() -> void:
	super._ready()
	health = instance_health


func _physics_process(delta: float) -> void:
	if can_be_attacked:
		_flee(delta)
		move_and_slide()


#temporary override
func take_damage(damage_amount: int, attack_modifier) -> void:
	if not can_be_attacked:
		return

	health -= damage_amount
	if health <= 0:
		narrator_died.emit()

func _on_story_controller_narrator_vulnerable() -> void:
	can_be_attacked = true


func _flee(delta: float) -> void:
	flee_vector = (position - player.position).normalized()
	velocity = flee_vector * speed * delta
