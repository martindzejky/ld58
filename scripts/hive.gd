class_name Hive extends Node2D


func _enter_tree():
  Game.hive = self

func _exit_tree():
  Game.hive = null

func collect_resource(resource: ResourceItem):
  Game.collect_resource(resource)
  resource.queue_free()
