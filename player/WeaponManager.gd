class_name WeaponManager extends Node3D

signal weapon_equipped(weapon_slot_index)
signal weapon_unequipped(weapon_slot_index)
signal weapon_array_updated(weapon_array)

var debug_bullet := preload("res://object/debug/debug_bullet.tscn")

var max_weapon_slots: int = 2
var active_weapon_slot_index: int = 0:
	set(val):
		active_weapon_slot_index = val
		print("WeaponManager: Active weapon slot set to %s" % active_weapon_slot_index)

var weapon_resource_array: Array[ItemDataWeapon]	# Stores the Weapon's resource data
var player_model : Node3D


func _ready():
	weapon_resource_array.resize(2)
	print("WeaponManager: weapon_resource_array size: %s" % weapon_resource_array.size())

	EventBus.add_weapon.connect(_on_add_weapon)
	EventBus.remove_weapon.connect(_on_remove_weapon)


## Weapon Management
func _on_add_weapon(weapon_slot_index, weapon_resource: ItemDataWeapon):
	weapon_resource_array[weapon_slot_index] = weapon_resource
	print("WeaponManager: Added %s in slot %s" % [weapon_resource.name, weapon_slot_index])
	
	if weapon_slot_index == active_weapon_slot_index:
		if player_model != null:
			unequip_weapon()
		equip_weapon()


func _on_remove_weapon(weapon_slot_index):
	print("WeaponManager: Removed weapon in slot %s" % weapon_slot_index)
	
	if weapon_slot_index == active_weapon_slot_index:
		if player_model != null:
			unequip_weapon()
	
	weapon_resource_array[weapon_slot_index] = null


func set_active_weapon_slot(weapon_slot_index):
	if !weapon_resource_array[weapon_slot_index]:
		print("WeaponManager: Slot is empty, cannot change")
		return
	if active_weapon_slot_index == weapon_slot_index:
		return
	
	active_weapon_slot_index = weapon_slot_index
	EventBus.active_weapon_changed.emit(active_weapon_slot_index)
	print("WeaponManager: Active slot = ", active_weapon_slot_index)
	
	
	if player_model != null:
		unequip_weapon()
	equip_weapon()


func fire_weapon():
	if !weapon_resource_array[active_weapon_slot_index]:
		print("WeaponManager: Slot is empty, cannot fire")
		return
	
	# Do raycast method
	var camera_collision = get_camera_collision(weapon_resource_array[active_weapon_slot_index].base_range)
	
	# Call the weapon resource's fire function to increment ammo
	weapon_resource_array[active_weapon_slot_index].fire()
	# Call the weapon model's fire function for animation
	player_model.fire()


func equip_weapon():
	print("WeaponManager: Equip weapon %s" % active_weapon_slot_index)
	player_model = weapon_resource_array[active_weapon_slot_index].player_model.instantiate()
	PlayerManager.player.FPS_RIG.add_child(player_model)
	
	# TODO: Temporary fix for weapon render placement, will be replaced w/ anims
	player_model.position = weapon_resource_array[active_weapon_slot_index].default_position
	player_model.rotation = weapon_resource_array[active_weapon_slot_index].default_rotation


func unequip_weapon():
	print("WeaponManager: Unequip weapon %s" % active_weapon_slot_index)
	player_model.unequip()


func get_camera_collision(distance) -> Vector3:
	var camera_ = get_viewport().get_camera_3d()
	var viewport_size = get_viewport().get_size()
	
	# Set raycast origin to center of viewport
	var ray_origin = camera_.project_ray_origin(viewport_size/2)
	# Set raycast end to the distance specified (weapon distance for hitscan, custom distance for projectile)
	var ray_end = ray_origin + camera_.project_ray_normal(viewport_size/2) * distance
	
	var new_intersection = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var intersection: Dictionary = get_world_3d().direct_space_state.intersect_ray(new_intersection)
	
	# Detect if the ray is colliding with anything
	if not intersection.is_empty():
		var col_point = intersection.position
		create_hit_indicator(col_point)
		# TODO: Disabling for debug due to bullet inheriting oblique angles close to colliders
		#return col_point
		#else:
	return ray_end


func create_hit_indicator(_position: Vector3) -> void:
	var hit_indicator : Node3D = debug_bullet.instantiate()
	hit_indicator.modulate = Color(0.1,0.0,1.0)
	hit_indicator.transform.scaled(Vector3(0.5,0.5,0.5))
	var world = get_tree().get_root().get_child(0)
	world.add_child(hit_indicator)
	hit_indicator.global_translate(_position)
