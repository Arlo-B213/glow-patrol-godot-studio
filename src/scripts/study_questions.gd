class_name StudyQuestions
extends RefCounted
## Quiz questions for Study Hall and the Lounge missions (grades 1-5). Pure functions: questions
## come from the global RNG, so tests can seed it. Banks are static; math is generated per call.

const ROUND_LENGTH := {"math": 8, "grammar": 5, "reading": 3}

const GRAMMAR_BANK := {
	1: [
		{"q": "Pick the correctly written sentence.", "choices": ["the cat is sleeping", "The cat is sleeping.", "The Cat is sleeping", "the cat Is sleeping."], "answer": "The cat is sleeping."},
		{"q": "Which word is a noun?", "choices": ["run", "happy", "dog", "fast"], "answer": "dog"},
		{"q": "Which word is a verb?", "choices": ["jump", "blue", "chair", "slow"], "answer": "jump"},
		{"q": "Which ending punctuation fits: \"Do you like ice cream\"", "choices": [".", "?", "!", ","], "answer": "?"},
		{"q": "What is the plural of \"cat\"?", "choices": ["cats", "cates", "cat's", "caties"], "answer": "cats"},
	],
	2: [
		{"q": "Which word is spelled correctly?", "choices": ["frend", "friend", "freind", "frind"], "answer": "friend"},
		{"q": "Choose the past-tense verb: \"Yesterday I ___ to the park.\"", "choices": ["go", "goes", "went", "going"], "answer": "went"},
		{"q": "Which word is an adjective in \"The big dog barked\"?", "choices": ["big", "dog", "barked", "The"], "answer": "big"},
		{"q": "Which sentence uses \"their\" correctly?", "choices": ["Their going home.", "They put their shoes on.", "Their is a cat.", "Their happy today."], "answer": "They put their shoes on."},
		{"q": "What is the plural of \"box\"?", "choices": ["boxs", "boxes", "box's", "boxxes"], "answer": "boxes"},
	],
	3: [
		{"q": "Which word is an adverb in \"She sang loudly\"?", "choices": ["She", "sang", "loudly", "song"], "answer": "loudly"},
		{"q": "Choose the correct word: \"I saw ___ deer in the woods.\"", "choices": ["to", "too", "two", "tew"], "answer": "two"},
		{"q": "Which sentence is a question?", "choices": ["The sun is bright.", "Close the door.", "Why is the sky blue?", "I like pizza."], "answer": "Why is the sky blue?"},
		{"q": "What is the plural of \"child\"?", "choices": ["childs", "childes", "children", "childrens"], "answer": "children"},
		{"q": "Which word means the opposite of \"happy\"?", "choices": ["glad", "sad", "joyful", "excited"], "answer": "sad"},
	],
	4: [
		{"q": "Choose the sentence with correct subject-verb agreement.", "choices": ["The dogs runs fast.", "The dogs run fast.", "The dog run fast.", "The dog running fast."], "answer": "The dogs run fast."},
		{"q": "Which word is a conjunction in \"I wanted to go, but it rained\"?", "choices": ["wanted", "but", "rained", "go"], "answer": "but"},
		{"q": "Choose the correctly punctuated sentence.", "choices": ["Lets eat Grandma!", "Let's eat, Grandma!", "Lets eat, grandma", "Let's eat Grandma"], "answer": "Let's eat, Grandma!"},
		{"q": "Which is a synonym for \"quick\"?", "choices": ["slow", "fast", "tired", "quiet"], "answer": "fast"},
		{"q": "Identify the pronoun in \"She gave the book to him.\"", "choices": ["book", "gave", "She", "to"], "answer": "She"},
	],
	5: [
		{"q": "Which sentence uses correct capitalization?", "choices": ["We visited paris in june.", "We visited Paris in June.", "we visited Paris in june.", "We Visited Paris In June."], "answer": "We visited Paris in June."},
		{"q": "Which shows the correct possessive for one dog owning a bone?", "choices": ["dogs bone", "dog's bone", "dogs' bone", "dog's' bone"], "answer": "dog's bone"},
		{"q": "Which word is an adverb?", "choices": ["quickly", "quick", "quickness", "quicken"], "answer": "quickly"},
		{"q": "Choose the sentence free of run-on errors.", "choices": ["I like dogs I like cats too.", "I like dogs, and I like cats too.", "I like dogs and cats I like them.", "I like, dogs and cats."], "answer": "I like dogs, and I like cats too."},
		{"q": "What type of sentence is \"Watch out for that puddle!\"?", "choices": ["Declarative", "Interrogative", "Exclamatory", "Imperative"], "answer": "Exclamatory"},
	],
}

