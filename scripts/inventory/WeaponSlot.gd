extends Node3D

@export var weapon_data: ItemDataWeapon

var fps_model
var weapon_equipped: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	print("WeaponSlot")
	pass
	

func _on_weapon_equipped():
	# TODO: pass
	if weapon_equipped and fps_model:
		fps_model.queue_free()
	if weapon_data.first_person_model:
		fps_model = weapon_data.first_person_model.instantiate()
		add_child(fps_model)
		weapon_equipped = true


func _on_weapon_unequipped():
	weapon_equipped = false
	if fps_model:
		fps_model.queue_free()
		fps_model = null


func fire_weapon():
	print("Pew pew")
