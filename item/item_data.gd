class_name ItemData extends Resource

@export_group("Item Details")
@export var itemID: int
@export var name: String = ""
@export var value: int
@export_multiline var description: String = ""
@export var stackable: bool = false

@export_group("Item Rendering")
@export var texture: AtlasTexture
@export var mesh: ArrayMesh
@export var mesh_scale_modifier: float = 1.0

# Placeholder function - children will define behavior
func use(target) -> void:
	print(self, ": Used")
