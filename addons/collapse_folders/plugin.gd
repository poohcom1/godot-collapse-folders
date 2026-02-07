@tool
extends EditorPlugin

var filesystem_tree: Tree
var buttons: Array[Button] = []

func _enter_tree():
	var fs_dock := EditorInterface.get_file_system_dock()
	filesystem_tree = find_filesystem_tree(fs_dock)
	if filesystem_tree == null:
		print_rich("[color=#ff786b][Godot Collapse Folder] Error: Cannot find filesystem tree. Please report this issue to [url]https://github.com/poohcom1/godot-collapse-folders/issues[/url].")
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
		if _is_file_tree(child, node):
			return child
		var ret := find_filesystem_tree(child)
		if ret:
			return ret
	return null

func _is_file_tree(child: Node, parent: Node) -> bool:
	var ver = Engine.get_version_info()
	# Unoptimized as FUCK but easier to read and only runs at start so eh
	if ver.major == 4:
		if ver.minor <= 5:
			return child is Tree and parent is SplitContainer
		else:
			return child is Tree and parent is MarginContainer and parent.get_parent() is SplitContainer
	else:
		return false

func find_button_container(node: Node) -> Array[Container]:
	var containers: Array[Container] = []
	for child in node.get_children():
		if child is MenuButton and child.tooltip_text == tr("Sort Files"):
			containers.append(node)
		
		for container in find_button_container(child):
			containers.append(container)

	return containers
