class_name Grenade extends RigidBody3D

@export var damage: int = 30
@export var explosion_radius: int = 3

@onready var collision_shape_3d: CollisionShape3D = $BlastArea/CollisionShape3D
@onready var blast_area: Area3D = $BlastArea


func _ready():
	collision_shape_3d.shape.radius = explosion_radius


func throw(direction):
	print("Grenade: Throwing")
	apply_impulse(direction * 15)


func _on_timer_timeout():
	for body in blast_area.get_overlapping_bodies():
		if body.has_method("hit"):
			body.hit(damage)
	
	print("Grenade goes boom")
	queue_free()
