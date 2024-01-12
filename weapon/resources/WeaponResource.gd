class_name WeaponResource extends Resource

@export var name: String
@export var damage: int
@export var max_ammo: int
@export var reload_speed: float


func reload(current_ammo):
	print("reloading ", current_ammo)


func fire():
		print("fire weapon")
