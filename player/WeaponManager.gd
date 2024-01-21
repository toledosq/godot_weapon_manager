class_name WeaponManager extends Node3D

enum STATES { NONE, NOT_READY, READY, FIRING, RELOADING }
var STATE = STATES.NONE

signal weapon_equipped(weapon_slot_index)
signal weapon_unequipped(weapon_slot_index)
signal weapon_array_updated(weapon_array)

@export var ammo_reserve: AmmoReserve

var debug_bullet := preload("res://object/debug/debug_bullet.tscn")
var grenade_scene := preload("res://item/weapons/grenade.tscn")

var max_weapon_slots: int = 2
var active_weapon_slot_index: int = 0:
	set(val):
		active_weapon_slot_index = val
		print("WeaponManager: Active weapon slot set to %s" % active_weapon_slot_index)
var grenade_data: SlotData
var single_fire: bool = true

var weapon_resource_array: Array[ItemDataWeapon]	# Stores the Weapon's resource data
var grenade_slot: SlotData
var weapon_model : Node3D
var return_position : Vector3
var return_rotation : Vector3

var ads := false
const ADS_LERP := 20
var default_position : Vector3
var default_rotation : Vector3
var ads_position : Vector3
var ads_rotation : Vector3

# Dynamic Recoil vars
var recoil_amplitude_modifier := 1.0
var target_rot: Vector3
var target_pos: Vector3
var current_time: float


func _ready():
	weapon_resource_array.resize(max_weapon_slots)
	print("WeaponManager: weapon_resource_array size: %s" % weapon_resource_array.size())
	
	EventBus.add_weapon.connect(_on_add_weapon)
	EventBus.remove_weapon.connect(_on_remove_weapon)
	EventBus.add_grenade.connect(_on_add_grenade)
	EventBus.remove_grenade.connect(_on_remove_grenade)
	EventBus.attachment_added.connect(equip_attachment)
	active_weapon_slot_index = 0
	
	PlayerManager.player_ready.connect(_on_player_ready)


func _process(delta):
	if weapon_model and STATE != STATES.NONE:
		if ads:
			weapon_model.ads = true
		else:
			weapon_model.ads = false
	
	# Only do this if the player is controlling character
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		handle_input()


func force_ui_refresh():
	EventBus.reserve_ammo_changed.emit(ammo_reserve.ammo_reserve)
	if weapon_resource_array[active_weapon_slot_index] != null:
		EventBus.weapon_equipped.emit(weapon_resource_array[active_weapon_slot_index].name)
		EventBus.weapon_ammo_changed.emit(weapon_resource_array[active_weapon_slot_index].current_ammo)
	else:
		EventBus.weapon_equipped.emit("No weapon equipped")
		EventBus.weapon_ammo_changed.emit("")


func handle_input():
	if STATE == STATES.READY:
		if single_fire:
			if Input.is_action_just_pressed("weapon_fire"):
				fire_weapon()
		else:
			if Input.is_action_pressed("weapon_fire"):
				fire_weapon()
		
		if Input.is_action_just_pressed("weapon_reload"):
			reload_weapon()
		
	if Input.is_action_just_pressed("primary_weapon"):
		print("WeaponManager: Equip primary weapon")
		set_active_weapon_slot(0)
	
	if Input.is_action_just_pressed("secondary_weapon"):
		print("WeaponManager: Equip secondary weapon")
		set_active_weapon_slot(1)
		
	if Input.is_action_just_pressed("weapon_grenade"):
		print("WeaponManager: Throw Grenade")
		throw_grenade()


func change_state(new_state: STATES):
	print("WeaponManager: STATE = ", STATE)
	STATE = new_state


#region Weapon/Inventory Management
func _on_add_weapon(weapon_slot_index, weapon_resource: ItemDataWeapon):
	weapon_resource_array[weapon_slot_index] = weapon_resource
	print("WeaponManager: Added %s in slot %s" % [weapon_resource.name, weapon_slot_index])
	
	if weapon_slot_index == active_weapon_slot_index:
		equip_weapon()