const READING_BANK := {
	1: [
		{"passage": "Max is a little dog. He likes to play with a red ball. Max runs fast in the park.", "q": "What does Max like to play with?", "choices": ["A red ball", "A blue box", "A cat", "A bike"], "answer": "A red ball"},
		{"passage": "Lily has a pet fish. The fish is orange. It swims in a round bowl.", "q": "What color is Lily's fish?", "choices": ["Blue", "Orange", "Green", "Purple"], "answer": "Orange"},
		{"passage": "It is raining outside. Sam puts on his yellow boots. He jumps in the puddles.", "q": "What color are Sam's boots?", "choices": ["Red", "Green", "Yellow", "Black"], "answer": "Yellow"},
	],
	2: [
		{"passage": "The Lanternboys light up the alley every night. Hae carries the biggest lantern. Bit hums a happy tune while he walks.", "q": "Who carries the biggest lantern?", "choices": ["Bit", "Nun", "Hae", "Sam"], "answer": "Hae"},
		{"passage": "A caterpillar eats leaves all day long. After many weeks, it makes a small case called a cocoon. Later, it comes out as a butterfly.", "q": "What does a caterpillar turn into?", "choices": ["A moth", "A butterfly", "A bird", "A bee"], "answer": "A butterfly"},
		{"passage": "Every morning, the baker makes fresh bread. The smell fills the whole street. People line up early to buy a warm loaf.", "q": "What does the baker make?", "choices": ["Fresh bread", "Cold pizza", "Ice cream", "Soup"], "answer": "Fresh bread"},
	],
	3: [
		{"passage": "Gloomlings are small, shy creatures that only come out at night. They are not really mean — they just like to float around and look for quiet places to rest. A gentle tap of light is enough to send them home.", "q": "Why do Gloomlings float around at night?", "choices": ["To scare people", "To look for quiet places to rest", "To eat leaves", "To find their lanterns"], "answer": "To look for quiet places to rest"},
		{"passage": "The desert is very dry, but some animals still live there. Camels can go many days without water. Their humps store fat, not water, which helps them survive long trips.", "q": "What do a camel's humps store?", "choices": ["Water", "Fat", "Sand", "Air"], "answer": "Fat"},
		{"passage": "Long ago, people used the stars to find their way at night. Sailors would look for the North Star because it always points north. This helped ships travel safely across the ocean.", "q": "Why did sailors look for the North Star?", "choices": ["It was the brightest star", "It always points north", "It changes color", "It was closest to the moon"], "answer": "It always points north"},
	],
	4: [
		{"passage": "Recycling helps the Earth in many ways. When we recycle paper, fewer trees need to be cut down. When we recycle metal and plastic, less new material has to be dug up or made. Small actions, like rinsing out a can, can make a big difference over time.", "q": "What is one benefit of recycling paper?", "choices": ["It makes paper shinier", "Fewer trees need to be cut down", "It creates more plastic", "It uses more water"], "answer": "Fewer trees need to be cut down"},
		{"passage": "Music has a strange power over memory. Scientists have found that hearing a song from years ago can bring back memories of exactly where you were and how you felt. This is one reason old favorite songs feel emotional.", "q": "Why might an old song make someone feel emotional?", "choices": ["Songs are always sad", "It can bring back old memories", "Radios are broken", "People forget the words"], "answer": "It can bring back old memories"},
		{"passage": "Before refrigerators existed, people used ice houses to keep food cold. Blocks of ice were cut from frozen lakes in winter and stored underground, packed in sawdust to keep them from melting.", "q": "What was used to keep the ice blocks from melting?", "choices": ["Sawdust", "Salt water", "Sunlight", "Plastic wrap"], "answer": "Sawdust"},
	],
	5: [
		{"passage": "The human body is made up of trillions of cells, each with its own job. Red blood cells carry oxygen throughout the body, while white blood cells fight off germs. Together, these tiny cells keep the whole body running.", "q": "What is the main idea of this passage?", "choices": ["Cells are too small to matter", "Different cells have different jobs that keep the body running", "White blood cells are stronger than red ones", "Microscopes were invented recently"], "answer": "Different cells have different jobs that keep the body running"},
		{"passage": "In 1969, astronauts landed on the Moon for the first time. It took years of planning, powerful rockets, and brave crews willing to take the risk. The success of that mission showed what people could achieve by working toward a shared goal.", "q": "What helped make the Moon landing possible?", "choices": ["Luck alone", "Years of planning and teamwork", "A single scientist working alone", "Modern smartphones"], "answer": "Years of planning and teamwork"},
		{"passage": "Not all storms are dangerous, but some can be. A thunderstorm becomes severe when it produces large hail, strong winds, or a tornado. Meteorologists study weather patterns closely so they can warn people before a severe storm arrives.", "q": "Why do meteorologists study weather patterns?", "choices": ["To predict sports scores", "To warn people before severe storms arrive", "To make storms stronger", "To control the weather"], "answer": "To warn people before severe storms arrive"},
	],
}

