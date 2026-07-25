extends Node2D


func _physics_process(_delta):
	var raw_left_stick_vector: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down");
	print(raw_left_stick_vector);
	# if absf(raw_left_stick_vector[0]) > 0.383: # sin 22.5 degrees