func _on_remove_weapon(weapon_slot_index):
	print("WeaponManager: Removed weapon in slot %s" % weapon_slot_index)
	
	if weapon_slot_index == active_weapon_slot_index:
		if weapon_model != null:
			unequip_weapon()
	
	weapon_resource_array[weapon_slot_index] = null


func _on_add_grenade(slot_data):
	print("Grenade Added")
	grenade_data = slot_data
	EventBus.grenade_ammo_changed.emit(grenade_data.quantity)


func _on_remove_grenade():
	print("Grenade Removed")
	grenade_data = null
	EventBus.grenade_ammo_changed.emit(0)


func set_active_weapon_slot(weapon_slot_index):
	if !weapon_resource_array[weapon_slot_index]:
		print("WeaponManager: Slot is empty, cannot change")
		return
	if active_weapon_slot_index == weapon_slot_index:
		return
	if STATE == STATES.FIRING or STATE == STATES.RELOADING:
		return
	
	active_weapon_slot_index = weapon_slot_index
	
	print("WeaponManager: Active slot = ", active_weapon_slot_index)
	
	equip_weapon()
#endregion#


#region Equipping/Unequipping
func equip_weapon():
	if STATE == STATES.FIRING or STATE == STATES.RELOADING:
		return
	
	change_state(STATES.NOT_READY)
	await unequip_weapon()
	
	print("WeaponManager: Equip weapon %s" % active_weapon_slot_index)
	
	# Render weapon and play equip animation
	if weapon_resource_array[active_weapon_slot_index].weapon_model:
		weapon_model = weapon_resource_array[active_weapon_slot_index].weapon_model.instantiate()
		
		# Equip any attachments already on weapon
		if weapon_resource_array[active_weapon_slot_index].scope:
			equip_attachment(weapon_resource_array[active_weapon_slot_index].scope, active_weapon_slot_index)
		if weapon_resource_array[active_weapon_slot_index].grip:
			equip_attachment(weapon_resource_array[active_weapon_slot_index].grip, active_weapon_slot_index)
		
		PlayerManager.player.FPS_RIG.add_child(weapon_model)
		weapon_model.equip()
	
	# If weapon is single fire, set flag for input switch
	if weapon_resource_array[active_weapon_slot_index].single_fire:
		single_fire = true
	else:
		single_fire = false
	
	# Return to ready
	change_state(STATES.READY)
	
	# Force UI refresh
	force_ui_refresh()


func equip_attachment(attachment_resource: ItemDataAttachment, weapon_slot_index):
	if weapon_slot_index == active_weapon_slot_index and weapon_model:
		weapon_model.equip_attachment(attachment_resource.attachment_type, attachment_resource.attachment_scene)


func unequip_attachment(attachment_resource: ItemDataAttachment, weapon_slot_index):
	if weapon_slot_index == active_weapon_slot_index and weapon_model:
		match attachment_resource.attachment_type:
			1:
				weapon_model.remove_scope()
			2:
				weapon_model.remove_grip()


func unequip_weapon():
	# Check if weapon is being rendered
	if weapon_model == null:
		return
	
	# Change state to NONE
	change_state(STATES.NONE)
	
	print("WeaponManager: Unequip weapon %s" % active_weapon_slot_index)
	
	# Play unequip animation and delete render model
	await weapon_model.unequip()
	weapon_model.queue_free()
	
	# Force UI refresh
	force_ui_refresh()
#endregion


