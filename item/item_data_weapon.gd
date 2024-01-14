class_name ItemDataWeapon extends ItemData

@export_group("Weapon Defaults")
@export var player_model: PackedScene
@export var base_damage: int
@export var base_range: int

@export_group("Transforms")
@export var default_position: Vector3
@export var default_rotation: Vector3
@export var ads_position: Vector3
@export var ads_rotation: Vector3


func fire():
	pass
