extends Label

var resource_type: ResourceItem.Type

func _ready():
  Game.resource_changed.connect(_on_resource_changed)

func _on_resource_changed(type: ResourceItem.Type):
  if type == resource_type:
    text = get_resource_name(type) + ': ' + str(Game.resources[type])

func get_resource_name(type: ResourceItem.Type):
  match type:
    ResourceItem.Type.WOOD:
      return 'Wood'
    ResourceItem.Type.STONE:
      return 'Stone'
    ResourceItem.Type.FRUIT:
      return 'Fruit'
    _:
      return 'Unknown'
