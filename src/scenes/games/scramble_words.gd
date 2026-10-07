extends RefCounted
## Word data and pure logic for Word Scramble (Story 029): grade 1-5 word lists with a short clue
## each, round picking and a shuffle that never returns the word itself. Headless-testable.

const ROUND_WORDS := 8
## Seconds allowed per word by grade (gentle: running out only reveals the word).
const TIME_BY_GRADE := {1: 60.0, 2: 55.0, 3: 50.0, 4: 50.0, 5: 60.0}

## [word, clue] pairs. Grade 1: 3-4 letters ... grade 5: 7-9 letters.
const WORDS := {
	1: [
		["cat", "A furry pet that purrs."], ["sun", "It shines in the sky all day."], ["dog", "A pet that barks and wags its tail."],
		["hat", "You wear it on your head."], ["bed", "You sleep in it at night."], ["cup", "You drink milk from it."],
		["pig", "A pink farm animal that oinks."], ["bus", "A big vehicle that takes kids to school."], ["fish", "It swims in the water."],
		["frog", "A green animal that hops and croaks."], ["tree", "It has leaves and a trunk."], ["star", "It twinkles in the night sky."],
		["moon", "It glows in the sky at night."], ["cake", "A sweet treat for birthdays."], ["ball", "Kick it, throw it or bounce it."],
		["duck", "A bird that says quack."], ["bird", "It has wings and sings in the morning."], ["book", "You read the pages of it."],
		["rain", "Water that falls from the clouds."], ["snow", "Cold white flakes that fall in winter."], ["milk", "A white drink from a cow."],
		["bear", "A big furry animal that loves honey."], ["kite", "It flies high on a string."], ["fork", "You eat peas with it."],
		["door", "You open it to walk into a room."], ["hand", "It has five fingers."], ["nose", "You smell flowers with it."],
		["boat", "It floats and sails on water."], ["cow", "A farm animal that says moo."], ["hen", "A mother chicken."],
		["bee", "A buzzing insect that makes honey."], ["egg", "A hen lays it."], ["jam", "A sweet fruity spread for toast."],
		["map", "It shows you where places are."], ["sock", "You wear it inside your shoe."],
	],
	2: [
		["apple", "A crunchy red or green fruit."], ["bread", "You make a sandwich with two slices."], ["chair", "You sit on it at the table."],
		["tiger", "A big striped cat."], ["plant", "A green thing that grows in soil."], ["cloud", "A fluffy white shape in the sky."],
		["horse", "You can ride this animal."], ["sheep", "Its wool keeps us warm."], ["mouse", "A tiny animal that loves cheese."],
		["table", "You put your dinner plate on it."], ["house", "A place where a family lives."], ["beach", "Sand and waves are found here."],
		["river", "Water that flows along to the sea."], ["train", "It rolls along tracks and goes choo choo."], ["smile", "A happy look on your face."],
		["light", "A lamp gives you this in the dark."], ["grass", "Green and soft, it grows on the lawn."], ["water", "You drink it when you are thirsty."],
		["clock", "It tells you the time."], ["shoes", "You wear them on your feet."], ["socks", "They keep your toes cosy."],
		["dream", "Pictures in your mind while you sleep."], ["panda", "A black and white bear that eats bamboo."], ["zebra", "A striped animal like a horse."],
		["lemon", "A sour yellow fruit."], ["pizza", "A round meal with cheese on top."], ["camel", "A desert animal with a hump."],
		["whale", "The biggest animal in the ocean."], ["snake", "A long animal that slithers."], ["eagle", "A big bird that soars high."],
		["ocean", "A huge body of salty water."], ["party", "Friends gather to celebrate."], ["piano", "You press its black and white keys."],
		["robot", "A machine that can move and beep."],
	],
	3: [
		["garden", "A place where flowers and vegetables grow."], ["planet", "Earth is one of these."], ["rabbit", "A fluffy animal with long ears."],
		["pencil", "You write with it and it has an eraser."], ["window", "You look through it and it is made of glass."], ["jungle", "A thick, hot forest full of animals."],
		["castle", "A king and queen live in this."], ["dragon", "A make-believe animal that breathes fire."], ["rocket", "It blasts off into space."],
		["button", "You push it through a hole on a shirt."], ["pillow", "You rest your head on it in bed."], ["monkey", "It swings in trees and loves bananas."],
		["turtle", "A slow animal with a shell."], ["flower", "A pretty plant with petals."], ["basket", "You carry picnic food in it."],
		["bridge", "It lets cars cross over a river."], ["candle", "A little flame sits on top of it."], ["forest", "Many, many trees growing together."],
		["island", "Land with water all around it."], ["yellow", "The colour of a sunflower."], ["orange", "A round fruit and also a colour."],
		["purple", "Mix red and blue to get this colour."], ["school", "Kids learn here every day."], ["kitten", "A baby cat."],
		["puppy", "A baby dog."], ["butter", "A yellow spread for bread."], ["silver", "A shiny grey metal."],
		["circus", "Clowns and acrobats perform here."], ["magnet", "It sticks to the fridge."], ["summer", "The hottest season of the year."],
		["winter", "The coldest season of the year."], ["spring", "The season when flowers start to bloom."],
	],
	4: [
		["balloon", "A party toy filled with air."], ["blanket", "It keeps you warm on the sofa."], ["giraffe", "The tallest animal with a long neck."],
		["chicken", "A farm bird that lays eggs."], ["dolphin", "A clever, friendly sea animal that jumps."], ["penguin", "A bird that cannot fly but loves ice."],
		["pumpkin", "A big orange vegetable for pies and lanterns."], ["rainbow", "Colours in the sky after the rain."], ["teacher", "This person helps you learn at school."],
		["farmer", "This person grows crops and raises animals."], ["kitchen", "The room where we cook dinner."], ["mailbox", "Letters arrive in this."],
		["trumpet", "A shiny brass horn you blow into."], ["picnic", "A meal you eat outside on the grass."], ["journey", "A long trip to somewhere far."],
		["lantern", "A light you can carry that glows."], ["harvest", "Gathering the crops in autumn."], ["compass", "Its needle points to north."],
		["whistle", "You blow into it to make a sharp sound."], ["thunder", "A loud boom during a storm."], ["volcano", "A mountain that can erupt with lava."],
		["diamond", "A sparkly gem."], ["library", "A quiet place full of books to borrow."], ["village", "A small town in the countryside."],
		["morning", "The early part of the day."], ["evening", "The time just before night."], ["feather", "Soft and light, it grows on a bird."],
		["captain", "The leader of a ship."], ["painter", "An artist who uses brushes and colours."], ["sparkle", "To shine with tiny flashes."],
		["blossom", "A flower on a tree in spring."], ["bicycle", "You pedal it and it has two wheels."],
	],
	5: [
		["adventure", "An exciting journey with surprises."], ["butterfly", "An insect with colourful wings that was once a caterpillar."], ["mountain", "A very tall hill with a peak."],
		["elephant", "A huge animal with a trunk."], ["notebook", "You write your notes inside it."], ["hospital", "Doctors and nurses work here."],
		["sunshine", "The warm light of the sun."], ["umbrella", "You hold it over your head in the rain."], ["treasure", "Pirates hide chests of gold and jewels."],
		["airplane", "It flies passengers through the sky."], ["dinosaur", "A giant reptile that lived long ago."], ["football", "A team sport played with an oval or round ball."],
		["pancakes", "Flat breakfast cakes you eat with syrup."], ["scissors", "You use them to cut paper."], ["telescope", "You look through it to see the stars."],
		["crocodile", "A big reptile with strong jaws that lives in rivers."], ["chocolate", "A sweet brown treat made from cocoa."], ["fireworks", "They burst with colour in the night sky."],
		["invention", "A brand new machine someone creates."], ["backpack", "You carry your school things in it."], ["calendar", "It shows the days and months of the year."],
		["triangle", "A shape with three sides."], ["whirlwind", "A spinning column of wind."], ["snowflake", "A tiny frozen crystal that falls in winter."],
		["ladybug", "A small red beetle with black spots."], ["universe", "Everything: all the planets, stars and space."], ["explorer", "Someone who travels to find new places."],
		["keyboard", "You type on it with your fingers."], ["sandwich", "Two slices of bread with a filling."], ["vacation", "A holiday away from school or work."],
		["geography", "The study of maps, lands and countries."], ["orchestra", "A big group of musicians playing together."], ["spaceship", "A vehicle that travels among the stars."],
	],
}


