@tool
extends EditorPlugin
class_name attachmentgui

var dock
var editor : EditorInterface
var entities_folder : String = "res://Entities/"
var dock_gui

func _enter_tree() -> void:
	editor = get_editor_interface()
	dock = preload("res://addons/attachmentgui/Scenes/AttachmentGUIDock.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_UL, dock)
	dock.attachment_gui = self

func _init() -> void:
	self.name = "Attachment GUI"

func _exit_tree() -> void:
	remove_control_from_docks(dock)
	dock.free()

## Editor Interactions
func edit_scene(object : PackedScene, path : String):
	print("Path to new creature: " + path)
	print("New creature : " + str(object.resource_name))
	editor.open_scene_from_path(path)
	editor.get_editor_viewport_2d()
		
func get_open_scene() -> Node:
	return editor.get_edited_scene_root()

func load_resources_from_folder(attachment_gui, folder_path : String = entities_folder):
	dock_gui = attachment_gui
	if attachment_gui == null or dock_gui == null:
		print("Error")
		return
		
	var dir = DirAccess.open(folder_path)
	if not dir:
		print("Something went wrong opening folder: " + folder_path)
		return
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	# Loop through the directory entries
	while file_name != "":
		if file_name == "." or file_name == "..":
			print("avoiding special folder")
			return
		
		var file_path = folder_path + "/"+ file_name
		#If its a file, add it
		if !dir.current_is_dir():
			# Check if the file is a resource we care about (like scenes, textures, etc.)
			if file_name.ends_with(".tscn"):
				attachment_gui.add_resource_item(file_path, file_name)
				print("Found scene: " + file_path)
		else:
			load_resources_from_folder(dock_gui, file_path)
		file_name = dir.get_next()
	dir.list_dir_end()
