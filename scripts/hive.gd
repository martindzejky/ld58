class_name Hive extends Node2D

@export var animation_player: AnimationPlayer
@export var collect_sound: AudioStreamPlayer2D

func _enter_tree():
  Game.hive = self

func _exit_tree():
  Game.hive = null

func collect_resource(resource: ResourceItem):
  Game.collect_resource(resource)
  animation_player.play('squish')
  collect_sound.play()
  resource.queue_free()
