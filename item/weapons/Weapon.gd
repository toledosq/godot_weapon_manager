class_name Weapon extends Node3D


func fire():
	print("WeaponModel: Firing")


func unequip():
	print("%s: Unequipping" % name)
	queue_free()
