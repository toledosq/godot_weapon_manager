extends Camera3D


var base_recoil_pitch_strength = 2.5
var randomness_factor = 0.5
var recoil_return_speed = 2.0
var sway_return_speed = 4.0
var original_rotation_degrees = Vector3.ZERO
var target_rotation_degrees = Vector3.ZERO
var fps_rig_original_position = Vector3.ZERO


@onready var fps_rig = $FPSRig


func _ready():
	# Store starting rotation if different
	original_rotation_degrees = rotation_degrees
	
	# Connect to the weapon fired event for recoil effect
	EventBus.weapon_fired.connect(apply_recoil)


func _process(delta):
	# Interpolate from current rotation to the original rotation
	rotation_degrees = rotation_degrees.lerp(original_rotation_degrees, recoil_return_speed * delta)
	fps_rig.position = fps_rig.position.lerp(fps_rig_original_position, sway_return_speed * 2 * delta)


func sway(sway_amount):
	fps_rig.position.y += sway_amount.y * 0.0001
	fps_rig.position.x -= sway_amount.x * 0.0001


func apply_recoil():
	# Apply random recoil effect
	target_rotation_degrees.x = rotation_degrees.x + base_recoil_pitch_strength + randf_range(-randomness_factor, randomness_factor)
	# Optional: add randomized yaw recoil for horizontal shake
	target_rotation_degrees.y = rotation_degrees.y + randf_range(-randomness_factor, randomness_factor)
	
	rotation_degrees = lerp(rotation_degrees, target_rotation_degrees, 0.6)


func change_fov(value: float, speed: float = 0.1):
	fov = lerp(fov, value, speed)
