class_name Grenade extends Node3D

@export var damage: int = 30
@export var explosion_radius: int = 3

@onready var collision_shape_3d = $Area3D/CollisionShape3D
@onready var area_3d = $Area3D


func _ready():
	collision_shape_3d.shape.radius = explosion_radius


func throw():
	print("Grenade: Thrown")


func _on_timer_timeout():
	for body in area_3d.get_overlapping_bodies():
		if body.has_method("hit"):
			body.hit(damage)
	
	print("Grenade goes boom")
	queue_free()
