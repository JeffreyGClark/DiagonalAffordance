extends Node2D

# nodes
@onready var _Direction: Sprite2D = $"./Direction";

# textures
const RArrow: Texture2D = preload("res://RArrow.png");
const URArrow: Texture2D = preload("res://URArrow.png");

var allow_input: bool = true;

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
		"vector": Vector2(0, -1)
	},
	directions.dr: {
		"direction": "dr",
		"vector": Vector2(1, -1)
	},
}

var composite_data: Dictionary = {
	"orthogonal": {},
	"diagonal": {},
	"all": {}
}

func _ready() -> void:
	for direction in directions.values():
		for i in 6:
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

func _physics_process(_delta) -> void:
	
	if allow_input and Input.is_action_just_pressed("record"):
		var raw_left_stick_vector: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down");
		print(rad_to_deg(raw_left_stick_vector.angle_to(data[directions.r].vector)));

		update_deck_display();


func clear_data_samples() -> void:
	for key in data:
		data[key]["samples"] = [];
		data[key]["latency"] = [];
		data[key]["mu"] = 0.0;
		data[key]["sd"] = 0.0;
		data[key]["extreme"] = 0.0;
	for key in composite_data:
		composite_data[key]["samples"] = [];
		composite_data[key]["latency"] = [];
		composite_data[key]["mu"] = 0.0;
		composite_data[key]["sd"] = 0.0;
		composite_data[key]["extreme"] = 0.0;
	# print(JSON.stringify(data, "\t"));
	# print(JSON.stringify(composite_data, "\t"));

func update_deck_display():
	position_in_deck += 1;
	if position_in_deck < 0:
		current_direction = sample_deck[position_in_deck + sample_deck.size()];
	else:
		if position_in_deck < deck.size():
			current_direction = deck[position_in_deck];
		else:
			return;
  
	if (current_direction % 2 == 0):
		_Direction.texture = RArrow;
		_Direction.rotation_degrees = data[current_direction].angle_degrees;
	else:
		_Direction.texture = URArrow;
		_Direction.rotation_degrees = data[current_direction].angle_degrees + 45.0;

	
	print(position_in_deck, " ", current_direction);
	print("  ", _Direction.position);
