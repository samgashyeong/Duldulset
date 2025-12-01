# 202126868 Minseo Choi
extends Control
class_name TypingReportMinigame

@export var should_shuffle_fill_order: bool = true
@export var is_case_insensitive: bool = true
@export var should_trim_spaces: bool = true
@export var should_normalize_hyphen: bool = true

const SENTENCE_COUNT_PER_GAME: int = 3

# Level 1: report-style sentences (we will use only 3 per game)
@export var sentences_set_level_1: Array[String] = [
	"I'm writing a report for money.",
	"Just writing to look busy.",
	"Filling it with useless word.",
	"Copying old reports, pretending new.",
	"qwertyasdfgzxcvb",
	"1q2w3e4r5t6y7u8i9o0p"
]

@onready var input_line_edit: LineEdit            = $LineEdit
@onready var word_grid_container: GridContainer  = $WordPanel/SentenceContainer

signal minigame_finished(success: bool)

var word_labels: Array[Label] = []       # All label blocks used to display target texts
var remaining_label_count: int = 0       # How many labels are still “alive” (not typed yet)


func _ready() -> void:
	# Validate required nodes
	if word_grid_container == null:
		push_error("TypingReport: $WordPanel/GridContainer 경로를 확인하세요.")
		print_tree()
		return

	if input_line_edit == null:
		push_error("TypingReport: $LineEdit 경로를 확인하세요.")
		print_tree()
		return

	# Collect all Label nodes under the grid
	word_labels.clear()
	for child in word_grid_container.get_children():
		if child is Label:
			word_labels.append(child)

	if word_labels.is_empty():
		push_error("TypingReport: GridContainer 안에 Label 블록이 없습니다.")
		return

	# Source word list (all candidate sentences)
	var source_words: Array[String] = _get_words_from_sentence_set()

	# Decide how many targets to use this game:
	#  - up to SENTENCE_COUNT_PER_GAME sentences
	#  - cannot exceed number of labels or number of available sentences
	var target_label_count: int = min(
		word_labels.size(),
		source_words.size(),
		SENTENCE_COUNT_PER_GAME
	)

	# Pick texts for those labels
	var picked_words: Array[String] = _pick_words_for_labels(source_words, target_label_count)

	# Assign texts to first N labels, hide the rest
	for i in word_labels.size():
		if i < target_label_count:
			word_labels[i].text = picked_words[i]
			word_labels[i].visible = true
		else:
			word_labels[i].visible = false

	remaining_label_count = target_label_count

	# Connect LineEdit submit signal once
	if not input_line_edit.text_submitted.is_connected(_on_line_edit_submitted):
		input_line_edit.text_submitted.connect(_on_line_edit_submitted)

	input_line_edit.clear()
	input_line_edit.grab_focus()


# Handle Enter key from LineEdit
func _on_line_edit_submitted(text: String) -> void:
	_check_user_input(text)


# Handle submit button (if connected from the scene)
func _on_submit_pressed() -> void:
	_check_user_input(input_line_edit.text)


# Compare user input with remaining labels and update game state
func _check_user_input(user_input: String) -> void:
	var typed_normalized: String = _normalize_input(user_input)
	if typed_normalized == "":
		return

	var matched_index: int = _find_match_index(typed_normalized)

	if matched_index >= 0:
		# Correct answer
		word_labels[matched_index].visible = false
		remaining_label_count -= 1
		input_line_edit.clear()

		if remaining_label_count <= 0:
			_finish_minigame(true)
	else:
		# Wrong answer
		_on_wrong_answer()
		input_line_edit.clear()
		input_line_edit.select_all()


# Called when the user types a wrong answer (extend for feedback effects)
func _on_wrong_answer() -> void:
	pass


# Find the index of a label that matches the normalized input
func _find_match_index(typed_normalized: String) -> int:
	for i in word_labels.size():
		var label: Label = word_labels[i]
		if not label.visible:
			continue

		var target_normalized: String = _normalize_input(label.text)
		if typed_normalized == target_normalized:
			return i

	return -1


# Normalize user input and label text according to the options
func _normalize_input(text: String) -> String:
	var result: String = text

	if should_trim_spaces:
		result = result.strip_edges()
		var regex := RegEx.new()
		regex.compile("\\s+")
		result = regex.sub(result, " ", true)  # collapse multiple spaces into one

	if should_normalize_hyphen:
		result = result.replace("–", "-").replace("—", "-")

	if is_case_insensitive:
		result = result.to_lower()

	return result


# Return a duplicated word list (current game uses only this set)
func _get_words_from_sentence_set() -> Array[String]:
	return sentences_set_level_1.duplicate()


# Pick 'need' number of words from the pool (optionally shuffled)
func _pick_words_for_labels(pool: Array[String], need: int) -> Array[String]:
	var out: Array[String] = pool.duplicate()

	if should_shuffle_fill_order:
		out.shuffle()

	if out.size() < need:
		var i: int = 0
		while out.size() < need and pool.size() > 0:
			out.append(pool[i % pool.size()])
			i += 1
	elif out.size() > need:
		out.resize(need)

	return out


# Stop editing and notify MiniGameManager that the minigame ended
func _finish_minigame(success: bool) -> void:
	input_line_edit.editable = false
	minigame_finished.emit(success)
