extends SceneTree
## Renders every synthesized SFX and music track exactly as the game does (Sfx autoload rates and
## peaks) and prints measurable facts: duration, peak, RMS, DC offset, clipping, the largest sample
## jump (clicks), and for music the loop seam. Nothing here replaces listening. Run headless:
##   godot --headless --path src -s res://tools/audio_report.gd

const SFX_RATE := 16000
const SFX_PEAK := 0.6
const SfxSynthRef := preload("res://scripts/sfx_synth.gd")
const MusicRef := preload("res://scripts/music_tracks.gd")
const SFX_IDS := ["tap", "back", "punch", "hit", "enemy_defeat", "boss_hit", "star", "coin", "level_up",
	"high_five", "chapter", "win", "lose", "eat", "pet_happy", "grow", "error", "whoosh", "correct", "wrong"]
const TRACK_IDS := ["hq", "battle", "games", "study", "club", "pets", "story", "win"]


func _init() -> void:
	var problems := 0
	print("SFX (rate %d, peak cap %.2f)" % [SFX_RATE, SFX_PEAK])
	for id in SFX_IDS:
		var s: AudioStreamWAV = SfxSynthRef.render_sfx(id, SFX_RATE, SFX_PEAK)
		if s == null:
			print("  MISSING ", id)
			problems += 1
			continue
		var st := _stats(s)
		var flag := _flag(st)
		problems += 0 if flag == "" else 1
		print("  %-12s dur=%6.0fms peak=%.2f rms=%6.1fdB dc=%+.3f clip=%d maxjump=%.2f %s" % [
			id, st["dur"] * 1000.0, st["peak"], st["rms_db"], st["dc"], st["clip"], st["jump"], flag])
	print("MUSIC (rate %d, peak cap 0.50)" % MusicRef.RATE)
	for id in TRACK_IDS:
		var m: AudioStreamWAV = MusicRef.render(id)
		if m == null:
			print("  MISSING ", id)
			problems += 1
			continue
		var st := _stats(m)
		var seam := _seam(m)
		var flag := _flag(st)
		if seam > 0.12:
			flag += " SEAM"
			problems += 1
		problems += 0 if _flag(st) == "" else 1
		print("  %-8s dur=%5.1fs peak=%.2f rms=%6.1fdB dc=%+.3f clip=%d maxjump=%.2f seam=%.3f %s" % [
			id, st["dur"], st["peak"], st["rms_db"], st["dc"], st["clip"], st["jump"], seam, flag])
	print("PROBLEMS ", problems)
	print("DONE")
	quit()


## Decodes a 16-bit mono WAV stream into floats and measures it.
func _stats(s: AudioStreamWAV) -> Dictionary:
	var n: int = s.data.size() / 2
	var peak := 0.0
	var sum_sq := 0.0
	var sum := 0.0
	var clip := 0
	var jump := 0.0
	var prev := 0.0
	for i in n:
		var x: float = s.data.decode_s16(i * 2) / 32768.0
		peak = maxf(peak, absf(x))
		sum_sq += x * x
		sum += x
		if absf(x) >= 0.99:
			clip += 1
		if i > 0:
			jump = maxf(jump, absf(x - prev))
		prev = x
	var rms := sqrt(sum_sq / maxf(1, n))
	return {"dur": float(n) / float(s.mix_rate), "peak": peak,
		"rms_db": 20.0 * log(maxf(rms, 0.000001)) / log(10.0), "dc": sum / maxf(1, n),
		"clip": clip, "jump": jump, "edge": maxf(absf(s.data.decode_s16(0) / 32768.0), absf(s.data.decode_s16((n - 1) * 2) / 32768.0))}


## Loop seam: the jump between the last and first sample of a looping track, relative to peak.
func _seam(s: AudioStreamWAV) -> float:
	var n: int = s.data.size() / 2
	var first: float = s.data.decode_s16(0) / 32768.0
	var last: float = s.data.decode_s16((n - 1) * 2) / 32768.0
	return absf(first - last)


## Flags silence, clipping, a click (sample jump above `max_jump` of full scale) or a DC offset.
func _flag(st: Dictionary) -> String:
	if st["peak"] < 0.001:
		return "SILENT"
	if st["clip"] > 0:
		return "CLIP"
	if st["edge"] > 0.01:
		return "EDGE"
	if absf(st["dc"]) > 0.02:
		return "DC"
	return ""
