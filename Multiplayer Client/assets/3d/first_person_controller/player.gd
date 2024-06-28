class_name FPCPlayer
extends CharacterBody3D

enum MovementMode
{
	WALKING,
	FLY,
	CROUCHING,
}

const MOUSE_SENSITIVITY = 0.1

@export_range(0.01, 0.99) var deceleration := 0.1
@export var gravity := Vector3.DOWN
@export var mass := 1.5
@export var jump_strength := 25.0
@export var movement_mode := MovementMode.WALKING
@export var can_move := true
@export_group("Speed")
@export var walking_speed := 0.7
@export var running_speed := 1.3
@export var crouching_speed := 0.2
@export var fly_speed := 8.0

@onready var camera: Camera3D = %Camera
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var ray_cast: RayCast3D = $Camera/RayCast3D

var movement_mode_function = {
	MovementMode.WALKING: movement,
	MovementMode.CROUCHING: movement,
	MovementMode.FLY: fly,
}

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _input(event):
	camera_control(event)
	
	if InputMap.has_action("use") && event.is_action_pressed("use"):
		var node = ray_cast.get_collider()
		if node != null && node.has_method("use"):
			node.call("use")

func _unhandled_input(event):
	if event is InputEventMouseButton && event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			fly_speed += 0.5
			get_tree().root.set_input_as_handled()
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			fly_speed = max(0, fly_speed - 0.5)
			get_tree().root.set_input_as_handled()
	
	if InputMap.has_action("crouch") && event.is_action_pressed("crouch") && can_move:
		var mode = MovementMode.CROUCHING if movement_mode == MovementMode.WALKING else MovementMode.WALKING
		movement_mode = mode
		
		if mode == MovementMode.CROUCHING:
			anim_player.play("crouch")
		elif mode == MovementMode.WALKING:
			anim_player.play("stand")
		
		get_tree().root.set_input_as_handled()

func _process(delta: float) -> void:
	if !multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		MP.send_player_transform.rpc_id(1, position, camera.rotation)

func _physics_process(delta):
	movement_mode_function[movement_mode].call()

func camera_control(event: InputEvent):
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED && can_move:
		camera.rotation_degrees.y -= event.relative.x * MOUSE_SENSITIVITY
		camera.rotation_degrees.y = wrap(camera.rotation_degrees.y, 0, 359)
		camera.rotation_degrees.x -= event.relative.y * MOUSE_SENSITIVITY
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -89, 89)

func movement():
	if can_move:
		var input = Vector3()
		var basis_z = Vector3(camera.global_transform.basis.z.x, 0, camera.global_transform.basis.z.z).normalized()
		var basis_x = Vector3(camera.global_transform.basis.x.x, 0, camera.global_transform.basis.x.z).normalized()
		if Input.is_action_pressed("ui_up"):
			input += -basis_z
		if Input.is_action_pressed("ui_down"):
			input += basis_z
		if Input.is_action_pressed("ui_left"):
			input += -basis_x
		if Input.is_action_pressed("ui_right"):
			input += basis_x
		input = input.normalized()
		
		var speed
		if movement_mode == MovementMode.WALKING:
			var run = InputMap.has_action("speed_up") && Input.is_action_pressed("speed_up")
			speed = walking_speed if !run else running_speed
		elif movement_mode == MovementMode.CROUCHING:
			speed = crouching_speed
		
		velocity += input * speed
		
		if InputMap.has_action("jump") && Input.is_action_just_pressed("jump") && is_on_floor():
			velocity.y += jump_strength
	
	velocity += gravity * mass
	
	move_and_slide()
	
	velocity = velocity.lerp(Vector3.ZERO, deceleration)

func fly():
	var input = Vector3()
	var basis_z = Vector3(camera.global_transform.basis.z.x, 0, camera.global_transform.basis.z.z).normalized()
	var basis_x = Vector3(camera.global_transform.basis.x.x, 0, camera.global_transform.basis.x.z).normalized()
	if Input.is_action_pressed("ui_up"):
		input += -basis_z
	if Input.is_action_pressed("ui_down"):
		input += basis_z
	if Input.is_action_pressed("ui_left"):
		input += -basis_x
	if Input.is_action_pressed("ui_right"):
		input += basis_x
	
	if InputMap.has_action("fly_up") && InputMap.has_action("fly_down"):
		input.y = int(Input.is_action_pressed("fly_up")) - int(Input.is_action_pressed("fly_down"))
	
	input = input.normalized()
	
	velocity = input * fly_speed
	move_and_slide()
