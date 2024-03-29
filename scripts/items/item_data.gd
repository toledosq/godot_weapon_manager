class_name ItemData extends Resource


@export_group("Item Details")
@export var itemID: int
@export var name: String = ""
@export var value: int
@export_multiline var description: String = ""
@export var stackable: bool = false
@export var is_unique = false

@export_group("Item Rendering")
@export var texture: Texture
@export var mesh: Mesh
@export var mesh_scale_modifier: float = 1.0

# Placeholder function - children will define behavior
func use(_target) -> void:
	print(self, ": Used")
