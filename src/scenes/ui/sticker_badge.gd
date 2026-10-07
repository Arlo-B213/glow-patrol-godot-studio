class_name StickerBadge
extends Control
const FD := preload("res://scripts/fast_draw.gd")
## Round sticker badge drawn in code: coloured disc, scalloped rim and a UiIcon.
## Locked stickers are grey with a "?".

var icon_name := "star"
var color := UiTheme.GOLD
var earned := false


## Configures the badge and sizes it `px` square. Returns self.
func setup(icon: String, tint: Color, is_earned: bool, px: float = 84.0) -> StickerBadge:
	icon_name = icon
	color = tint
	earned = is_earned
	custom_minimum_size = Vector2(px, px)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()
	return self


func _draw() -> void:
	var c := size / 2.0
	var r := minf(size.x, size.y) / 2.0 - 2.0
	var base := color if earned else UiTheme.LOCKED.darkened(0.2)
	# Scalloped rim: 12 small discs around the edge.
	for i in 12:
		var a := TAU * float(i) / 12.0
		FD.circle(self, c + Vector2(cos(a), sin(a)) * r * 0.86, r * 0.17, base.lightened(0.15))
	FD.circle(self, c, r * 0.86, base.darkened(0.35))
	FD.circle(self, c, r * 0.74, base)
	FD.arc(self, c, r * 0.62, 0.0, TAU, 40, Color(1, 1, 1, 0.35 if earned else 0.15), 2.0, true)
	var inner := Rect2(c - Vector2(r, r) * 0.46, Vector2(r, r) * 0.92)
	if earned:
		UiIcons.draw(self, icon_name, inner, UiTheme.TEXT_ON_ACCENT if base.get_luminance() > 0.5 else Color.WHITE)
	else:
		var font := ThemeDB.fallback_font
		var fs := int(r * 0.9)
		var w := font.get_string_size("?", HORIZONTAL_ALIGNMENT_CENTER, -1, fs).x
		draw_string(font, Vector2(c.x - w / 2.0, c.y + fs * 0.34), "?",
			HORIZONTAL_ALIGNMENT_LEFT, -1, fs, UiTheme.TEXT_MUTED)
