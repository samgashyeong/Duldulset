# 202126868 Minseo Choi
extends Control
class_name TypingReportMinigame

@export var should_shuffle_fill_order: bool = true

const SENTENCE_COUNT_PER_GAME: int = 2

@export var sentences_set: Array[String] = [
	"I'm writing a report for money.",
	"Just writing to look busy.",
	"Filling it with useless word.",
	"Copying old reports, pretending new.",
	"qwertyasdfgzxcvb",
	"1q2w3e4r5t6y7u8i9o0p"
]

@onready var input_line_edit: LineEdit           = $LineEdit
@onready var word_grid_container: GridContainer  = $WordPanel/SentenceContainer
@onready var typing_sound: AudioStreamPlayer     = $Sounds/TypingSound
@onready var error_sound: AudioStreamPlayer      = $Sounds/ErrorSound
@onready var success_sound: AudioStreamPlayer    = $Sounds/SuccessSound
@onready var success_panel: Panel                = $SuccessWindow

signal minigame_finished(success: bool)

var word_labels: Array[Label] = []       # All label blocks used to display target texts
var remaining_label_count: int = 0       # How many labels are still “alive” (not typed yet)


func _ready() -> void:
	# Collect all Label nodes under the grid
	word_labels.clear()
	for child in word_grid_container.get_children():
		if child is Label:
			word_labels.append(child)

	# Source word list (all candidate sentences)
	var source_words: Array[String] = _get_words_from_sentence_set()

	# Decide how many targets to use this game
	var target_label_count: int = min(
		word_labels.size(),
		source_words.size(),
		SENTENCE_COUNT_PER_GAME
	)

	# Pick texts for those labels
	var picked_words: Array[String] = _pick_words_for_labels(source_words, target_label_count)

	# Assign texts to first N labels, hide the rest
	for i in range(word_labels.size()):
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


# Handle submit button
func _on_submit_pressed() -> void:
	_check_user_input(input_line_edit.text)


# Compare user input with remaining labels and update game state (STRICT: exact match only)
func _check_user_input(user_input: String) -> void:
	# Strict mode: do not normalize; empty string is ignored
	if user_input == "":
		return

	var matched_index: int = _find_match_index(user_input)

	if matched_index >= 0:
		# Correct answer
		word_labels[matched_index].visible = false

		SoundManager.play_Waterclean_sound()

		remaining_label_count -= 1
		input_line_edit.clear()

		if remaining_label_count <= 0:
			success_panel.visible = true
			if success_sound:
				success_sound.play()
			else:
				_finish_minigame(true)
	else:
		_on_wrong_answer()
		input_line_edit.clear()
		input_line_edit.select_all()


# Called when the user types a wrong answer
func _on_wrong_answer() -> void:
	error_sound.play(0.5)
	pass


# Find the index of a label that matches the raw input exactly (STRICT: case/space/symbol sensitive)
func _find_match_index(user_input: String) -> int:
	for i in range(word_labels.size()):
		var label: Label = word_labels[i]
		if not label.visible:
			continue

		# Strict comparison: must be identical to label.text
		if user_input == label.text:
			return i

	return -1


# Return a duplicated word list
func _get_words_from_sentence_set() -> Array[String]:
	return sentences_set.duplicate()


# Pick required number of words from the pool
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


# Play typing sound when the player types the string
func _on_line_edit_text_changed(new_text: String) -> void:
	typing_sound.play(0.05)


# If success sound finished, minigame will be also finished with true(success)
func _on_success_sound_finished() -> void:
	_finish_minigame(true)