static func _rand_int(min_v: int, max_v: int) -> int:
	return min_v + randi() % (max_v - min_v + 1)


static func _build_numeric_choices(answer: int) -> Array:
	var set_vals: Array = [answer]
	var guard := 0
	while set_vals.size() < 4 and guard < 40:
		guard += 1
		var mag: int = randi() % 9 + 1
		var offset: int = mag if randf() < 0.5 else -mag
		var val: int = answer + offset
		if val >= 0 and not set_vals.has(val):
			set_vals.append(val)
	set_vals.shuffle()
	var out: Array = []
	for v in set_vals:
		out.append(str(v))
	return out


static func math_question(grade: int) -> Dictionary:
	var a := 0
	var b := 0
	var answer := 0
	var q := ""
	if grade <= 1:
		a = _rand_int(1, 10)
		b = _rand_int(1, 10)
		if a < b:
			var t := a
			a = b
			b = t
		if randf() < 0.5:
			answer = a + b
			q = "%d + %d = ?" % [a, b]
		else:
			answer = a - b
			q = "%d − %d = ?" % [a, b]
	elif grade == 2:
		a = _rand_int(10, 60)
		b = _rand_int(5, 40)
		if a < b:
			var t2 := a
			a = b
			b = t2
		if randf() < 0.5:
			answer = a + b
			q = "%d + %d = ?" % [a, b]
		else:
			answer = a - b
			q = "%d − %d = ?" % [a, b]
	elif grade == 3:
		if randf() < 0.6:
			a = _rand_int(2, 10)
			b = _rand_int(2, 10)
			answer = a * b
			q = "%d × %d = ?" % [a, b]
		else:
			a = _rand_int(100, 500)
			b = _rand_int(50, 300)
			answer = a + b
			q = "%d + %d = ?" % [a, b]
	elif grade == 4:
		var mode := randf()
		if mode < 0.45:
			a = _rand_int(11, 25)
			b = _rand_int(2, 9)
			answer = a * b
			q = "%d × %d = ?" % [a, b]
		else:
			b = _rand_int(2, 9)
			answer = _rand_int(2, 12)
			a = b * answer
			q = "%d ÷ %d = ?" % [a, b]
	else:
		var mode5 := randf()
		if mode5 < 0.4:
			a = _rand_int(12, 30)
			b = _rand_int(11, 20)
			answer = a * b
			q = "%d × %d = ?" % [a, b]
		elif mode5 < 0.75:
			b = _rand_int(3, 12)
			answer = _rand_int(4, 15)
			a = b * answer
			q = "%d ÷ %d = ?" % [a, b]
		else:
			a = _rand_int(200, 900)
			b = _rand_int(150, 700)
			var hi: int = max(a, b)
			var lo: int = min(a, b)
			answer = hi - lo
			q = "%d − %d = ?" % [hi, lo]
	return {"q": q, "choices": _build_numeric_choices(answer), "answer": str(answer)}


## One shuffled round of `subject` questions for `grade`, ROUND_LENGTH[subject] long (or fewer if a bank is short).
static func round_for(subject: String, grade: int) -> Array:
	var length: int = ROUND_LENGTH[subject]
	if subject == "math":
		var out: Array = []
		for i in range(length):
			out.append(math_question(grade))
		return out
	var bank: Array = (GRAMMAR_BANK if subject == "grammar" else READING_BANK)[grade].duplicate()
	bank.shuffle()
	return bank.slice(0, min(length, bank.size()))
