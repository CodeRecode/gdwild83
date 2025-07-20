extends CharacterBody2D
class_name Player


const DEFAULT_SPEED: int = 6000
const DEFAULT_ATTACK_RADIUS: int = 16
const ARMOR_DEFAULT: float = 1.0
const ARMOR_DAMAGE_REDUCTION: float = 0.7


signal health_modified(new_value: float)
signal dna_modified(new_value: int)
signal evolution_triggered(name1: String, name2: String)
signal evolution_complete(new_level: int)

signal player_died()
signal player_took_damage()
signal zoom_camera(new_value: float)

var current_speed: int = 5000
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var current_attack_range_CS2D = $Scalars/AttackRangeArea2D/AttackRange

@onready var scalars: Node2D = $Scalars
@onready var body_sprite: AnimatedSprite2D = $Scalars/BodySprite
@onready var legs_sprite: AnimatedSprite2D = $Scalars/LegsSprite
@onready var weapon_sprite: AnimatedSprite2D = $Scalars/WeaponSprite

@onready var hit_fx_player: AudioStreamPlayer2D = $HitFxPlayer
@onready var background: Sprite2D = $Background


@export var health: float = 10.0
@export var regen_amount: int = 1
@export var regen_timer: float = 2.0
var can_regen: bool = false
var armor_multiplier: float = 1.0


@export var stored_dna: int = 0
@export var evolution_thresholds: Array[int] = [10, 50, 250, 500]
@export var evolution_scales: Array[float] = [1.0, 1.5, 2.0, 3.0, 5.0]
@export var camera_scales: Array[float] = [1.0, .8, .6, .4, .3]
var evolution_level: int = 0
var choosing_evolution: bool = false


var projectile = preload("res://projectile.tscn")


@export var current_damage: int = 1
@export var damage_delay: float = 0.5
@export var attack_speed: float = 25000.0
var can_deal_damage: bool = false
var tween_once: bool = true
var animals_in_range: Array[Animal] = []


@export var current_attack_evolution: Attack_Evolution = Attack_Evolution.NONE
@export var current_attack_modifier: Attack_Modifier = Attack_Modifier.NONE
@export var current_movement_evolution: Movement_Evolution = Movement_Evolution.NONE
@export var current_health_evolution: Health_Evolution = Health_Evolution.NONE


var tentacles_modifier: float = 0.3


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

	create_tween().tween_property(body_sprite, "material:shader_parameter/hit_color", Color.BLACK, 0.001)
	create_tween().tween_property(legs_sprite, "material:shader_parameter/hit_color", Color.BLACK, 0.001)
	create_tween().tween_property(weapon_sprite, "material:shader_parameter/hit_color", Color.BLACK, 0.001)

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
	if health > 0:
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

	background.material.set("shader_parameter/player_position", global_position)

#region Evolution

func _update_attack_radius(new_radius: float) -> void:
	current_attack_range_CS2D.shape.radius =  collision_shape_2d.shape.radius + new_radius


func _update_attack(new_attack_evolution: Attack_Evolution) -> void:
	if  new_attack_evolution == Attack_Evolution.NONE:
		current_attack_evolution = Attack_Evolution.NONE
		_update_attack_radius(DEFAULT_ATTACK_RADIUS)
		return

	_scale_evolve()
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

			current_damage = 4
			damage_delay = 0.5

			if current_movement_evolution == Movement_Evolution.TENTACLES_BASIC:
				current_damage *= 1 + tentacles_modifier
				damage_delay *= 1 - tentacles_modifier

		Attack_Evolution.SPRAY:
			weapon_sprite.play("spray")
			current_attack_evolution =Attack_Evolution.SPRAY
			_update_attack_radius(DEFAULT_ATTACK_RADIUS + 64)

			current_damage = 2
			damage_delay = 1.5

			if current_movement_evolution == Movement_Evolution.TENTACLES_BASIC:
				current_damage *= 1 + tentacles_modifier
				damage_delay *= 1 - tentacles_modifier
				attack_speed *= 1 + tentacles_modifier


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

	_scale_evolve()
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
	evolution_complete.emit(evolution_level)
