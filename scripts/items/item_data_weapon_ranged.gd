class_name ItemDataWeaponRanged extends ItemDataWeapon

@export var current_ammo: int
@export var max_ammo: int
@export var projectile: PackedScene
@export var rate_of_fire: int = 100

@export_category("Attachments")
@export var scope: ItemDataAttachmentScope
@export var underbarrel: ItemDataAttachmentUnderBarrel


func fire():
	print("%s: Fire" % [name])
	current_ammo -= 1
	print("%s: Remaining ammo - %s" % [name, current_ammo])


func reload(amount):
	current_ammo += amount


func add_attachment(attachment: ItemDataAttachment):
	# Will return attachment if incompatible
	# Will return prev attachment if swapped
	# Will return null if added
	
	var prev_attachment = attachment
	
	match attachment.attachment_type:
		1:
			prev_attachment = scope
			scope = attachment
			print("WeaponResource: Added scope")
		2:
			prev_attachment = underbarrel
			underbarrel = attachment
			print("WeaponResource: Added underbarrel")
	
	return prev_attachment


func remove_attachment(attachment_type: int):
	var prev_attachment: ItemDataAttachment
	
	match attachment_type:
		1:
			prev_attachment = scope
			scope = null
		2:
			prev_attachment = underbarrel
			underbarrel = null
	
	# Give attachment to caller
	return prev_attachment
