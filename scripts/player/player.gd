extends CharacterBody2D
class_name Player

@onready var player_sprite: Sprite2D = get_node("Texture")
@onready var wall_ray: RayCast2D = get_node("WallRay")
@onready var stats: Node = get_node("Stats")
@export var speed: int
@export var jump_speed: int
@export var player_gravity:int
@export var wall_jump_speed:int
@export var wall_gravity:int
@export var wall_impulse_speed:int

var jump_count: int = 0
var landing:bool = false
var on_wall:bool = false
var attacking: bool = false
var defending: bool = false
var crouching: bool = false
var direction:int = 1
var dead: bool = false
var on_hit: bool = false

var can_track_input: bool = true
var not_on_wall: bool = true


func _physics_process(delta: float):
	horizontal_movement_env()
	gravity(delta)
	vertical_movement_env()
	
	actions_env()
	
	player_sprite.animate(velocity)
	move_and_slide()
	

func horizontal_movement_env() -> void:
	var input_direction: float = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if can_track_input == false or attacking:
		velocity.x = 0
		return
	velocity.x = input_direction * speed

func vertical_movement_env() ->void:
	if is_on_floor() or is_on_wall():
		jump_count = 0
		velocity.y = 0
	
	if Input.is_action_just_pressed("ui_select") and jump_count<2 and can_track_input and not attacking:
		jump_count+=1
		if next_to_wall() and not is_on_floor():
			velocity.y = wall_jump_speed
			velocity.x += wall_impulse_speed * direction
		else:
			velocity.y = jump_speed
	

func actions_env() -> void:
	attack()
	crouch()
	defense()
	
func attack() -> void:
	var attack_condition: bool = not attacking and not crouching and not defending
	if Input.is_action_just_pressed("attack") and attack_condition and is_on_floor():
		attacking = true
		player_sprite.normal_attack = true
	
func crouch() -> void:
	if Input.is_action_pressed("crouch") and not defending and is_on_floor():
		crouching = true
		can_track_input=false
		stats.shielding = false
	elif not defending:
		crouching = false
		can_track_input = true
		stats.shielding = false
		player_sprite.crouching_off = true
	
func defense() -> void:
	if Input.is_action_pressed("defense") and not crouching and is_on_floor():
		defending = true
		can_track_input=false
		stats.shielding = true
	elif not crouching:
		defending = false
		stats.shielding = false
		can_track_input = true
		player_sprite.shield_off = true

func gravity(delta:float) -> void:
	if next_to_wall():
		velocity.y += delta * player_gravity
		if velocity.y >= wall_gravity:
			velocity.y = wall_gravity
	else:
		velocity.y += delta * player_gravity
		if velocity.y >= player_gravity:
			velocity.y = player_gravity
		
	
func next_to_wall() -> bool:
	if wall_ray.is_colliding() and not is_on_floor():
		if not_on_wall:
			velocity.y=0
			not_on_wall =true
		return true
	else:
		not_on_wall = true
		return false
	

