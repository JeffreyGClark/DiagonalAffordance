extends Node2D

# nodes
@onready var _Direction: Sprite2D = $"./Direction";
@onready var _Node2D: Node2D = $"./Node2D";
@onready var _Count: Label = $"./Control/Count";
@onready var _Total: Label = $"./Control/Total";

# textures
const RArrow: Texture2D = preload("res://RightArrow.png");
const URArrow: Texture2D = preload("res://URightArrow.png");

var allow_input: bool = true;
var finished: bool = false;

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

var current_direction = directions.r;

var sample_deck: Array[directions] = [
	directions.r, directions.dl, directions.u
]

var position_in_deck = -sample_deck.size() - 1; # will have 1 added to it before displaying;

var deck: Array[directions] = [];

var data: Dictionary = {
	directions.r: {
		"direction": "r",
		"vector": Vector2(1, 0)
	},
	directions.ur: {
		"direction": "ur",
		"vector": Vector2(1, -1)
	},
	directions.u: {
		"direction": "u",
		"vector": Vector2(0, -1)
	},
	directions.ul: {
		"direction": "ul",
		"vector": Vector2(-1, -1)
	},
	directions.l: {
		"direction": "l",
		"vector": Vector2(-1, 0)
	},
	directions.dl: {
		"direction": "dl",
		"vector": Vector2(-1, 1)
	},
	directions.d: {
		"direction": "d",
		"vector": Vector2(0, 1)
	},
	directions.dr: {
		"direction": "dr",
		"vector": Vector2(1, 1)
	},
}

var composite_data: Dictionary = {
	"orthogonal": {},
	"diagonal": {},
	"all": {}
}

var card_repeats: int = 8;
var count: int = -1;
func _ready() -> void:
	for direction in directions.values():
		for i in card_repeats:
			deck.push_back(direction);
	deck.shuffle();
	for key in data:
		data[key]["angle_degrees"] = rad_to_deg(data[key].vector.angle());
		var vec = data[key].vector;
		if is_zero_approx(vec.x) or is_zero_approx(vec.y):
			data[key]["orthogonal"] = true;
		else:
			data[key]["orthogonal"] = false;
	clear_data_samples();

	update_deck_display();

	_Count.text = str(count);
	_Total.text = "/" + str(card_repeats * directions.size() + 3)

func _physics_process(_delta) -> void:
	
	if allow_input and Input.is_action_just_pressed("record"):
		var raw_left_stick_vector: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down");
		var error_angle: float = rad_to_deg(raw_left_stick_vector.angle_to(data[current_direction].vector));

		input_received_visual();

		save_value(error_angle);

		update_deck_display();

	else:
		var raw_left_stick_vector: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down");
		var error_angle: float = rad_to_deg(raw_left_stick_vector.angle_to(data[current_direction].vector));
		# print(error_angle);


func clear_data_samples() -> void:
	for key in data:
		data[key]["samples"] = [];
		# data[key]["latency"] = [];
		data[key]["mu"] = 0.0;
		data[key]["sd"] = 0.0;
		data[key]["extreme"] = 0.0;
		data[key]["row"] = "";
	for key in composite_data:
		composite_data[key]["samples"] = [];
		# composite_data[key]["latency"] = [];
		composite_data[key]["mu"] = 0.0;
		composite_data[key]["sd"] = 0.0;
		composite_data[key]["extreme"] = 0.0;
		composite_data[key]["row"] = 0.0;
	# print(JSON.stringify(data, "\t"));
	# print(JSON.stringify(composite_data, "\t"));

func input_received_visual():
	_Direction.visible = false;
	_Direction.modulate = Color.BLACK;
	_Node2D.visible = false;
	_Node2D.modulate = Color.BLACK;
	allow_input = false;
	
	await get_tree().create_timer(0.2).timeout;

	if finished:
		return;

	allow_input = true;
	_Direction.visible = true;
	_Node2D.visible = true;

	get_tree().create_tween().tween_property(
		_Direction,
		"modulate",
		Color.WHITE,
		0.2
	);
	get_tree().create_tween().tween_property(
		_Node2D,
		"modulate",
		Color.WHITE,
		0.2
	);


