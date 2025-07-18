extends CharacterBody2D
class_name Player


const DEFAULT_SPEED: int = 6000
const DEFAULT_ATTACK_RADIUS: int = 16
const ARMOR_DEFAULT: float = 1.0
const ARMOR_DAMAGE_REDUCTION: float = 0.7


signal health_modified(new_value: float)
signal dna_modified(new_value: int)
signal evolution_triggered(name1: String, name2: String)
signal player_died()
signal player_took_damage()


var current_speed: int = 5000
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var current_attack_range_CS2D = $AttackRangeArea2D/AttackRange
@onready var body_sprite: AnimatedSprite2D = $BodySprite
@onready var legs_sprite: AnimatedSprite2D = $LegsSprite
@onready var weapon_sprite: AnimatedSprite2D = $WeaponSprite


@export var health: float = 10.0
@export var regen_amount: int = 1
@export var regen_timer: float = 2.0
var can_regen: bool = false
var armor_multiplier: float = 1.0


@export var stored_dna: int = 0
@export var evolution_thresholds: Array[int] = [10, 50, 250, 1000]
@export var evolution_scales: Array[float] = [1.0, 1.5, 2.0, 3.0, 5.0]
var evolution_level: int = 0
var choosing_evolution: bool = false


var projectile = preload("res://projectile.tscn")


@export var current_damage: int = 1
@export var damage_delay: float = 0.5
@export var attack_speed: float = 17500.0
var can_deal_damage: bool = false
var animals_in_range: Array[Animal] = []


@export var current_attack_evolution: Attack_Evolution = Attack_Evolution.NONE
@export var current_attack_modifier: Attack_Modifier = Attack_Modifier.NONE
@export var current_movement_evolution: Movement_Evolution = Movement_Evolution.NONE
@export var current_health_evolution: Health_Evolution = Health_Evolution.NONE


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
	ONESHOT = 4,
	SPEED = 5
}


enum Movement_Evolution {
	NONE = DEFAULT_SPEED,
	LEGS_BASIC = 12500,
	TENTACLES_BASIC = 9000
}


enum Health_Evolution{
	NONE = 1,
	ARMOR = 2,
	REGEN = 3
}


func _ready() -> void:
	# top down motion mode
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

	current_speed = DEFAULT_SPEED
	_update_attack_radius(DEFAULT_ATTACK_RADIUS)
	current_attack_evolution = Attack_Evolution.NONE
	current_attack_modifier = Attack_Modifier.NONE
	current_movement_evolution = Movement_Evolution.NONE
	current_health_evolution = Health_Evolution.NONE

	body_sprite.play("basic")

	# update ui values
	_modify_health(0)
	_modify_dna(0)


func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir.normalized() * current_speed * delta

	if current_movement_evolution == Movement_Evolution.LEGS_BASIC:
		if velocity.length_squared() > 0:
			legs_sprite.play("walk")
		else:
			legs_sprite.play("default")

	move_and_slide()
	_deal_damage()
	_check_evolve()
	_regen_health()

#region Evolution

func _update_attack_radius(new_radius: float) -> void:
	current_attack_range_CS2D.shape.radius =  collision_shape_2d.shape.radius + new_radius


func _update_attack(new_attack_evolution: Attack_Evolution) -> void:
	if  new_attack_evolution == Attack_Evolution.NONE:
		current_attack_evolution = Attack_Evolution.NONE
		_update_attack_radius(DEFAULT_ATTACK_RADIUS)
		return

	var new_scale = evolution_scales[evolution_level + 1]
	scale = Vector2(new_scale, new_scale)
	weapon_sprite.show()

	match new_attack_evolution:
#		Attack_Evolution.TEETH:
#			current_attack_evolution = Attack_Evolution.TEETH
#			_update_attack_radius(DEFAULT_ATTACK_RADIUS)
#			current_damage = 2
#			damage_delay = 1
		Attack_Evolution.CLAWS:
			weapon_sprite.play("claws")
			current_attack_evolution = Attack_Evolution.CLAWS
			_update_attack_radius(DEFAULT_ATTACK_RADIUS + 4)
			current_damage = 3
			damage_delay = 0.5
		Attack_Evolution.SPRAY:
			weapon_sprite.play("spray")
			current_attack_evolution =Attack_Evolution.SPRAY
			_update_attack_radius(DEFAULT_ATTACK_RADIUS + 64)
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


func _update_movement(new_movement_evolution: Movement_Evolution) -> void:
	current_movement_evolution = new_movement_evolution
	if new_movement_evolution == Movement_Evolution.NONE:
		current_speed = DEFAULT_SPEED
		return

	var new_scale = evolution_scales[evolution_level + 1]
	scale = Vector2(new_scale, new_scale)
	body_sprite.play("body")
	legs_sprite.show()

	match  new_movement_evolution:
		Movement_Evolution.LEGS_BASIC:
			legs_sprite.play("default")
			current_speed = Movement_Evolution.LEGS_BASIC
		Movement_Evolution.TENTACLES_BASIC:
			legs_sprite.play("tentacles")
			current_speed = Movement_Evolution.TENTACLES_BASIC


