class_name ItemDataWeapon extends ItemData

@export_group("Weapon Defaults")
@export var weapon_model: PackedScene
@export var base_damage: int = 20
@export var base_range: int = 1000
@export var single_fire: bool = true
@export var ammo_type: String


func fire():
	pass


func reload(_amount):
	pass
