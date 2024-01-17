class_name AmmoReserve extends Resource


# name, current amount, max amount
@export var ammo_reserve: Dictionary = {
	"pistol": Vector2(30, 120),
	"shotgun": Vector2(30, 80),
	"rifle": Vector2(30, 240)
}


func send_event():
	EventBus.reserve_ammo_changed.emit(ammo_reserve)


func add_ammo_to_reserve(type: String, amount: int):
	var amount_to_add = min(ammo_reserve[type][1] - ammo_reserve[type][0], amount)
	var amount_to_return = amount - amount_to_add
	ammo_reserve[type][0] += amount_to_add
	send_event()
	return amount_to_return


func take_ammo_from_reserve(type: String, amount: int):
	var amount_to_return = min(ammo_reserve[type][1] - ammo_reserve[type][0], ammo_reserve[type][0], amount)
	ammo_reserve[type][0] -= amount_to_return
	send_event()
	return amount_to_return


func set_ammo_reserve(type: String, amount: int):
	ammo_reserve[type][0] = amount
	send_event()


func fill_ammo_reserve(type: String):
	ammo_reserve[type][0] = ammo_reserve[type][1]
	send_event()


func fill_all_ammo_reserve():
	for type in ammo_reserve:
		fill_ammo_reserve(type)
	send_event()


func get_ammo_amount(type: String):
	return ammo_reserve[type]