## Word list ([word, clue] pairs) for a grade, clamped to 1-5.
static func for_grade(grade: int) -> Array:
	return WORDS[clampi(grade, 1, 5)]


## Seconds per word for a grade.
static func time_for(grade: int) -> float:
	return float(TIME_BY_GRADE[clampi(grade, 1, 5)])


## Picks `count` different entries for a grade (seeded, deterministic for a given rng).
static func pick_round(grade: int, rng: RandomNumberGenerator, count: int = ROUND_WORDS) -> Array:
	var pool: Array = for_grade(grade).duplicate()
	var out: Array = []
	while out.size() < count and not pool.is_empty():
		out.append(pool.pop_at(rng.randi() % pool.size()))
	return out


## Shuffles the letters of `word`; the result is never equal to `word` (when any other order exists).
static func scramble(word: String, rng: RandomNumberGenerator) -> String:
	var letters: Array = []
	for i in word.length():
		letters.append(word[i])
	for attempt in 30:
		for i in range(letters.size() - 1, 0, -1):
			var j: int = rng.randi() % (i + 1)
			var tmp: Variant = letters[i]
			letters[i] = letters[j]
			letters[j] = tmp
		if "".join(letters) != word:
			return "".join(letters)
	# Deterministic fallback: rotate until different (only impossible when all letters are equal).
	for shift in range(1, word.length()):
		var rot: String = word.substr(shift) + word.substr(0, shift)
		if rot != word:
			return rot
	return word
