class_name Hive extends Node2D

@export var animation_player: AnimationPlayer
@export var collect_sound: AudioStreamPlayer2D
@export var unit_scene: PackedScene

func _enter_tree():
  Game.hive = self

func _exit_tree():
  Game.hive = null

func collect_resource(resource: ResourceItem):
  Game.collect_resource(resource)
  animation_player.play('squish')
  collect_sound.play()
  resource.queue_free()

func spawn_units():
  for i in 2:
    var unit = unit_scene.instantiate()
    get_parent().add_child(unit)
    unit.global_position = global_position + Vector2.DOWN * randf_range(10, 20)
    unit.global_position.x += randf_range(-10, 10)
