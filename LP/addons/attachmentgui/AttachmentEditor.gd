@tool
extends EditorPlugin
class_name AttachmentEditor

var dock
var editor : EditorInterface
var entities_folder : String = "res://entities/"
var components_folder : String = "res://components/"
var dock_gui


func _enter_tree() -> void:
	editor = get_editor_interface()
	dock = preload("res://addons/attachmentgui/Scenes/AttachmentGUIDock.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_UL, dock)
	dock.attachment_editor = self
	if not dock:
		push_error("Failed to load AttachmentGUI dock!")


func _exit_tree() -> void:
	remove_control_from_docks(dock)
	dock.free()


## Editor Interactions
func edit_scene(object : PackedScene, path : String):
	if path == "" or not object:
		push_error("Invalid scene path or object!")
		return
	editor.open_scene_from_path(path)
	editor.get_editor_viewport_2d()


func get_open_scene() -> Node:
	return editor.get_edited_scene_root()


func load_resources_from_folder(receiver : AttachmentGui, target : String, folder_path : String = entities_folder):
	var dir = DirAccess.open(folder_path)
	dock_gui = receiver
	if receiver == null or dock_gui == null or not dir:
		push_error("Dock/Receiver/FolderPath is null - AttachmentEditor")
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	var files_found = 0

	# Loop through the directory entries
	while file_name != "":
		if file_name == "." or file_name == "..":
			print("avoiding special folder: " + file_name )
			continue
		var file_path = folder_path + "/"+ file_name
		
		if dir.current_is_dir():
			# Recursive call for directories
			var secondary_dir = DirAccess.open(file_path)
			if secondary_dir and secondary_dir.get_files().size() > 0:
				receiver.add_grid_label(file_name + ":")  # Add the folder name as a label
			load_resources_from_folder(dock_gui, target, file_path)  # Pass target as well for consistency
		else:
			# If it's a file, check if it's a target resource
			if file_name.ends_with(target):
				receiver.add_resource_item(file_path, file_name)
				files_found += 1

		file_name = dir.get_next()
	dir.list_dir_end()
	print("Found " + str(files_found) + " files in " + folder_path)
	if files_found < 1 and folder_path != entities_folder:
		receiver.add_grid_label("-Empty-", false)