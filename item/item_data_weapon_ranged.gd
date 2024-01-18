class_name ItemDataWeaponRanged extends ItemDataWeapon

@export var current_ammo: int
@export var max_ammo: int
@export var ammo_type: String # TODO: this should be an enum defined somewhere globally
@export var projectile: PackedScene
@export var rate_of_fire: int = 100


func fire():
	print("%s: Fire" % [name])
	current_ammo -= 1
	print("%s: Remaining ammo - %s" % [name, current_ammo])


func reload(amount):
	current_ammo += amount
	
