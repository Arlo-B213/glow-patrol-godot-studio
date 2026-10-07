class_name MusicTracks
extends RefCounted
## Data-driven chiptune loops (Story 018). Each track = 4 bars of 4 beats = 32 eighth steps.
## chords: 4 [root_midi, "M"|"m"] (one per bar). lead: 32 semitone offsets above the bar's
## chord root (99 = rest). bass: eighth-step indices within a bar that play the root (octave down).
## wave: lead waveform (see SfxSynth). drums: soft noise ticks on off-beats.

const RATE := 11025
const REST := 99
const TRIADS: Dictionary = {"M": [0, 4, 7], "m": [0, 3, 7]}

const TRACKS: Dictionary = {
	"hq": {"bpm": 100, "wave": 2, "drums": false, "bass": [0, 4],
		"chords": [[60, "M"], [57, "m"], [65, "M"], [67, "M"]],
		"lead": [4, 99, 7, 99, 12, 99, 7, 99,  0, 99, 4, 99, 9, 99, 4, 99,
			5, 99, 9, 99, 12, 99, 9, 99,  7, 99, 11, 99, 14, 99, 99, 99]},
	"battle": {"bpm": 140, "wave": 1, "drums": true, "bass": [0, 2, 4, 6],
		"chords": [[57, "m"], [53, "M"], [60, "M"], [55, "M"]],
		"lead": [0, 3, 7, 3, 12, 7, 3, 7,  0, 4, 7, 4, 12, 9, 7, 4,
			0, 4, 7, 4, 12, 7, 4, 7,  2, 5, 7, 5, 11, 7, 5, 2]},
	"games": {"bpm": 124, "wave": 1, "drums": true, "bass": [0, 3, 4, 7],
		"chords": [[60, "M"], [65, "M"], [67, "M"], [60, "M"]],
		"lead": [12, 99, 7, 12, 99, 16, 99, 12,  12, 99, 9, 12, 99, 17, 99, 12,
			14, 99, 11, 14, 99, 19, 99, 14,  16, 12, 7, 12, 16, 99, 12, 99]},
	"study": {"bpm": 90, "wave": 0, "drums": false, "bass": [0],
		"chords": [[62, "m"], [58, "M"], [53, "M"], [57, "m"]],
		"lead": [7, 99, 99, 99, 5, 99, 99, 99,  7, 99, 99, 99, 12, 99, 99, 99,
			4, 99, 99, 99, 7, 99, 99, 99,  5, 99, 99, 99, 3, 99, 99, 99]},
	"club": {"bpm": 108, "wave": 2, "drums": false, "bass": [0, 4],
		"chords": [[65, "M"], [60, "M"], [62, "m"], [60, "M"]],
		"lead": [0, 99, 4, 7, 99, 4, 0, 99,  7, 99, 4, 0, 99, 4, 7, 99,
			9, 99, 5, 2, 99, 5, 9, 99,  7, 99, 4, 0, 99, 99, 99, 99]},
	"pets": {"bpm": 84, "wave": 0, "drums": false, "bass": [0],
		"chords": [[67, "M"], [64, "m"], [60, "M"], [62, "M"]],
		"lead": [4, 99, 7, 99, 12, 99, 99, 99,  3, 99, 7, 99, 10, 99, 99, 99,
			4, 99, 7, 99, 12, 99, 99, 99,  2, 99, 6, 99, 9, 99, 99, 99]},
	"story": {"bpm": 96, "wave": 2, "drums": false, "bass": [0, 4],
		"chords": [[57, "m"], [57, "m"], [53, "M"], [52, "M"]],
		"lead": [0, 99, 3, 99, 7, 99, 6, 99,  3, 99, 0, 99, 99, 99, 99, 99,
			5, 99, 9, 99, 12, 99, 11, 99,  7, 99, 4, 99, 99, 99, 99, 99]},
	"win": {"bpm": 132, "wave": 1, "drums": true, "bass": [0, 4],
		"chords": [[60, "M"], [67, "M"], [65, "M"], [60, "M"]],
		"lead": [12, 16, 19, 16, 24, 19, 16, 19,  14, 19, 23, 19, 26, 23, 19, 14,
			12, 17, 21, 17, 24, 21, 17, 21,  16, 19, 24, 19, 28, 24, 99, 99]},
}


## True if a music track id exists.
static func has_track(id: String) -> bool:
	return TRACKS.has(id)


## Render a track into a seamlessly looping AudioStreamWAV, or null if unknown.
static func render(id: String, cap: float = 0.5) -> AudioStreamWAV:
	if not TRACKS.has(id):
		return null
	var t: Dictionary = TRACKS[id]
	var step_s: float = 30.0 / float(t["bpm"])
	var chords: Array = t["chords"]
	var lead: Array = t["lead"]
	var buf := PackedFloat32Array()
	buf.resize(int(step_s * 32.0 * RATE))
	var wave: int = t["wave"]
	for bar in 4:
		var root: int = chords[bar][0]
		var tri: Array = TRIADS[chords[bar][1]]
		var bar_s: float = bar * 8.0 * step_s
		for iv in tri:
			SfxSynth.add_note(buf, RATE, [SfxSynth.SINE, bar_s, step_s * 8.0, root + int(iv), root + int(iv), 0.12],
				1.0, 0.03, 0.1)
		for st in t["bass"]:
			SfxSynth.add_note(buf, RATE, [SfxSynth.TRI, bar_s + int(st) * step_s, step_s * 1.8,
				root - 12, root - 12, 0.4], 1.0, 0.01, step_s)
		for s in 8:
			var off: int = lead[bar * 8 + s]
			var at: float = bar_s + s * step_s
			if off != REST:
				SfxSynth.add_note(buf, RATE, [wave, at, step_s * 0.9, root + 12 + off, root + 12 + off,
					0.22 if wave == SfxSynth.SQUARE else 0.3], 1.0, 0.008, step_s * 0.5)
			if t["drums"] and s % 2 == 1:
				SfxSynth.add_note(buf, RATE, [SfxSynth.NOISE, at, 0.04, 80, 80, 0.12], 1.0, 0.002, 0.03)
	var wav: AudioStreamWAV = SfxSynth.to_stream(buf, RATE, cap, 48)
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = buf.size()
	return wav
