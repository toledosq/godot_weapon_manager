class_name ItemDataWeaponRanged extends ItemDataWeapon

@export var current_ammo: int
@export var ammo_type: String # TODO: this should be an enum defined somewhere globally
@export var projectile: PackedScene

func fire():
	print("%s: Firing" % [name])
	current_ammo -= 1
	print("%s: Remaining ammo - %s" % [name, current_ammo])
