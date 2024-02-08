@tool
extends EditorPlugin

var filesystem_tree: Tree
var buttons: Array[Button] = []

func _enter_tree():
	var fs_dock := EditorInterface.get_file_system_dock()
	filesystem_tree = find_filesystem_tree(fs_dock)
	var fs_button_containers := find_button_container(fs_dock)

	for container in fs_button_containers:
		var button = Button.new()
		button.tooltip_text = "Collapse All"
		button.flat = true
		button.icon = preload("res://addons/collapse_folders/collapse-all.svg")
		button.pressed.connect(collapse_files)
		container.add_child(button)
		container.move_child(button, container.get_child_count() - 2)
		buttons.append(button)

func _exit_tree():
	for button in buttons:
		button.queue_free()
	buttons.clear()

func collapse_files():
	if !filesystem_tree: return
	var tree_root := filesystem_tree.get_root()
	
	for i in tree_root.get_child_count():
		var item := tree_root.get_child(i)
		item.set_collapsed_recursive(true)
		
		if i == tree_root.get_child_count() - 1:
			# Uncollapse only res://
			item.collapsed = false
		
		
# Util functions
func find_filesystem_tree(node: Node) -> Tree:
	for child in node.get_children():
		if child is Tree and node is SplitContainer:
			return child
		var ret := find_filesystem_tree(child)
		if ret:
			return ret
	return null


func find_button_container(node: Node) -> Array[Container]:
	var containers: Array[Container] = []
	for child in node.get_children():
		if child is MenuButton and child.tooltip_text == tr("Sort Files"):
			containers.append(node)
		
		for container in find_button_container(child):
			containers.append(container)

	return containers