func _update_health(new_health_evolution: Health_Evolution) -> void:
	current_health_evolution = new_health_evolution
	match new_health_evolution:
		Health_Evolution.NONE:
			armor_multiplier = ARMOR_DEFAULT
		Health_Evolution.ARMOR:
			armor_multiplier *= ARMOR_DAMAGE_REDUCTION
		Health_Evolution.REGEN:
			can_regen = true


func _check_evolve() -> void:
	if choosing_evolution:
		return

	if evolution_level < evolution_thresholds.size() and stored_dna > evolution_thresholds[evolution_level]:
		choosing_evolution = true
		match evolution_level:
			0: evolution_triggered.emit("Legs", "Tentacles")
			1: evolution_triggered.emit("Claws", "Spray")
			2: evolution_triggered.emit("Armor", "Regen")
			3:
				if current_attack_evolution == Attack_Evolution.CLAWS:
					evolution_triggered.emit("Attack Speed", "Oneshot")
				else:
					evolution_triggered.emit("Venom", "Slowdown")

func _on_upgrade_panel_evolution_chosen(choice: int) -> void:
	match evolution_level:
		0: _update_movement(Movement_Evolution.LEGS_BASIC if choice == 1 else Movement_Evolution.TENTACLES_BASIC)
		1: _update_attack(Attack_Evolution.CLAWS if choice == 1 else Attack_Evolution.SPRAY)
		2: _update_health(Health_Evolution.ARMOR if choice == 1 else Health_Evolution.REGEN)
		3:
			if current_attack_evolution == Attack_Evolution.CLAWS:
				_update_modifier(Attack_Modifier.SPEED if choice == 1 else Attack_Modifier.ONESHOT)
			else:
				_update_modifier(Attack_Modifier.VENOM if choice == 1 else Attack_Modifier.SLOWDOWN)

	evolution_level += 1
	choosing_evolution = false
#endregion


#region Combat
func _on_attack_range_area_2d_body_entered(body: CharacterBody2D) -> void:
	if body is Animal:
		animals_in_range.append(body)


func _on_attack_range_area_2d_body_exited(body: CharacterBody2D) -> void:
	if body is Animal and animals_in_range.has(body):
		animals_in_range.erase(body)

		if animals_in_range.size() <= 0:
			animals_in_range.resize(0)


func _deal_damage() -> void:
	if animals_in_range.size() <= 0:
		can_deal_damage = true

	if animals_in_range.size() > 0 and can_deal_damage:
		can_deal_damage = false

		for animal in animals_in_range:
			if current_attack_evolution != Attack_Evolution.SPRAY:
				animal.take_damage(current_damage, current_attack_modifier)
			else:
				_fire_projectile(animal)

			if animal.current_status == animal.STATUS.DEAD and current_attack_evolution != Attack_Evolution.SPRAY:
				_consume_resources(animal)

		await get_tree().create_timer(damage_delay).timeout
		can_deal_damage = true


func _fire_projectile(animal: Animal) -> void:
	var projectile_instance: Projectile = projectile.instantiate()

	projectile_instance.global_position = global_position

	var attack_vector: Vector2 = animal.global_position - global_position
	var projectile_velocity: Vector2 = attack_vector.normalized() * attack_speed

	projectile_instance.spawn(current_damage, current_attack_range_CS2D.shape.radius * self.scale.x, projectile_velocity, 1)
	get_tree().root.add_child(projectile_instance)


func _consume_resources(animal: Animal) -> void:
	_modify_health(animal.restore_health_value)
	_modify_dna(animal.dna_awarded)

	var current_scale = self.scale
	var consume_tween = create_tween().tween_property(self, "scale", self.scale*Vector2(.7,1.3), 0.075)
	await consume_tween.finished
	var return_tween = create_tween().tween_property(self, "scale", current_scale, 0.05)


func take_damage(damage_amount: float, damage_modifier: int) -> void:
	_modify_health(-1 * damage_amount * armor_multiplier)
	player_took_damage.emit()

	var original_color: Color = body_sprite.modulate

	var tween = create_tween().tween_property(self, "modulate", Color.RED, 1)

	await tween.finished

	create_tween().tween_property(self, "modulate", original_color, 0.2)



func _regen_health() -> void:
	if can_regen:
		can_regen = false

		_modify_health(regen_amount)
		await get_tree().create_timer(regen_timer).timeout

		can_regen = true


func _modify_health(delta: float) -> void:
	health += delta

	health_modified.emit(health)

	if health <= 0:
		get_tree().paused = true
		player_died.emit()


func _modify_dna(delta: int) -> void:
	stored_dna += delta
	dna_modified.emit(stored_dna)

#endregion
