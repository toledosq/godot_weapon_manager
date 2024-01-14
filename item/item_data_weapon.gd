class_name ItemDataWeapon extends ItemData

@export_group("Weapon Defaults")
@export var player_model: PackedScene
@export var base_damage: int = 20
@export var base_range: int = 1000
@export var single_fire: bool = true

@export_group("Transforms")
@export var default_position: Vector3
@export var default_rotation: Vector3
@export var ads_position: Vector3
@export var ads_rotation: Vector3


func fire():
	pass
