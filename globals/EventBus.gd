extends Node

signal weapon_equipped(index)
signal weapon_unequipped(index)

func _ready():
	weapon_equipped.connect(print_something)
	weapon_unequipped.connect(print_something)


func print_something(something):
	print(something)
