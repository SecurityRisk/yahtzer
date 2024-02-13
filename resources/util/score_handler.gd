extends Node

# Inner class to hold the yahtzee combos (for static typing)
class YahtzeeCombo:
	var combo_name:String
	var base_score:int
	var multiplier:int
	var total_dots:int
	var total_scoring_dots:int
	var base_adder:int = 0
	var multiplier_adder:int = 0
	
	func set_dots(dots:int, scoring_dots:int) -> YahtzeeCombo:
		total_dots = dots
		total_scoring_dots = scoring_dots
		return self
	
	func _init(starting_name:String = "", starting_base_score:int = 0, starting_base_multiplier:int = 0):
		combo_name = starting_name
		base_score = starting_base_score
		multiplier = starting_base_multiplier
	
	func reset_base():
		base_adder = 0
		multiplier_adder = 0

enum { NOTHING, CHANCE, PAIR, TWO_PAIR, THREE_OF_A_KIND, FOUR_OF_A_KIND, FULL_HOUSE, SMALL_STRAIGHT, LARGE_STRAIGHT, YAHTZEE }

signal current_combo_changed(new_combo:YahtzeeCombo)
var current_combo:YahtzeeCombo: 
	get:
		return current_combo
	set(value):
		current_combo_changed.emit(value)
		current_combo = value

var current_score := 0
var yahtzee_combinations = {
	NOTHING: YahtzeeCombo.new("Nothing", 0, 0),
	CHANCE: YahtzeeCombo.new("Chance", 10, 1),
	PAIR: YahtzeeCombo.new("Pair", 10, 2),
	TWO_PAIR: YahtzeeCombo.new("Two Pair", 20, 2),
	THREE_OF_A_KIND: YahtzeeCombo.new("Three of a Kind", 30, 3),
	FOUR_OF_A_KIND: YahtzeeCombo.new("Four of a Kind", 40, 3),
	FULL_HOUSE: YahtzeeCombo.new("Full House", 50, 4),
	SMALL_STRAIGHT: YahtzeeCombo.new("Small Straight", 60, 5),
	LARGE_STRAIGHT: YahtzeeCombo.new("Large Straight", 70, 6),
	YAHTZEE: YahtzeeCombo.new("Yahtzee", 100, 8)
}

func reset_score():
	current_combo.reset_base()
	current_combo = yahtzee_combinations.get(NOTHING)
	current_score = 0

func update_yahtzee_combo(dice_array:Array[Die]) -> YahtzeeCombo:
	current_combo = calculate_highest_score(dice_array)
	return current_combo

func calculate_highest_score(dice_array:Array[Die]) -> YahtzeeCombo:
	var counts := {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0}
	var total_dots = 0
	# Count the occurrences of each die value
	for die in dice_array:
		counts[die.num_dots] += 1
		total_dots += die.num_dots

	# Check for Yahtzee (5 of a kind)
	if 5 in counts.values():
		return (yahtzee_combinations.get(YAHTZEE) as YahtzeeCombo).set_dots(total_dots, total_dots)  # Yahtzee score

	# Check for Large Straight
	if counts.values().slice(1, 6) == [1, 1, 1, 1, 1] or counts.values().slice(0, 5) == [1, 1, 1, 1, 1]:
		var scoring_set:Array = counts.values().slice(0, 5)
		if counts.values().slice(1, 6) == [1, 1, 1, 1, 1]:
			scoring_set = counts.values().slice(1, 6)
			
		var scoring_dots = 0
		var i = 1
		for c in scoring_set:
			scoring_dots += c * i
			i += 1
			
		return (yahtzee_combinations.get(LARGE_STRAIGHT) as YahtzeeCombo).set_dots(total_dots, scoring_dots) # Large Straight score

	# Check for Small Straight
	# Possible small straight sequences
	var sequences = [[1, 2, 3, 4], [2, 3, 4, 5], [3, 4, 5, 6]]
	var sequence_dots = 0
	for sequence in sequences:
		var straight = true
		var temp_sequence_dots = 0
		for number in sequence:
			temp_sequence_dots += number
			if counts[number] < 1:
				straight = false
				break
		if straight:
			sequence_dots = maxi(sequence_dots, temp_sequence_dots)
	if (sequence_dots > 0):
		return (yahtzee_combinations.get(SMALL_STRAIGHT) as YahtzeeCombo).set_dots(total_dots, sequence_dots)  # Small Straight score
			
	# Check for Four of a Kind
	if 4 in counts.values():
		return (yahtzee_combinations.get(FOUR_OF_A_KIND) as YahtzeeCombo).set_dots(total_dots, counts.values().find(4) * 4)

	# Check for Full House (3 of a kind and a pair)
	if 3 in counts.values() and 2 in counts.values():
		return (yahtzee_combinations.get(FULL_HOUSE) as YahtzeeCombo).set_dots(total_dots, total_dots)  # Full House score

	# Check for Three of a Kind
	if 3 in counts.values():
		return (yahtzee_combinations.get(THREE_OF_A_KIND) as YahtzeeCombo).set_dots(total_dots, counts.values().find(3) * 3)

	if 2 in counts.values():
		var pairs = 0
		var first_pair_dots = 0
		for dots in counts.values():
			if (dots >= 2):
				pairs += 1
				if (pairs == 2):
					return (yahtzee_combinations.get(TWO_PAIR) as YahtzeeCombo).set_dots(total_dots, first_pair_dots + counts.values().find(dots) * 2)
				else:
					first_pair_dots = counts.values().find(dots) * 2
		return yahtzee_combinations.get(PAIR)
	
	# Chance (sum of all dice)
	# Idk if I want to change this to just the high die or keep it at total
	return (yahtzee_combinations.get(CHANCE) as YahtzeeCombo).set_dots(total_dots, total_dots)
