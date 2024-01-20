class_name Player extends CharacterBody3D

enum STATES { NORMAL, CROUCHING, SPRINTING }
var state: STATES = STATES.NORMAL

@export_category("Character")
@export var base_speed : float = 3.0
@export var sprint_speed : float = 6.0
@export var crouch_speed : float = 1.0

@export var acceleration : float = 10.0
@export var jump_velocity : float = 4.5
@export var mouse_sensitivity : float = 0.1

@export var initial_facing_direction : Vector3 = Vector3.ZERO

@export_group("Nodes")
@export var HEAD : Node3D
@export var CAMERA : Camera3D
@export var FPS_RIG : Node3D
@export var RETICLE : Reticle
@export var COLLISION_MESH : CollisionShape3D
@export var CROUCHED_CEILING_DETECT : RayCast3D
@export var INTERACT_RAY : RayCast3D
@export var WEAPON_MANAGER : WeaponManager
@export var HEALTH_MANAGER : HealthManager

@export_group("Controls")
@export var JUMP : String = "jump"
@export var LEFT : String = "move_left"
@export var RIGHT : String = "move_right"
@export var FORWARD : String = "move_forward"
@export var BACKWARD : String = "move_backward"
@export var PAUSE : String = "ui_cancel"
@export var CROUCH : String = "crouch"
@export var SPRINT : String = "sprint"

# Uncomment for full controller support
#@export var LOOK_LEFT : String
#@export var LOOK_RIGHT : String
#@export var LOOK_UP : String
#@export var LOOK_DOWN : String

@export_group("Feature Settings")
@export var immobile : bool = false
@export var jumping_enabled : bool = true
@export var in_air_momentum : bool = true
@export var motion_smoothing : bool = true
@export var sprint_enabled : bool = true
@export var crouch_enabled : bool = true
@export_enum("Hold to Crouch", "Toggle Crouch") var crouch_mode : int = 0
@export_enum("Hold to Sprint", "Toggle Sprint") var sprint_mode : int = 0
@export var dynamic_fov : bool = true
@export var continuous_jumping : bool = true

@export_group("Inventory")
@export var inventory_data: InventoryData
@export var armor_inventory_data: InventoryDataArmor
@export var weapon_inventory_data: InventoryDataWeapon
@export var grenade_inventory_data: InventoryDataGrenade

signal toggle_inventory()

# Member variables
var speed : float = base_speed

var low_ceiling : bool = false # This is for when the cieling is too low and the player needs to crouch.
var is_ads : bool = false


# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity") # Don't set this as a const, see the gravity section in _physics_process


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	EventBus.set_active_player.emit(self)
	
	# Set the camera rotation to initial facing direction
	if initial_facing_direction and HEAD.rotation_degrees != Vector3.ZERO:
		HEAD.set_rotation_degrees(initial_facing_direction)


