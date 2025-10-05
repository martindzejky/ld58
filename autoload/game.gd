# Game autoload
extends Node

# type -> amount
var resources = {}
signal new_resource(type)
signal resource_changed(type)

var hive: Hive

@export var tasks: Array[Task] = []
signal task_completed(task: Task)

# world radius only ever increases
signal world_radius_changed
var world_radius: float = 100.0:
  get:
    return world_radius
  set(new_radius):
    world_radius = new_radius
    world_radius_changed.emit()

const WORLD_RADIUS_CHANGE_TIME = 2

@export var upgrade_sound: AudioStreamPlayer
@export var reveal_sound: AudioStream

@export var end_screen: PackedScene
@export var upgrades_ui: PackedScene

var active_upgrades: Array[Upgrade.Type] = []
var current_move_speed: float = BASE_MOVE_SPEED
var current_unit_strength: int = BASE_UNIT_STRENGTH
const BASE_MOVE_SPEED = 100.0
const UPGRADE_SPEED_INCREASE = 40.0
const BASE_UNIT_STRENGTH = 1
const UPGRADE_ATTACK_INCREASE = 1

func collect_resource(resource: ResourceItem):
  var type = resource.type
  if type in resources:
    resources[type] += resource.amount
    resource_changed.emit(type)
  else:
    resources[type] = resource.amount
    new_resource.emit(type)
  update_task_completion()

func update_task_completion():
  if tasks.size() == 0:
    return

  var current_task = tasks[0]
  if not check_resource(ResourceItem.Type.WOOD, current_task.wood):
    return
  if not check_resource(ResourceItem.Type.STONE, current_task.stone):
    return
  if not check_resource(ResourceItem.Type.FRUIT, current_task.fruit):
    return
  var completed_task = tasks.pop_front()
  task_completed.emit(completed_task)
  display_upgrades(completed_task)

func display_upgrades(task: Task):
  assert(task.upgrades.size() > 0)
  var upgrades_ui_instance = upgrades_ui.instantiate()
  get_tree().call_group('ui_layer', 'add_child', upgrades_ui_instance)
  for upgrade in task.upgrades:
    var upgrade_instance = upgrade.instantiate()
    upgrades_ui_instance.add_upgrade(upgrade_instance)

func on_choose_upgrade():
  if tasks.size() > 0:
    var tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD)
    tween.tween_property(self, 'world_radius', tasks[0].world_radius, WORLD_RADIUS_CHANGE_TIME)
    upgrade_sound.play()
  else:
    var end_screen_instance = end_screen.instantiate()
    get_tree().call_group('ui_layer', 'add_child', end_screen_instance)

func check_resource(type: ResourceItem.Type, required: int):
  if required <= 0: return true
  if type not in resources: return false
  return resources[type] >= required

func choose_upgrade(upgrade: Upgrade):
  active_upgrades.append(upgrade.type)
  on_choose_upgrade()
  recalculate_active_upgrades()

  if upgrade.type == Upgrade.Type.UNITS:
    hive.spawn_units()

func recalculate_active_upgrades():
  current_move_speed = get_unit_speed()
  current_unit_strength = get_unit_strength()

func get_unit_strength():
  var strength = BASE_UNIT_STRENGTH
  for upgrade in active_upgrades:
    if upgrade == Upgrade.Type.ATTACK:
      strength += UPGRADE_ATTACK_INCREASE
  return strength

func get_unit_speed():
  var speed = BASE_MOVE_SPEED
  for upgrade in active_upgrades:
    if upgrade == Upgrade.Type.SPEED:
      speed += UPGRADE_SPEED_INCREASE
  return speed
