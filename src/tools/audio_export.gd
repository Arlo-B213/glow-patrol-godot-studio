extends SceneTree
## Writes every synthesized SFX and music track to a 16-bit mono WAV so a person can listen to them.
## Uses the same rates and peaks as the Sfx autoload. Run headless:
##   godot --headless --path src -s res://tools/audio_export.gd -- <out_dir>

const SFX_RATE := 16000
const SFX_PEAK := 0.6
const SfxSynthRef := preload("res://scripts/sfx_synth.gd")
const MusicRef := preload("res://scripts/music_tracks.gd")
const SFX_IDS := ["tap", "back", "punch", "hit", "enemy_defeat", "boss_hit", "star", "coin", "level_up",
	"high_five", "chapter", "win", "lose", "eat", "pet_happy", "grow", "error", "whoosh", "correct", "wrong"]
const TRACK_IDS := ["hq", "battle", "games", "study", "club", "pets", "story", "win"]


func _init() -> void:
	var out_dir: String = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(out_dir)
	for id in SFX_IDS:
		var s: AudioStreamWAV = SfxSynthRef.render_sfx(id, SFX_RATE, SFX_PEAK)
		_write(s, out_dir.path_join("sfx-%s.wav" % id))
	for id in TRACK_IDS:
		var m: AudioStreamWAV = MusicRef.render(id)
		_write(m, out_dir.path_join("music-%s.wav" % id))
	print("DONE wrote ", SFX_IDS.size() + TRACK_IDS.size(), " files to ", out_dir)
	quit()


func _write(s: AudioStreamWAV, path: String) -> void:
	var pcm: PackedByteArray = s.data
	var rate: int = s.mix_rate
	var hdr := PackedByteArray()
	hdr.resize(44)
	hdr.encode_u8(0, 0x52); hdr.encode_u8(1, 0x49); hdr.encode_u8(2, 0x46); hdr.encode_u8(3, 0x46)  # RIFF
	hdr.encode_u32(4, 36 + pcm.size())
	hdr.encode_u8(8, 0x57); hdr.encode_u8(9, 0x41); hdr.encode_u8(10, 0x56); hdr.encode_u8(11, 0x45)  # WAVE
	hdr.encode_u8(12, 0x66); hdr.encode_u8(13, 0x6d); hdr.encode_u8(14, 0x74); hdr.encode_u8(15, 0x20)  # fmt
	hdr.encode_u32(16, 16)
	hdr.encode_u16(20, 1)        # PCM
	hdr.encode_u16(22, 1)        # mono
	hdr.encode_u32(24, rate)
	hdr.encode_u32(28, rate * 2)
	hdr.encode_u16(32, 2)
	hdr.encode_u16(34, 16)
	hdr.encode_u8(36, 0x64); hdr.encode_u8(37, 0x61); hdr.encode_u8(38, 0x74); hdr.encode_u8(39, 0x61)  # data
	hdr.encode_u32(40, pcm.size())
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_buffer(hdr)
	f.store_buffer(pcm)
	f.close()