#endregion


#region Combat
func _on_attack_range_area_2d_body_entered(body: CharacterBody2D) -> void:
	if body is Animal and not animals_in_range.has(body):
		animals_in_range.append(body)


func _on_attack_range_area_2d_body_exited(body: CharacterBody2D) -> void:
	if body is Animal and animals_in_range.has(body):
		animals_in_range.erase(body)

		if animals_in_range.size() <= 0:
			animals_in_range.clear()


func _deal_damage() -> void:
	if animals_in_range.size() < 1:
		can_deal_damage = true

	if animals_in_range.size() > 0 and can_deal_damage:
		can_deal_damage = false
		tween_once = true
		var animal_position: Vector2 = animals_in_range[0].position

		for animal in animals_in_range:
			if animal.current_status == animal.STATUS.DEAD:
				animals_in_range.erase(animal)
				pass

			if current_attack_evolution != Attack_Evolution.SPRAY:
				animal.take_damage(current_damage, current_attack_modifier)
			else:
				_fire_projectile(animal)

			if animal.current_status == animal.STATUS.DEAD and current_attack_evolution != Attack_Evolution.SPRAY:
				_consume_resources(animal)
				if animals_in_range.has(animal):
					animals_in_range.erase(animal)

		if tween_once:
			var animal_direction = (animal_position - scalars.position).normalized() * 10 * scalars.scale

			var original_position = scalars.position
			var tween = create_tween().tween_property(scalars, "position", original_position + animal_direction, 0.075)
			await tween.finished
			var end_tween = create_tween().tween_property(scalars, "position", original_position, 0.05)
			await  end_tween.finished

			tween_once = false

		await get_tree().create_timer(damage_delay - 0.075 - 0.05).timeout
		can_deal_damage = true


func _fire_projectile(animal: Animal) -> void:
	var projectile_instance: Projectile = projectile.instantiate()

	projectile_instance.global_position = global_position

	var attack_vector: Vector2 = animal.global_position - global_position
	var projectile_velocity: Vector2 = attack_vector.normalized() * attack_speed

	projectile_instance.spawn(current_damage, current_attack_range_CS2D.shape.radius * scalars.scale.x, projectile_velocity, 1)
	get_tree().root.add_child(projectile_instance)


var consume_tweening = false
func _consume_resources(animal: Animal) -> void:
	_modify_health(animal.restore_health_value)
	_modify_dna(animal.dna_awarded)

	# Don't set scale if we're going to evolve
	if evolution_level < evolution_thresholds.size() and stored_dna > evolution_thresholds[evolution_level]:
		return

	# don't double play
	if consume_tweening:
		return

	consume_tweening = true

# Additive color, set factor 0-1 to increase/decrease the greenness
	var green_factor = .3
	var tween_in_time = .1
	var tween_out_time = .15

	var current_scale = scalars.scale
	var enter_tween = create_tween()
	enter_tween.tween_property(scalars, "scale", current_scale*Vector2(1.2,1.2), tween_in_time)

	create_tween().tween_property(body_sprite, "material:shader_parameter/hit_color", Color.GREEN * green_factor, tween_in_time)
	create_tween().tween_property(legs_sprite, "material:shader_parameter/hit_color", Color.GREEN * green_factor, tween_in_time)
	create_tween().tween_property(weapon_sprite, "material:shader_parameter/hit_color", Color.GREEN * green_factor, tween_in_time)

	await enter_tween.finished

	var exit_tween = create_tween().tween_property(scalars, "scale", current_scale, tween_out_time)

	create_tween().tween_property(body_sprite, "material:shader_parameter/hit_color", Color.BLACK, tween_out_time)
	create_tween().tween_property(legs_sprite, "material:shader_parameter/hit_color", Color.BLACK, tween_out_time)
	create_tween().tween_property(weapon_sprite, "material:shader_parameter/hit_color", Color.BLACK, tween_out_time)

	await exit_tween.finished

	consume_tweening = false


