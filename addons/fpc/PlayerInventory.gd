class_name Inventory extends Node

@export var equipped_weapons = [] # Array of equipped weapons
@export var default_weapon_resource: WeaponResource # Weapon to be equipped if all weapon slots empty
const MAX_WEAPONS = 3
var current_weapon: WeaponResource
var current_ammo: int = 5


func _ready():
	if len(equipped_weapons) == 0:
		equip_weapon(default_weapon_resource)


func equip_weapon(weapon_resource):
	print("equip", weapon_resource.name)
	current_weapon = weapon_resource


func fire_weapon():
	if current_weapon and current_weapon.has_method("fire"):
		current_weapon.fire()


func reload_weapon():
	if current_weapon and current_weapon.has_method("reload"):
		current_weapon.reload(current_ammo)
