extends CharacterBody2D


const DEFAULT_SPEED: int = 5000
const DEFAULT_ATTACK_RADIUS: int = 16


var current_speed: int = 5000
@onready var attack_range_CS2D = $AttackRangeArea2D/CollisionShape2D


@export var health: int = 10


@export var current_damage: int = 1
@export var damage_delay: float = 0.5
var can_deal_damage: bool = false
var animals_in_range: Array[Animal] = []


@export var current_attack_evolution: Attack_Evolution = Attack_Evolution.NONE
@export var current_attack_modifier: Attack_Modifier = Attack_Modifier.NONE
@export var current_movement_evolution: Movement_Evolution = Movement_Evolution.NONE


enum Attack_Evolution {
	NONE = 1,
	TEETH = 2,
	CLAWS = 3,
	SPRAY = 4,
}


enum Attack_Modifier {
	NONE = 1,
	SLOWDOWN = 2,
	VENOM = 3,
	ONESHOT = 4
}


enum Movement_Evolution {
	NONE = DEFAULT_SPEED,
	LEGS_BASIC = 10000,
	TENTACLES_BASIC = 7500
}


func _ready() -> void:
	# top down motion mode
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING


func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir.normalized() * current_speed * delta

	move_and_slide()
	_deal_damage()
	_update_movement(Movement_Evolution.TENTACLES_BASIC)
	_update_attack(Attack_Evolution.CLAWS)
	_update_modifier(Attack_Modifier.VENOM)


func _update_attack(new_attack_evolution: Attack_Evolution) -> void:
	match new_attack_evolution:
		Attack_Evolution.NONE:
			current_attack_evolution = Attack_Evolution.NONE
			attack_range_CS2D.shape.radius = DEFAULT_ATTACK_RADIUS
			current_attack_modifier = Attack_Modifier.NONE
		Attack_Evolution.TEETH:
			current_attack_evolution = Attack_Evolution.TEETH
			attack_range_CS2D.shape.radius = DEFAULT_ATTACK_RADIUS
			current_damage = 2
			damage_delay = 1
		Attack_Evolution.CLAWS:
			current_attack_evolution = Attack_Evolution.CLAWS
			attack_range_CS2D.shape.radius = DEFAULT_ATTACK_RADIUS + 4
			current_damage = 3
			damage_delay = 0.5
		Attack_Evolution.SPRAY:
			current_attack_evolution =Attack_Evolution.SPRAY
			attack_range_CS2D.shape.radius = DEFAULT_ATTACK_RADIUS + 16
			current_damage = 1
			damage_delay = 2


func _update_modifier(new_attack_modifier: Attack_Modifier) -> void:
	match new_attack_modifier:
		Attack_Modifier.NONE:
			current_attack_modifier = Attack_Modifier.NONE
		Attack_Modifier.SLOWDOWN:
			current_attack_modifier = Attack_Modifier.SLOWDOWN
		Attack_Modifier.VENOM:
			current_attack_modifier = Attack_Modifier.VENOM
		Attack_Modifier.ONESHOT:
			current_attack_modifier = Attack_Modifier.ONESHOT


func _update_movement(new_movemoent_evolution: Movement_Evolution) -> void:
	match  new_movemoent_evolution:
		Movement_Evolution.NONE:
			current_speed = DEFAULT_SPEED
		Movement_Evolution.LEGS_BASIC:
			current_speed = Movement_Evolution.LEGS_BASIC
		Movement_Evolution.TENTACLES_BASIC:
			current_speed = Movement_Evolution.TENTACLES_BASIC



#region Attacking
func _on_attack_range_area_2d_body_entered(body: CharacterBody2D) -> void:
	if body is Animal:
		animals_in_range.append(body)
		can_deal_damage = true


func _on_attack_range_area_2d_body_exited(body: CharacterBody2D) -> void:
	if body is Animal and animals_in_range.has(body):
		animals_in_range.erase(body)

		if animals_in_range.size() <= 0:
			can_deal_damage = false


func _deal_damage() -> void:
	if can_deal_damage:
		can_deal_damage = false

		for animal in animals_in_range:
			animal.take_damage(current_damage, current_attack_modifier)
			_restore_health(animal)

		await get_tree().create_timer(damage_delay).timeout
		can_deal_damage = true


func _restore_health(animal: Animal) -> void:
	health += animal.restore_health_value

#endregion
