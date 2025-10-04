extends Control

@export var resource_display: PackedScene

func _ready():
  Game.new_resource.connect(_on_new_resource)

func _on_new_resource(type: ResourceItem.Type):
  var display = resource_display.instantiate()
  display.resource_type = type
  add_child(display)
