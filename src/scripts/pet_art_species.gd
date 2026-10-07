extends RefCounted
## Species dispatcher for PetArt (Story 024/033). Each species body draws in pet space
## (ground centre 0,0, up is negative) for stages baby..adult from the shared context `p`
## built by PetArt.draw, and records its head/eye/neck anchors for accessories and effects.
## Unknown ids fall back to Puff. Simple polygons only.

const Xolo := preload("res://scripts/pet_art_xolo.gd")
const Puff := preload("res://scripts/pet_art_puff.gd")
const Fox := preload("res://scripts/pet_art_fox.gd")
const Bun := preload("res://scripts/pet_art_moonbun.gd")
const Drake := preload("res://scripts/pet_art_inkydrake.gd")


static func draw_species(ci: CanvasItem, species: String, p: Dictionary) -> void:
	match species:
		"xolo": Xolo.draw(ci, p)
		"puff": Puff.draw(ci, p)
		"sparkfox": Fox.draw(ci, p)
		"moonbun": Bun.draw(ci, p)
		"inkydrake": Drake.draw(ci, p)
		_: Puff.draw(ci, p)
