extends PanelContainer

@onready var score_label = $Label

# Called when the node enters the scene tree for the first time.
func _ready():
	ScoreHandler.current_combo_changed.connect(_update_score)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _update_score(yahtzee_combo:ScoreHandler.YahtzeeCombo):
	ScoreHandler.current_score = yahtzee_combo.base_score * yahtzee_combo.multiplier
	score_label.text = "%s" % [yahtzee_combo.combo_name]

func _on_hand_dice_selection_updated(selection:Array[Die]):
	if (selection.is_empty()):
		score_label.text = "Nothing"
	else:
		var score = ScoreHandler.current_combo as ScoreHandler.YahtzeeCombo
		ScoreHandler.current_score = score.base_score * score.multiplier
		score_label.text = "%s\n%d x %d" % [score.combo_name, score.base_score, score.multiplier]


func _on_end_turn_button_pressed():
	score_label.text = "Nothing"
