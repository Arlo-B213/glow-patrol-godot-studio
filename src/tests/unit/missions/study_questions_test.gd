extends GdUnitTestSuite
## Study Hall and mission questions: every generated answer is right, and every choice list is valid.

const Q := preload("res://scripts/study_questions.gd")
const SAMPLES := 60


## Evaluates an arithmetic question such as "12 × 3 = ?" with the unicode operators swapped for code ones.
func _eval(q: String) -> int:
	var expr := q.replace(" = ?", "").replace("×", "*").replace("÷", "/").replace("−", "-")
	var e := Expression.new()
	assert_int(e.parse(expr)).is_equal(OK)
	return int(e.execute())


func _assert_choices(choices: Array, answer: String) -> void:
	assert_int(choices.size()).is_equal(4)
	assert_bool(choices.has(answer)).is_true()
	var unique := {}
	for c in choices:
		unique[c] = true
	assert_int(unique.size()).is_equal(4)


func test_math_answers_are_correct_for_every_grade() -> void:
	seed(7)
	for grade in range(1, 6):
		for i in SAMPLES:
			var item: Dictionary = Q.math_question(grade)
			assert_str(String(item["answer"])).is_equal(str(_eval(String(item["q"]))))
			_assert_choices(item["choices"], String(item["answer"]))


func test_banks_have_valid_items_for_every_grade() -> void:
	for bank in [Q.GRAMMAR_BANK, Q.READING_BANK]:
		for grade in range(1, 6):
			assert_int((bank[grade] as Array).size()).is_greater(0)
			for item in bank[grade]:
				_assert_choices(item["choices"], String(item["answer"]))


func test_rounds_have_the_configured_length() -> void:
	seed(11)
	for subject in ["math", "grammar", "reading"]:
		for grade in range(1, 6):
			var round_items: Array = Q.round_for(subject, grade)
			assert_int(round_items.size()).is_equal(mini(Q.ROUND_LENGTH[subject], round_items.size()))
			assert_int(round_items.size()).is_greater(0)
