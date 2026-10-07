class_name SfxSynth
extends RefCounted
## Tiny code-only synthesizer: renders note lists into 16-bit mono AudioStreamWAV.
## Story 018 (design/game-brief.md enhancement round). No audio files are used.
## Notes are arrays [wave, start_s, dur_s, midi_from, midi_to, volume].

const SINE := 0
const SQUARE := 1
const TRI := 2
const NOISE := 3

## SFX recipes: id -> Array of notes [wave, start, dur, midi0, midi1, vol].
const RECIPES: Dictionary = {
	"tap": [[2, 0.0, 0.05, 84, 80, 0.5]],
	"back": [[2, 0.0, 0.08, 76, 66, 0.5]],
	"punch": [[3, 0.0, 0.09, 62, 40, 0.6], [2, 0.0, 0.13, 52, 34, 0.6]],
	"hit": [[3, 0.0, 0.06, 74, 60, 0.5], [1, 0.0, 0.08, 60, 48, 0.25]],
	"enemy_defeat": [[1, 0.0, 0.08, 72, 60, 0.25], [1, 0.08, 0.08, 67, 55, 0.25], [2, 0.16, 0.22, 60, 36, 0.5]],
	"boss_hit": [[3, 0.0, 0.16, 58, 36, 0.6], [2, 0.0, 0.22, 48, 28, 0.6]],
	"star": [[2, 0.0, 0.08, 84, 84, 0.5], [2, 0.08, 0.22, 91, 91, 0.5], [0, 0.08, 0.22, 103, 103, 0.12]],
	"coin": [[1, 0.0, 0.06, 83, 83, 0.25], [1, 0.06, 0.24, 88, 88, 0.25]],
	"level_up": [[2, 0.0, 0.1, 72, 72, 0.5], [2, 0.1, 0.1, 76, 76, 0.5], [2, 0.2, 0.1, 79, 79, 0.5],
		[2, 0.3, 0.35, 84, 84, 0.5], [1, 0.3, 0.35, 72, 72, 0.12]],
	"high_five": [[3, 0.0, 0.05, 82, 72, 0.45], [2, 0.02, 0.12, 79, 79, 0.4], [2, 0.14, 0.2, 84, 84, 0.45]],
	"chapter": [[2, 0.0, 0.14, 67, 67, 0.45], [2, 0.14, 0.14, 72, 72, 0.45], [2, 0.28, 0.14, 76, 76, 0.45],
		[2, 0.42, 0.14, 79, 79, 0.45], [2, 0.56, 0.5, 84, 84, 0.45], [0, 0.56, 0.5, 72, 72, 0.2],
		[0, 0.56, 0.5, 76, 76, 0.15]],
	"win": [[2, 0.0, 0.12, 72, 72, 0.5], [2, 0.12, 0.12, 76, 76, 0.5], [2, 0.24, 0.12, 79, 79, 0.5],
		[2, 0.36, 0.12, 84, 84, 0.5], [2, 0.5, 0.1, 79, 79, 0.45], [2, 0.6, 0.55, 84, 84, 0.5],
		[0, 0.6, 0.55, 76, 76, 0.18], [0, 0.6, 0.55, 67, 67, 0.18]],
	"lose": [[2, 0.0, 0.18, 72, 72, 0.45], [2, 0.2, 0.18, 69, 69, 0.45], [2, 0.4, 0.18, 65, 65, 0.45],
		[2, 0.6, 0.4, 60, 58, 0.45]],
	"eat": [[3, 0.0, 0.05, 70, 60, 0.4], [3, 0.1, 0.05, 68, 58, 0.4], [3, 0.2, 0.06, 66, 56, 0.4]],
	"pet_happy": [[2, 0.0, 0.08, 79, 84, 0.45], [2, 0.1, 0.08, 84, 88, 0.45], [2, 0.2, 0.16, 88, 91, 0.45]],
	"grow": [[2, 0.0, 0.5, 60, 84, 0.5], [0, 0.0, 0.5, 72, 96, 0.2], [2, 0.5, 0.2, 88, 88, 0.4]],
	"error": [[2, 0.0, 0.1, 55, 55, 0.5], [2, 0.12, 0.16, 50, 50, 0.5]],
	"whoosh": [[3, 0.0, 0.25, 50, 80, 0.45]],
	"correct": [[2, 0.0, 0.09, 79, 79, 0.5], [2, 0.09, 0.2, 84, 84, 0.5]],
	"wrong": [[1, 0.0, 0.12, 60, 58, 0.22], [1, 0.12, 0.18, 55, 53, 0.22]],
}


