extends RigidBody3D

# Export slot for item assignment
@export var slot_data: SlotData

# World Sprite
@onready var sprite_3d = $Sprite3D


func _ready() -> void:
	# Assign the slotted item's texture to the world sprite
	sprite_3d.texture = slot_data.item_data.texture


func _physics_process(delta) -> void:
	# Rotate the sprite around cause it fancy
	sprite_3d.rotate_y(delta)


func _on_area_3d_body_entered(body) -> void:
	# Attempt to pick up slot data (returns bool)
	if body.inventory_data.pick_up_slot_data(slot_data):
		# If successful, just delete pickup
		queue_free()