func _process(delta):
	
	if Input.is_action_just_pressed(PAUSE):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if Input.is_action_just_released("weapon_ads"):
		toggle_ads(false)
	
	if Input.is_action_pressed("weapon_ads"):
		if state != STATES.SPRINTING:
			toggle_ads(true)
	
	if Input.is_action_just_pressed("test_health"):
		hit(5)
	
	HEAD.rotation.x = clamp(HEAD.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	# Uncomment if you want full controller support
	#var controller_view_rotation = Input.get_vector(LOOK_LEFT, LOOK_RIGHT, LOOK_UP, LOOK_DOWN)
	#HEAD.rotation_degrees.y -= controller_view_rotation.x * 1.5
	#HEAD.rotation_degrees.x -= controller_view_rotation.y * 1.5


func _physics_process(delta):
	# TODO: Move to it's own debug component
	
	# Gravity
	#gravity = ProjectSettings.get_setting("physics/3d/default_gravity") # If the gravity changes during your game, uncomment this code
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	handle_jumping()
	
	var input_dir = Vector2.ZERO
	if !immobile:
		input_dir = Input.get_vector(LEFT, RIGHT, FORWARD, BACKWARD)
	handle_movement(delta, input_dir)
	
	low_ceiling = CROUCHED_CEILING_DETECT.is_colliding()
	
	handle_state(input_dir)
	
	if dynamic_fov:
		update_camera_fov()
	update_collision_scale()


func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		HEAD.rotation_degrees.y -= event.relative.x * mouse_sensitivity
		HEAD.rotation_degrees.x -= event.relative.y * mouse_sensitivity
		
		CAMERA.sway(Vector2(event.relative.x, event.relative.y))
	
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit()


func handle_jumping():
	if jumping_enabled and is_on_floor():
		if continuous_jumping and Input.is_action_pressed(JUMP):
			velocity.y += jump_velocity
		elif Input.is_action_just_pressed(JUMP):
			velocity.y += jump_velocity


func handle_movement(delta, input_dir):
	var direction = input_dir.rotated(-HEAD.rotation.y)
	direction = Vector3(direction.x, 0, direction.y)
	move_and_slide()
	
	if in_air_momentum:
		if is_on_floor():
			if motion_smoothing:
				velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
				velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
			else:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
	else:
		if motion_smoothing:
			velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
			velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
		else:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed


#region Player State Management (crouching, sprinting, normal)
func handle_state(moving):
	# Handle sprinting
	if sprint_enabled:
		handle_sprinting(moving)

	# Handle crouching
	if crouch_enabled:
		handle_crouching(moving)


func handle_sprinting(moving):
	if sprint_mode == 0:
		handle_sprint_mode_0(moving)
	elif sprint_mode == 1:
		handle_sprint_mode_1(moving)


func handle_sprint_mode_0(moving):
	var is_sprinting = Input.is_action_pressed(SPRINT) and not Input.is_action_pressed(CROUCH)
	if is_sprinting and moving and state != STATES.SPRINTING:
		enter_sprint_state()
	elif (not is_sprinting or not moving) and state == STATES.SPRINTING:
		enter_normal_state()


func handle_sprint_mode_1(moving):
	if moving and Input.is_action_just_pressed(SPRINT):
		state = STATES.SPRINTING if state == STATES.NORMAL else STATES.NORMAL
		enter_sprint_state() if state == STATES.SPRINTING else enter_normal_state()
	elif not moving and state == STATES.SPRINTING:
		enter_normal_state()


func handle_crouching(moving):
	if crouch_mode == 0:
		handle_crouch_mode_0(moving)
	elif crouch_mode == 1:
		handle_crouch_mode_1(moving)


func handle_crouch_mode_0(moving):
	var is_crouching = Input.is_action_pressed(CROUCH) and not Input.is_action_pressed(SPRINT)
	if is_crouching and state != STATES.CROUCHING:
		enter_crouch_state()
	elif not is_crouching and state == STATES.CROUCHING and not low_ceiling:
		enter_normal_state()


func handle_crouch_mode_1(moving):
	if Input.is_action_just_pressed(CROUCH):
		if state == STATES.NORMAL:
			enter_crouch_state()
		elif state == STATES.CROUCHING and not low_ceiling:
			enter_normal_state()


# Any enter state function should only be called once when you want to enter that state, not every frame.
func enter_normal_state():
	#print("entering normal state")
	var prev_state = state
	state = STATES.NORMAL
	speed = base_speed

func enter_crouch_state():
	#print("entering crouch state")
	var prev_state = state
	state = STATES.CROUCHING
	speed = crouch_speed

func enter_sprint_state():
	#print("entering sprint state")
	var prev_state = state
	state = STATES.SPRINTING
	speed = sprint_speed
	toggle_ads(false)
#endregion


func update_camera_fov():
	if state == STATES.SPRINTING:
		CAMERA.fov = lerp(CAMERA.fov, 85.0, 0.1)
	elif is_ads:
		CAMERA.fov = lerp(CAMERA.fov, 65.0, 0.3)
	else:
		CAMERA.fov = lerp(CAMERA.fov, 75.0, 0.3)


func update_collision_scale():
	# Add animation here
	# TODO: This causes a bug with the collision detection and the Ceiling detection
	if state == STATES.CROUCHING: 
		COLLISION_MESH.scale.y = lerp(COLLISION_MESH.scale.y, 0.5, 0.2)
	else:
		COLLISION_MESH.scale.y = lerp(COLLISION_MESH.scale.y, 1.0, 0.2)


# Handled here due to sprinting cancel and reticle
func toggle_ads(ads: bool):
	is_ads = ads
	WEAPON_MANAGER.ads = ads
	RETICLE.visible = !ads


func get_drop_position() -> Vector3:
	# Get forward facing direction from camera
	var direction = -CAMERA.global_transform.basis.z
	return CAMERA.global_position + direction


func hit(damage):
	HEALTH_MANAGER.hit(damage)


func heal(amount):
	HEALTH_MANAGER.heal(amount)
