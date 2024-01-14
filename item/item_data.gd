class_name ItemData extends Resource

@export var name: String = ""
@export_multiline var description: String = ""
@export var stackable: bool = false
# Using Atlas cause all item textures are on an atlas in this practice project
# Otherwise, use Texture type for individual texture files
@export var texture: AtlasTexture


# Placeholder function - children will define behavior
func use(target) -> void:
	pass
