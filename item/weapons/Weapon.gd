class_name Weapon extends Node3D

@export_category("Weapon transforms")
@export var default_position : Vector3
@export var default_rotation : Vector3
@export var ads_position : Vector3
@export var ads_rotation : Vector3

@export_category("Animations & Audio")
@export var animation_player: AnimationPlayer
@export var fire_audio: AudioStreamPlayer

@export_category("Dynamic Recoil")
@export var recoil_rotation_x: Curve
@export var recoil_rotation_y: Curve
@export var recoil_rotation_z: Curve
@export var recoil_position_z: Curve
@export var recoil_amplitude := Vector3.ONE
@export var lerp_speed: float = 1.0

# Dynamic Recoil
var recoil_amplitude_modifier := 1.0
var current_time: float = 0.0
var target_rot: Vector3
var target_pos: Vector3

var ads := false
const ADS_LERP := 20


func _process(delta):
	if ads:
		position = position.lerp(ads_position, ADS_LERP * delta)
		rotation = rotation.lerp(ads_rotation, ADS_LERP * delta)
	else:
		position = position.lerp(default_position, ADS_LERP * delta)
		rotation = rotation.lerp(default_rotation, ADS_LERP * delta)
	
	lerp_recoil(delta)


func fire(rof=60.0):
	print("WeaponModel: Firing")
	
	EventBus.weapon_fired.emit()
	
	apply_recoil()
	
	if fire_audio:
		fire_audio.pitch_scale = randf_range(0.9, 1.05)
		fire_audio.play()
		
	if animation_player:
		animation_player.play("fire", -1, rof / 60.0)
		await animation_player.animation_finished
		
	else:
		await get_tree().create_timer(1.0 / (rof / 60.0)).timeout


func unequip():
	print("%s: Unequipping" % name)
	if animation_player:
		animation_player.play("unequip")
		await animation_player.animation_finished


func equip(fast):
	print("%s: Equipping" % name)
	if !fast and animation_player:
		animation_player.play("equip")
		await animation_player.animation_finished


func reload():
	print("%s: Reloading" % name)
	if animation_player:
		animation_player.play("reload")
		await animation_player.animation_finished


func lerp_recoil(delta: float) -> void:
	# If weapon just fired
	if current_time < 0.05:
		# Increment timer
		current_time += delta
		
		# Lerp to the rotation/position given by the apply_recoil function
		position.z = lerp(position.z, target_pos.z, lerp_speed * delta)
		rotation.z = lerp(rotation.z, target_rot.z, lerp_speed * delta)
		rotation.x = lerp(rotation.x, target_rot.x, lerp_speed * delta)

		# Adjust target rotation/position for next physics tic
		target_rot.z = recoil_rotation_z.sample(current_time) * recoil_amplitude.y * recoil_amplitude_modifier
		target_rot.x = recoil_rotation_x.sample(current_time) * -recoil_amplitude.x * recoil_amplitude_modifier
		target_pos.z = recoil_position_z.sample(current_time) * recoil_amplitude.z * recoil_amplitude_modifier


func apply_recoil():
	# Randomize which y direction the gun rotates
	recoil_amplitude.y *= -1 if randf() > 0.6 else 1
	
	# Rotate
	target_rot.z = recoil_rotation_z.sample(0)
	target_rot.x = recoil_rotation_x.sample(0)
	target_rot.y = recoil_rotation_y.sample(0) * 0.1
	
	# Move gun backwards
	target_pos.z = recoil_position_z.sample(0)
	current_time = 0
