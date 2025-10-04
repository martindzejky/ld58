class_name Hive extends Node2D

# type -> amount
var resources = {}

func _enter_tree():
  Game.hive = self

func _exit_tree():
  Game.hive = null

func collect_resource(resource: ResourceItem):
  resource.queue_free()
  var type = resource.type
  if type in resources:
    resources[type] += resource.amount
  else:
    resources[type] = resource.amount
