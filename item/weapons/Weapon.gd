class_name Weapon extends Node3D


@onready var animation_player = $AnimationPlayer



func fire():
	print("WeaponModel: Firing")
	animation_player.play("fire")


func unequip():
	print("%s: Unequipping" % name)
	animation_player.play("unequip")
	await animation_player.animation_finished
	return true


func equip():
	print("%s: Equipping" % name)
	animation_player.play("equip")
	await animation_player.animation_finished
	return true
