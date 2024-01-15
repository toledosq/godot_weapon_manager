class_name ItemDataWeaponRanged extends ItemDataWeapon

@export var current_ammo: int
@export var ammo_type: String # TODO: this should be an enum defined somewhere globally
@export var projectile: PackedScene

@export_category("Dynamic Recoil")
@export var dynamic_recoil := false
@export var recoil_rotation_x: Curve
@export var recoil_rotation_y: Curve
@export var recoil_rotation_z: Curve
@export var recoil_position_z: Curve
@export var recoil_amplitude := Vector3.ONE
@export var lerp_speed : float = 1


func fire():
	print("%s: Fire" % [name])
	current_ammo -= 1
	print("%s: Remaining ammo - %s" % [name, current_ammo])
