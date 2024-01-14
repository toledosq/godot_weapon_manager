extends Node

signal weapon_equipped(weapon_slot_index)
signal weapon_unequipped(weapon_slot_index)

var player
var active_weapon_slot_index: int = 0


func _ready():
	EventBus.set_active_player.connect(_set_active_player)
	EventBus.weapon_equipped.connect(_equip_weapon)
	EventBus.weapon_unequipped.connect(_unequip_weapon)
	EventBus.set_active_weapon_slot.connect(_set_active_weapon_slot)


func use_slot_data(slot_data: SlotData) -> void:
	slot_data.item_data.use(player)


func get_global_position() -> Vector3:
	return player.global_position


func _equip_weapon(weapon_slot_index):
	print("Equipped weapon in slot %s" % weapon_slot_index)


func _unequip_weapon(weapon_slot_index):
	print("Unequipped weapon in slot %s" % weapon_slot_index)


func _set_active_weapon_slot(weapon_slot_index):
	active_weapon_slot_index = weapon_slot_index
	print("PlayerManager: Active weapon slot set to %s" % weapon_slot_index)


func _set_active_player(active_player):
	player = active_player
	print("PlayerManager: Active player set to %s" % player)