func take_damage(damage_amount: float, damage_modifier: int) -> void:
	_modify_health(-1 * damage_amount * armor_multiplier)
	hit_fx_player.play()
	player_took_damage.emit()

	# Additive color, set factor 0-1 to increase/decrease the redness
	var red_factor = .2
	var tween_in_time = .05
	var tween_out_time = .15

	var tween = create_tween().tween_property(body_sprite, "material:shader_parameter/hit_color", Color.RED * red_factor, tween_in_time)
	create_tween().tween_property(legs_sprite, "material:shader_parameter/hit_color", Color.RED * red_factor, tween_in_time)
	create_tween().tween_property(weapon_sprite, "material:shader_parameter/hit_color", Color.RED * red_factor, tween_in_time)

	await tween.finished

	create_tween().tween_property(body_sprite, "material:shader_parameter/hit_color", Color.BLACK, tween_out_time)
	create_tween().tween_property(legs_sprite, "material:shader_parameter/hit_color", Color.BLACK, tween_out_time)
	create_tween().tween_property(weapon_sprite, "material:shader_parameter/hit_color", Color.BLACK, tween_out_time)


func _scale_evolve() -> void:
	var new_scale = evolution_scales[evolution_level + 1]
	collision_shape_2d.scale = Vector2(new_scale, new_scale)
	scalars.scale = Vector2(new_scale, new_scale)

	zoom_camera.emit(camera_scales[evolution_level + 1])


func _regen_health() -> void:
	if can_regen:
		can_regen = false

		_modify_health(regen_amount)

		var green_factor = .2
		var tween_in_time = .075
		var tween_out_time = .15

		var current_scale = scalars.scale

		#var enter_tween = create_tween().tween_property(scalars, "scale", scalars.scale*Vector2(.7,1.3), tween_in_time)

		var enter_tween = create_tween().tween_property(body_sprite, "material:shader_parameter/hit_color", Color.GREEN * green_factor, tween_in_time)
		create_tween().tween_property(legs_sprite, "material:shader_parameter/hit_color", Color.GREEN * green_factor, tween_in_time)
		create_tween().tween_property(weapon_sprite, "material:shader_parameter/hit_color", Color.GREEN * green_factor, tween_in_time)

		await enter_tween.finished

		#var exit_tween = create_tween().tween_property(scalars, "scale", current_scale, tween_out_time)

		var exit_tween = create_tween().tween_property(body_sprite, "material:shader_parameter/hit_color", Color.BLACK, tween_out_time)
		create_tween().tween_property(legs_sprite, "material:shader_parameter/hit_color", Color.BLACK, tween_out_time)
		create_tween().tween_property(weapon_sprite, "material:shader_parameter/hit_color", Color.BLACK, tween_out_time)

		await exit_tween.finished

		await get_tree().create_timer(regen_timer - tween_in_time - tween_out_time).timeout

		can_regen = true


func _modify_health(delta: float) -> void:
	health += delta

	health_modified.emit(health)

	if health <= 0:
		player_took_damage.emit()
		hit_fx_player.play()

# Additive color, set factor 0-1 to increase/decrease the redness
		var red_factor = .4
		var tween_in_time = 0.25

		var tween = create_tween().tween_property(body_sprite, "material:shader_parameter/hit_color", Color.RED * red_factor, tween_in_time)
		create_tween().tween_property(legs_sprite, "material:shader_parameter/hit_color", Color.RED * red_factor, tween_in_time)
		create_tween().tween_property(weapon_sprite, "material:shader_parameter/hit_color", Color.RED * red_factor, tween_in_time)

		await tween.finished

		get_tree().paused = true
		player_died.emit()


func _modify_dna(delta: int) -> void:
	stored_dna += delta
	dna_modified.emit(stored_dna)

#endregion
