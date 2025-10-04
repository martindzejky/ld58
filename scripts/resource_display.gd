extends Label

var resource_type: ResourceItem.Type

func _ready():
  Game.resource_changed.connect(_on_resource_changed)
  Game.task_completed.connect(_on_task_completed)
  update_text()

func _on_resource_changed(type: ResourceItem.Type):
  if type == resource_type:
    update_text()

func _on_task_completed():
  update_text()

func update_text():
  text = get_resource_name(resource_type) + ': '
  if resource_type in Game.resources:
    text += str(Game.resources[resource_type])
  else:
    text += '0'

  if Game.tasks.size() == 0:
    return

  var current_task = Game.tasks[0]
  match resource_type:
    ResourceItem.Type.WOOD:
      if current_task.wood > 0:
        text += ' / ' + str(current_task.wood)
    ResourceItem.Type.STONE:
      if current_task.stone > 0:
        text += ' / ' + str(current_task.stone)
    ResourceItem.Type.FRUIT:
      if current_task.fruit > 0:
        text += ' / ' + str(current_task.fruit)


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
