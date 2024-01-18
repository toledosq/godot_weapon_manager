extends Node

var player: Player


func _ready():
	EventBus.set_active_player.connect(_set_active_player)


func use_slot_data(slot_data: SlotData) -> void:
	slot_data.item_data.use(player)


func get_global_position() -> Vector3:
	return player.global_position


func _set_active_player(active_player):
	player = active_player
	print("PlayerManager: Active player set to %s" % player)


func get_ammo_type() -> String:
	return player.WEAPON_MANAGER._on_get_ammo_type()


func refill_ammo_reserve() -> void:
	player.WEAPON_MANAGER._on_refill_ammo_reserve()
