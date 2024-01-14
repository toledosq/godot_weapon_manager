class_name ItemDataWeapon extends ItemData

enum WEAPON_TYPES { NONE, SHOTGUN, RIFLE, PISTOL, MELEE }

@export var damage: float
@export var weapon_type: WEAPON_TYPES
@export var first_person_model: PackedScene

