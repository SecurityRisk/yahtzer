class_name Hand
extends HBoxContainer

@onready var dice:Array[Die]
var hand_size = 5

@onready var DieScene = preload("res://scenes/gameplay/die.tscn")

signal dice_selection_updated(selection:Array[Die])
signal end_turn_with_selected_dice(selection:Array[Die])
# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is Die:
			child.die_selected.connect(_on_dice_selection_change)
			child.die_deselected.connect(_on_dice_selection_change)
			child.hand = self
			dice.append(child)
	sort_dice()

func sort_dice():
	dice.sort_custom(sort_dice_by_dot)
	var i = 0
	for die in dice:
		move_child(die, i)
		i += 1

func _on_dice_selection_change(_die:Die):
	ScoreHandler.update_yahtzee_combo(get_selected_dice())
	dice_selection_updated.emit(get_selected_dice())

func number_of_selected_dice() -> int:
	return get_selected_dice().size()

func get_selected_dice() -> Array[Die]:
	return dice.filter(func(a:Die): return a.selected)

func sort_dice_by_dot(a:Die, b:Die):
	return a.num_dots > b.num_dots

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_reroll_button_pressed():
	for die in get_selected_dice():
		die.change_dots(randi() % 6 + 1)
		die.selected = false
	sort_dice()


func _on_end_turn_button_pressed():
	var selected_dice = get_selected_dice()
	for die in get_selected_dice():
		dice.erase(die)
	end_turn_with_selected_dice.emit(selected_dice)
	#_on_reroll_button_pressed()


func _on_play_container_attack_finished():
	var diff = hand_size - dice.size()
	for num in diff:
		var die = DieScene.instantiate()
		die.die_selected.connect(_on_dice_selection_change)
		die.die_deselected.connect(_on_dice_selection_change)
		die.hand = self
		add_child(die)
		dice.append(die)
	sort_dice()
