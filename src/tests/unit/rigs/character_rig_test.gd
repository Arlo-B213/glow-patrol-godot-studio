extends GdUnitTestSuite
## Rig data validity, key sampling and runtime playback for CharacterRig.

const CharacterRig := preload("res://scripts/rigs/character_rig.gd")
const HaeRigData := preload("res://scripts/rigs/hae_rig_data.gd")
const NunRigData := preload("res://scripts/rigs/nun_rig_data.gd")
const BitRigData := preload("res://scripts/rigs/bit_rig_data.gd")
const JunoRigData := preload("res://scripts/rigs/juno_rig_data.gd")
const PearlRigData := preload("res://scripts/rigs/pearl_rig_data.gd")
const BreakerRigData := preload("res://scripts/rigs/breaker_rig_data.gd")
const RigLibrary := preload("res://scripts/rigs/rig_library.gd")

var rig: CharacterRig = null


func after_test() -> void:
	if rig != null:
		rig.free()
		rig = null


func test_hae_rig_data_is_valid() -> void:
	# Arrange
	var data := HaeRigData.rig()
	var anims := HaeRigData.animations()
	# Act
	var problems := CharacterRig.validate(data, anims)
	# Assert
	assert_int(problems.size()).is_equal(0)


func test_every_hae_and_nun_part_image_exists() -> void:
	# Arrange / Act / Assert
	for rig_data: Dictionary in [HaeRigData.rig(), NunRigData.rig(), BitRigData.rig(), JunoRigData.rig(), PearlRigData.rig(), BreakerRigData.rig()]:
		for bone: Dictionary in rig_data["bones"]:
			var path := "res://assets/art/characters/%s/parts/%s.png" % [rig_data["id"], bone["part"]]
			assert_bool(ResourceLoader.exists(path)).is_true()


func test_nun_rig_data_is_valid() -> void:
	# Arrange
	var data := NunRigData.rig()
	var anims := NunRigData.animations()
	# Act
	var problems := CharacterRig.validate(data, anims)
	# Assert
	assert_int(problems.size()).is_equal(0)


func test_bit_rig_data_is_valid() -> void:
	# Arrange
	var data := BitRigData.rig()
	var anims := BitRigData.animations()
	# Act
	var problems := CharacterRig.validate(data, anims)
	# Assert
	assert_int(problems.size()).is_equal(0)


func test_juno_rig_data_is_valid() -> void:
	# Arrange
	var data := JunoRigData.rig()
	var anims := JunoRigData.animations()
	# Act
	var problems := CharacterRig.validate(data, anims)
	# Assert
	assert_int(problems.size()).is_equal(0)


func test_pearl_rig_data_is_valid() -> void:
	# Arrange
	var data := PearlRigData.rig()
	var anims := PearlRigData.animations()
	# Act
	var problems := CharacterRig.validate(data, anims)
	# Assert
	assert_int(problems.size()).is_equal(0)


func test_breaker_rig_data_is_valid() -> void:
	# Arrange
	var data := BreakerRigData.rig()
	var anims := BreakerRigData.animations()
	# Act
	var problems := CharacterRig.validate(data, anims)
	# Assert
	assert_int(problems.size()).is_equal(0)


func test_rig_library_has_hae_nun_bit_juno_and_pearl() -> void:
	# Arrange / Act / Assert
	assert_bool(RigLibrary.has_rig("hae")).is_true()
	assert_bool(RigLibrary.has_rig("nun")).is_true()
	assert_bool(RigLibrary.has_rig("bit")).is_true()
	assert_bool(RigLibrary.has_rig("juno")).is_true()
	assert_bool(RigLibrary.has_rig("pearl")).is_true()
	assert_bool(RigLibrary.has_rig("moonbun")).is_false()


func test_validate_reports_bone_listed_before_parent() -> void:
	# Arrange
	var data := {"id": "x", "bones": [
		{"name": "child", "parent": "parent", "pivot": [0, 0]},
		{"name": "parent", "parent": "", "pivot": [0, 0]},
	]}
	# Act
	var problems := CharacterRig.validate(data, {})
	# Assert
	assert_int(problems.size()).is_greater(0)


func test_validate_reports_unknown_bone_in_track() -> void:
	# Arrange
	var data := {"id": "x", "bones": [{"name": "body", "parent": "", "pivot": [0, 0]}]}
	var anims := {"idle": {"duration": 1.0, "loop": true, "tracks": {"ghost": {"rot": [0, 1]}}}}
	# Act
	var problems := CharacterRig.validate(data, anims)
	# Assert
	assert_int(problems.size()).is_greater(0)


func test_looping_sample_wraps_back_to_first_key() -> void:
	# Arrange / Act
	var at_start := CharacterRig._sample([0, -4, 0], 0.0, true)
	var at_one_third := CharacterRig._sample([0, -4, 0], 1.0 / 3.0, true)
	var at_end := CharacterRig._sample([0, -4, 0], 1.0, true)
	# Assert
	assert_float(at_start).is_equal_approx(0.0, 0.001)
	assert_float(at_one_third).is_equal_approx(-4.0, 0.001)
	assert_float(at_end).is_equal_approx(0.0, 0.001)


func test_one_shot_sample_holds_last_key() -> void:
	# Arrange / Act
	var at_end := CharacterRig._sample([0, 10, 5], 1.0, false)
	# Assert
	assert_float(at_end).is_equal_approx(5.0, 0.001)


func test_play_unknown_animation_is_ignored() -> void:
	# Arrange
	rig = CharacterRig.new()
	rig.setup(HaeRigData.rig(), HaeRigData.animations())
	# Act
	rig.play("does_not_exist")
	# Assert
	assert_str(rig.current()).is_equal("")


func test_setup_builds_every_bone_and_part() -> void:
	# Arrange / Act
	rig = CharacterRig.new()
	rig.setup(HaeRigData.rig(), HaeRigData.animations())
	# Assert
	assert_int(rig.bone_names().size()).is_equal(HaeRigData.rig()["bones"].size())
	assert_object(rig.find_child("head", true, false)).is_not_null()


func test_cheer_raises_the_back_arm_while_playing() -> void:
	# Arrange
	rig = CharacterRig.new()
	rig.setup(HaeRigData.rig(), HaeRigData.animations())
	rig.play("cheer")
	# Act
	rig._process(0.3)
	var arm: Node2D = rig.find_child("arm_back_right", true, false)
	# Assert
	assert_float(arm.rotation_degrees).is_less(-45.0)
	assert_float(arm.rotation_degrees).is_greater(-65.0)


func test_one_shot_finishes_and_holds_its_last_pose() -> void:
	# Arrange
	rig = CharacterRig.new()
	rig.setup(HaeRigData.rig(), HaeRigData.animations())
	rig.play("hurt")
	# Act
	rig._process(5.0)
	var head: Node2D = rig.find_child("head", true, false)
	# Assert
	assert_str(rig.current()).is_equal("hurt")
	assert_float(head.rotation_degrees).is_equal_approx(0.0, 0.001)
