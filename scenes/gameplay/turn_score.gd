extends PanelContainer

@onready var score_label = $MarginContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	ScoreHandler.current_combo_changed.connect(_update_score)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _update_score(yahtzee_combo:ScoreHandler.YahtzeeCombo):
	ScoreHandler.current_score = yahtzee_combo.base_score * yahtzee_combo.multiplier
	score_label.text = "%s" % [yahtzee_combo.combo_name]
	
func _on_end_turn_button_pressed():
	#score_label.text = "Nothing"
	pass
