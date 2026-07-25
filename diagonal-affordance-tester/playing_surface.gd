extends Node2D

enum directions {
	r,
	ur,
	u,
	ul,
	l,
	dl,
	d,
	dr
}

var data: Dictionary = {
	directions.r: {
		"vector": Vector2(1, 0)
	},
	directions.ur: {
		"vector": Vector2(1, -1)
	},
	directions.u: {
		"vector": Vector2(0, -1)
	},
	directions.ul: {
		"vector": Vector2(-1, -1)
	},
	directions.l: {
		"vector": Vector2(-1, 0)
	},
	directions.dl: {
		"vector": Vector2(-1, 1)
	},
	directions.d: {
		"vector": Vector2(0, -1)
	},
	directions.dr: {
		"vector": Vector2(1, -1)
	},
}

func _ready() -> void:
	for entry in data:
		data[entry].angle_degrees = rad_to_deg(data[entry].vector.angle())
	print(data);

func _physics_process(_delta) -> void:
	var raw_left_stick_vector: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down");
	# print(raw_left_stick_vector, " ", rad_to_deg(raw_left_stick_vector.angle()));
	# if absf(raw_left_stick_vector[0]) > 0.383: # sin 22.5 degrees
