class_name Weapon extends Node3D

@export_category("Weapon transforms")
@export var default_position : Vector3
@export var default_rotation : Vector3
@export var ads_position : Vector3
@export var ads_rotation : Vector3

@export_category("Model")
@export var weapon_mesh : Node3D

@export_category("Attachments")
@export var scope_attach_point: Marker3D
@export var underbarrel_attach_point: Marker3D

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


func _ready():
	weapon_mesh.hide()
	pass


func _process(delta):
	if ads:
		position = position.lerp(ads_position, ADS_LERP * delta)
		rotation = rotation.lerp(ads_rotation, ADS_LERP * delta)
	else:
		position = position.lerp(default_position, ADS_LERP * delta)
		rotation = rotation.lerp(default_rotation, ADS_LERP * delta)
	
	lerp_recoil(delta)


func fire(rof=60.0):
	EventBus.weapon_fired.emit()
	
	apply_recoil()
	
	if fire_audio:
		fire_audio.pitch_scale = randf_range(0.9, 1.05)
		fire_audio.play()
		
	if animation_player and animation_player.has_animation("fire"):
		animation_player.play("fire", -1, rof / 60.0)
		await animation_player.animation_finished
		
	else:
		await get_tree().create_timer(1.0 / (rof / 60.0)).timeout


func unequip():
	print("%s: Unequipping" % name)
	if animation_player and animation_player.has_animation("unequip"):
		animation_player.play("unequip")
		await animation_player.animation_finished


func equip():
	print("%s: Equipping" % name)
	if animation_player and animation_player.has_animation("equip"):
		animation_player.play("equip")
		await animation_player.animation_finished
	else:
		weapon_mesh.show()


func reload():
	print("%s: Reloading" % name)
	if animation_player and animation_player.has_animation("reload"):
		animation_player.play("reload")
		await animation_player.animation_finished


func equip_attachment(attachment_type: int, attachment_scene: PackedScene):
	var attachment_instance = attachment_scene.instantiate()
	match attachment_type:
		1:
			attach_scope(attachment_instance)
		2:
			attach_under_barrel(attachment_instance)


func attach_scope(attachment_instance):
	if scope_attach_point.get_child_count() > 0:
		remove_scope()
	
	print("Weapon: Attaching scope")
	scope_attach_point.add_child(attachment_instance)


func attach_under_barrel(attachment_instance):
	if underbarrel_attach_point.get_child_count() > 0:
		remove_underbarrel()
	print("Weapon: Attaching under_barrel")
	underbarrel_attach_point.add_child(attachment_instance)


func remove_scope():
	print("Weapon: Removing scope")
	var scope_instance = scope_attach_point.get_child(0)
	scope_instance.queue_free()


func remove_underbarrel():
	print("Weapon: Removing under_barrel")
	var underbarrel_instance = underbarrel_attach_point.get_child(0)
	underbarrel_instance.queue_free()


func lerp_recoil(delta: float) -> void:
	# If weapon just fired
	if current_time < 0.2:
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
	recoil_amplitude.y *= -1 if randf() > 0.8 else 1
	
	# Rotate
	target_rot.z = recoil_rotation_z.sample(0)
	target_rot.x = recoil_rotation_x.sample(0)
	
	# Move gun backwards
	target_pos.z = recoil_position_z.sample(0)
	current_time = 0.0
