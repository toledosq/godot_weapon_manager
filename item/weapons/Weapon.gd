class_name Weapon extends Node3D


@onready var animation_player = $AnimationPlayer


func fire():
	print("WeaponModel: Firing")
	if animation_player:
		animation_player.play("fire")
		await animation_player.animation_finished

func unequip():
	print("%s: Unequipping" % name)
	if animation_player:
		animation_player.play("unequip")
		await animation_player.animation_finished


func equip():
	print("%s: Equipping" % name)
	if animation_player:
		animation_player.play("equip")
		await animation_player.animation_finished