func update_deck_display():
	# save data
	position_in_deck += 1;
	count += 1;
	_Count.text = str(count);
	if position_in_deck < 0:
		current_direction = sample_deck[position_in_deck + sample_deck.size()];
	else:
		if position_in_deck < deck.size():
			current_direction = deck[position_in_deck];
		else:
			finish();
  
	if (current_direction % 2 == 0):
		_Direction.texture = RArrow;
		_Direction.rotation_degrees = data[current_direction].angle_degrees;
	else:
		_Direction.texture = URArrow;
		_Direction.rotation_degrees = data[current_direction].angle_degrees + 45.0;

func save_value(error: float) -> void:
	print("%3d" % (current_direction * 45), ": ", error);
	if position_in_deck >= 0 and position_in_deck < deck.size():
		data[current_direction]["samples"].push_back(error);

func finish() -> void:
	finished = true;
	allow_input = false;
	var orthogonal_samples = [];
	var diagonal_samples = [];
	var all_samples = [];
	for direction in directions.values():
		var direction_angle: String = "%3d" % (direction * 45);
		var output_row: String = "(" + direction_angle + ")";
		var samples_string: String = "[ ";
		var max_error: float = 0.0;
		var samples: Array = data[direction]["samples"];
		var mean: float = find_mean(samples);
		var std: float = find_std(samples, mean);
		for sample in samples:
			if direction % 2 == 0:
				orthogonal_samples.push_back(sample);
			else:
				diagonal_samples.push_back(sample);
			all_samples.push_back(sample);

			samples_string += "%.1f" % sample + ", ";
			if abs(sample) > max_error:
				max_error = abs(sample);

		output_row += " " + char(0x00B5) + ": " + ("%5.1f" % mean);
		output_row += " sd: " + ("%5.1f" % std);
		output_row += " max: " + ("%5.1f" % max_error);
		output_row += " " + samples_string.left(-2) + "]"
		print(output_row);
		print("  ", find_over_225(samples));

	var diag_mean: float = find_mean(diagonal_samples);
	var diag_std: float = find_std(diagonal_samples, diag_mean);
	var diag_max: float = find_max(diagonal_samples);
	var diag_row: String = "(diag) " + \
		char(0x00B5) + ": " + ("%5.1f" % diag_mean) + \
		" sd: " + ("%5.1f" % diag_std) + \
		" max: " + ("%5.1f" % diag_max);
	print(diag_row);
	print("  ", find_over_225(diagonal_samples));

	var orth_mean: float = find_mean(orthogonal_samples);
	var orth_std: float = find_std(orthogonal_samples, orth_mean);
	var orth_max: float = find_max(orthogonal_samples);
	var orth_row: String = "(orth) " + \
		char(0x00B5) + ": " + ("%5.1f" % orth_mean) + \
		" sd: " + ("%5.1f" % orth_std) + \
		" max: " + ("%5.1f" % orth_max);
	print(orth_row);
	print("  ", find_over_225(orthogonal_samples));

	var all_mean: float = find_mean(all_samples);
	var all_std: float = find_std(all_samples, all_mean);
	var all_max: float = find_max(all_samples);
	var all_row: String = "( all) " + \
		char(0x00B5) + ": " + ("%5.1f" % all_mean) + \
		" sd: " + ("%5.1f" % all_std) + \
		" max: " + ("%5.1f" % all_max);
	print(all_row);
	print("  ", find_over_225(all_samples));

	# print(JSON.stringify(data, "\t"));
	# print(JSON.stringify(composite_data, "\t"));

func find_max(array: Array) -> float:
	var max_error: float = 0.0;
	for num in array:
		if abs(num) > max_error:
			max_error = abs(num);
	return max_error;

func find_mean(array: Array) -> float:
	var sum: float = 0.0;
	for num in array:
		sum += num;
	
	return sum / array.size();

func find_std(array: Array, mean: float = 0.0) -> float:
	if is_zero_approx(mean):
		mean = find_mean(array);

	var sum_squares: float = 0.0;
	var diff: float = 0;
	for num in array:
		diff = num - mean;
		sum_squares += diff * diff;

	return sqrt(sum_squares / (array.size() - 1));

func find_over_225(array: Array) -> Array:
	var _count: int = 0;
	for num in array:
		if abs(num) > 22.5:
			_count += 1;
	
	return [_count, float(_count) / float(array.size())];
