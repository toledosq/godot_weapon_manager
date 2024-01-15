extends Camera3D

var base_recoil_pitch_strength = 3.0
var randomness_factor = 0.5
var return_speed = 5.0
var original_rotation_degrees = Vector3.ZERO
var target_rotation_degrees = Vector3.ZERO


func _ready():
	original_rotation_degrees = rotation_degrees
	EventBus.weapon_fired.connect(apply_recoil)


func _process(delta):
	# Interpolate from current rotation to the original rotation
	rotation_degrees = rotation_degrees.lerp(original_rotation_degrees, return_speed * delta)


func apply_recoil():
	# Apply random recoil effect
	target_rotation_degrees.x = original_rotation_degrees.x + base_recoil_pitch_strength + randf_range(-randomness_factor, randomness_factor)
	# Optional: add randomized yaw recoil for horizontal shake
	target_rotation_degrees.y = original_rotation_degrees.y + randf_range(-randomness_factor, randomness_factor)
	
	rotation_degrees = target_rotation_degrees