## Convert a MIDI note number to frequency in Hz.
static func mtof(m: float) -> float:
	return 440.0 * pow(2.0, (m - 69.0) / 12.0)


## Add one note into a float mix buffer (soft attack, linear release).
static func add_note(buf: PackedFloat32Array, rate: int, note: Array, gain: float = 1.0,
		atk_s: float = 0.004, rel_s: float = -1.0) -> void:
	var wave: int = note[0]
	var n0: int = int(float(note[1]) * rate)
	var n: int = int(float(note[2]) * rate)
	if n <= 0:
		return
	var m0: float = note[3]
	var m1: float = note[4]
	var vol: float = float(note[5]) * gain
	var rel_n: float = maxf(1.0, (minf(float(note[2]) * 0.6, 0.12) if rel_s < 0.0 else rel_s) * rate)
	var atk_n: float = maxf(1.0, atk_s * rate)
	var phase := 0.0
	var seed_v: int = 12345 + n0
	var lp := 0.0
	var size: int = buf.size()
	var inv_n: float = 1.0 / float(n)
	for i in n:
		var idx: int = n0 + i
		if idx >= size:
			break
		var f: float = mtof(lerpf(m0, m1, float(i) * inv_n))
		var env: float = minf(minf(1.0, float(i) / atk_n), float(n - i) / rel_n)
		var s: float
		if wave == NOISE:
			seed_v = (seed_v * 1103515245 + 12345) & 0x7fffffff
			var white: float = float(seed_v) / 1073741823.5 - 1.0
			lp += (white - lp) * clampf(f * 6.0 / rate, 0.03, 1.0)
			s = lp * 2.0
		else:
			phase += f / rate
			phase -= floorf(phase)
			if wave == SINE:
				s = sin(phase * TAU)
			elif wave == SQUARE:
				s = 1.0 if phase < 0.5 else -1.0
			else:
				s = 4.0 * absf(phase - 0.5) - 1.0
		buf[idx] += s * env * vol


## Scale buffer so its peak is at most `cap`, fade tiny edges, return a WAV stream.
static func to_stream(buf: PackedFloat32Array, rate: int, cap: float, edge: int = 32) -> AudioStreamWAV:
	var size: int = buf.size()
	var peak := 0.0
	for i in size:
		peak = maxf(peak, absf(buf[i]))
	var k: float = cap / peak if peak > cap else 1.0
	var bytes := PackedByteArray()
	bytes.resize(size * 2)
	for i in size:
		var e := 1.0
		if i < edge:
			e = float(i) / edge
		elif size - 1 - i < edge:
			e = float(size - 1 - i) / edge
		bytes.encode_s16(i * 2, int(clampf(buf[i] * k * e, -1.0, 1.0) * 32767.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.stereo = false
	wav.data = bytes
	return wav


## Render a named SFX recipe into a stream (peak <= cap). Returns null if unknown.
static func render_sfx(id: String, rate: int, cap: float) -> AudioStreamWAV:
	if not RECIPES.has(id):
		return null
	var notes: Array = RECIPES[id]
	var end_s := 0.0
	for nt in notes:
		end_s = maxf(end_s, float(nt[1]) + float(nt[2]))
	var buf := PackedFloat32Array()
	buf.resize(int(end_s * rate) + 64)
	for nt in notes:
		add_note(buf, rate, nt)
	return to_stream(buf, rate, cap)
