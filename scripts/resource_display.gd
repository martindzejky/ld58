extends HBoxContainer

@export var icon: TextureRect
@export var amount: Label
@export var notification: TextureRect

@export var wood_icon: Texture2D
@export var stone_icon: Texture2D
@export var fruit_icon: Texture2D
@export var notification_warning: Texture2D
@export var notification_done: Texture2D

var resource_type: ResourceItem.Type

func _ready():
  Game.resource_changed.connect(_on_resource_changed)
  Game.task_completed.connect(_on_task_completed)
  update_text()

func _on_resource_changed(type: ResourceItem.Type):
  if type == resource_type:
    update_text()

func _on_task_completed(_task):
  update_text()

func update_text():
  icon.texture = get_resource_icon(resource_type)
  amount.text = ''
  if resource_type in Game.resources:
    amount.text += str(Game.resources[resource_type])
  else:
    amount.text += '0'

  if Game.tasks.size() == 0:
    return

  var current_task = Game.tasks[0]
  match resource_type:
    ResourceItem.Type.WOOD:
      update_notification(current_task.wood)
      if current_task.wood > 0:
        amount.text += '/' + str(current_task.wood)
    ResourceItem.Type.STONE:
      update_notification(current_task.stone)
      if current_task.stone > 0:
        amount.text += '/' + str(current_task.stone)
    ResourceItem.Type.FRUIT:
      update_notification(current_task.fruit)
      if current_task.fruit > 0:
        amount.text += '/' + str(current_task.fruit)

func update_notification(required: int):
  if required <= 0:
    notification.texture = null
    return

  var amount = 0
  if resource_type in Game.resources:
    amount = Game.resources[resource_type]

  if amount < required:
    notification.texture = notification_warning
  else:
    notification.texture = notification_done

func get_resource_icon(type: ResourceItem.Type):
  match type:
    ResourceItem.Type.WOOD:
      return wood_icon
    ResourceItem.Type.STONE:
      return stone_icon
    ResourceItem.Type.FRUIT:
      return fruit_icon
    _:
      return null
