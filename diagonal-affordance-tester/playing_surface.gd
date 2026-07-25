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

var composite_data: Dictionary = {
	"orthogonal": {
		"mu": 0.0,
		"sd": 0.0,
		"extreme": 0.0,
	},
	"diagonal": {
		"mu": 0.0,
		"sd": 0.0,
		"extreme": 0.0,
	},
	"all": {
		"mu": 0.0,
		"sd": 0.0,
		"extreme": 0.0,
	}
}

func _ready() -> void:
	for key in data:
		data[key]["angle_degrees"] = rad_to_deg(data[key].vector.angle());
		var vec = data[key].vector;
		if is_zero_approx(vec.x) or is_zero_approx(vec.y):
			data[key]["orthogonal"] = true;
		else:
			data[key]["orthogonal"] = false;
	clear_data_samples();
	print(data);

func _physics_process(_delta) -> void:
	var raw_left_stick_vector: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down");
	# print(raw_left_stick_vector, " ", rad_to_deg(raw_left_stick_vector.angle()));
	# if absf(raw_left_stick_vector[0]) > 0.383: # sin 22.5 degrees

func clear_data_samples() -> void:
	for key in data:
		data[key]["samples"] = [];
		data[key]["mu"] = [];
		data[key]["sd"] = [];
		data[key]["extremes"] = [];
	for key in composite_data:
		print(key, " ", composite_data[key]);