#region Firing/Reloading
func fire_weapon():
	if STATE != STATES.READY:
		return
	
	if !weapon_resource_array[active_weapon_slot_index]:
		print("WeaponManager: Slot is empty, cannot fire")
		return
	
	
	if weapon_resource_array[active_weapon_slot_index] is ItemDataWeaponRanged and weapon_resource_array[active_weapon_slot_index].current_ammo <= 0:
		print("WeaponManager: Cannot fire, no ammo")
		return
	
	# Change state to FIRING
	change_state(STATES.FIRING)
	
	# Do raycast method
	get_camera_collision(weapon_resource_array[active_weapon_slot_index].base_range)
	
	# Call the weapon resource's fire function to decrement weapon ammo
	weapon_resource_array[active_weapon_slot_index].fire()
	
	# Alert UI that weapon ammo changed
	if weapon_resource_array[active_weapon_slot_index] is ItemDataWeaponRanged:
		EventBus.weapon_ammo_changed.emit(weapon_resource_array[active_weapon_slot_index].current_ammo)
		await weapon_model.fire(weapon_resource_array[active_weapon_slot_index].rate_of_fire)
	
	# Change state to READY
	change_state(STATES.READY)


func reload_weapon():
	if STATE != STATES.READY:
		print("WeaponManager: Cannot reload, weapon not ready")
		return
	
	if weapon_resource_array[active_weapon_slot_index].current_ammo >= weapon_resource_array[active_weapon_slot_index].max_ammo:
		print("WeaponManager: Cannot reload, magazine full")
		return
	
	## Ammo Reserve Management
	# Get ammo type from weapon resource
	var ammo_type = weapon_resource_array[active_weapon_slot_index].ammo_type
	var ammo_needed: int = weapon_resource_array[active_weapon_slot_index].max_ammo - weapon_resource_array[active_weapon_slot_index].current_ammo
	# Request that amount from Ammo Reserve
	var reload_amount = ammo_reserve.take_ammo_from_reserve(ammo_type, ammo_needed)
	
	# If no ammo is given, return w/ message
	if reload_amount <= 0:
		print("WeaponManager: Cannot reload, no ammo in reserve")
		return
	
	## Reloading logic
	# Set state to reloading
	change_state(STATES.RELOADING)
	
	# Call player model for animation
	await weapon_model.reload()
	
	# Call resource reload func for ammo mgmt
	weapon_resource_array[active_weapon_slot_index].reload(reload_amount)
	
	# Broadcast reloaded event
	EventBus.weapon_reloaded.emit()
	EventBus.weapon_ammo_changed.emit(weapon_resource_array[active_weapon_slot_index].current_ammo)
	
	# Return to ready
	change_state(STATES.READY)
#endregion


#region Grenade Management
func throw_grenade():
		if !grenade_data:
			print("Cannot throw grenade, no grenades equipped")
			return
			
		if grenade_data.quantity < 1:
			print("Grenades empty")
			return
			
		print("Grenades available: ", grenade_data.quantity)
		# Get reference to camera position and direction
		var camera_ = get_viewport().get_camera_3d()
		var direction = -camera_.global_transform.basis.z
		
		# Bring grenade into the world
		var grenade = grenade_scene.instantiate()
		var world = get_tree().get_root().get_child(0)
		world.add_child(grenade)
		
		# Set grenade's starting position and direction
		grenade.global_position = camera_.global_position + direction
		
		# Throw the grenade
		grenade.throw(direction)
		
		# signal -> EventBus -> PlayerManager -> GrenadeInventory
		EventBus.grenade_thrown.emit()
		EventBus.grenade_ammo_changed.emit(grenade_data.quantity)
		
		# If GrenadeInventory is now empty, sync w/ WeaponManager
		if grenade_data.quantity < 1:
			grenade_data = null
#endregion



	

func get_camera_collision(distance) -> Vector3:
	# Get active camera
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


func _on_player_ready():
	force_ui_refresh()


func _on_get_ammo_type() -> String:
	if STATE != STATES.NONE:
		return weapon_resource_array[active_weapon_slot_index].ammo_type
	else:
		return ""


func _on_refill_ammo_reserve() -> void:
	ammo_reserve.fill_all_ammo_reserve()
	EventBus.reserve_ammo_changed.emit(ammo_reserve.ammo_reserve)
