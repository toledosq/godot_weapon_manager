class_name ContextMenu extends PanelContainer

signal item_clicked(index)

@export var menu_items: Array[String] = ["Inspect", "Use", "Remove Attachment", "Drop"]

@onready var item_list = $ItemList


func _ready():
	for item in menu_items:
		item_list.add_item(item, null, false)


func _on_item_list_item_clicked(index, _at_position, _mouse_button_index):
	var item_text = item_list.get_item_text(index)
	print("ContextMenu: Clicked on %s" % item_text)
	item_clicked.emit(item_text)
	queue_free()
