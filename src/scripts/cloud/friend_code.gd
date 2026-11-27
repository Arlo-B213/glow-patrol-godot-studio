class_name FriendCode
extends RefCounted
## Six-character friend codes. Letters and digits that are easy to confuse (0, O, 1, I, L) are left
## out, so a code can be read aloud or copied by hand.

const LENGTH := 6
const ALPHABET := "ABCDEFGHJKMNPQRSTUVWXYZ23456789"


## A random code from `rng`. Pass a seeded generator in tests.
static func generate(rng: RandomNumberGenerator) -> String:
	var out := ""
	for i in LENGTH:
		out += ALPHABET[rng.randi_range(0, ALPHABET.length() - 1)]
	return out


## True when `code` has the right length and only alphabet characters.
static func is_valid(code: String) -> bool:
	if code.length() != LENGTH:
		return false
	for ch in code:
		if not ALPHABET.contains(ch):
			return false
	return true


## Tidies what a player typed: spaces and hyphens removed, letters uppercased.
static func normalize(typed: String) -> String:
	return typed.replace(" ", "").replace("-", "").strip_edges().to_upper()
