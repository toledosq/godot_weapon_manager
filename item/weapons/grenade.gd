class_name Grenade extends RigidBody3D

@export var damage: int = 30
@export var explosion_radius: int = 3
@export var default_position : Vector3
@export var default_rotation : Vector3

@onready var collision_shape_3d: CollisionShape3D = $BlastArea/CollisionShape3D
@onready var blast_area: Area3D = $BlastArea
@onready var smoke_particles = $SmokeParticles
@onready var mesh_instance_3d = $MeshInstance3D



func _ready():
	collision_shape_3d.shape.radius = explosion_radius


func throw(direction):
	print("Grenade: Throwing ", direction)
	apply_impulse(direction * 16)


func _on_timer_timeout():
	for body in blast_area.get_overlapping_bodies():
		if body.has_method("hit"):
			body.hit(damage)
	
	print("Grenade goes boom")
	mesh_instance_3d.hide()
	smoke_particles.show()
	smoke_particles.emitting = true


func _on_smoke_particles_finished():
	print("Grenade: going away")
	queue_free()
