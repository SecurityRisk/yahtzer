extends Node

func _ready():
	get_tree().root.size_changed.connect(_on_window_resize)

func _on_window_resize():
	pass
	#print(get_tree().root.content_scale_factor)
