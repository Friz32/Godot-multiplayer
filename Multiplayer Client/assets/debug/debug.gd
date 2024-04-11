extends Node

@onready var window: Window = $Window
@onready var item_list := %ItemList
@onready var tab_container := %TabContainer

func _ready():
	window.visible = false
	
	item_list.item_selected.emit(0)

func _input(event):
	if InputMap.has_action("debug_window") && event.is_action_pressed("debug_window"):
		window.visible = !window.visible
	
	if InputMap.has_action("debug_mouse_mode") && event.is_action_pressed("debug_mouse_mode"):
		var mode = Input.MOUSE_MODE_CAPTURED if \
			Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else \
			Input.MOUSE_MODE_VISIBLE
		
		Input.mouse_mode = mode
	
	if InputMap.has_action("debug_reload_scene") && event.is_action_pressed("debug_reload_scene"):
		get_tree().reload_current_scene()
	
	if InputMap.has_action("debug_first_scene") && event.is_action_pressed("debug_first_scene"):
		get_tree().change_scene_to_file(ProjectSettings["application/run/main_scene"])

func _on_fly_pressed():
	if get_tree().root.has_node("System"):
		get_tree().root.get_node("System").call("debug_fly")

func _on_window_close_requested():
	window.hide()

func _on_item_list_item_selected(index):
	var selected = item_list.get_item_text(index)
	var node = tab_container.get_node_or_null(selected)
	if node != null:
		tab_container.current_tab = node.get_index()
