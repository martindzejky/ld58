class_name Unit extends Node2D

enum State {
  IDLE, # idle is a decision point
  WANDERING,
  MOVING_TO_COMMAND,
  MOVING_TO_HIVE,
  PERFORMING_JOB
}

var state: State = State.IDLE
var target: Node2D
var current_job: Command.Job

@export var debug_label: Label
@export var flip_node: Node2D
var last_position: Vector2

@export var wander_timer: Timer
const MIN_WANDER_TIME = 2.0
const MAX_WANDER_TIME = 3.0
@export var wander_position_timer: Timer
@onready var wander_position: Vector2 = global_position
const MIN_WANDER_POSITION_TIME = 2.0
const MAX_WANDER_POSITION_TIME = 4.0
const MAX_WANDER_POSITION_DISTANCE = 50.0

const MOVE_SPEED = 100.0
const REACHED_TARGET_DISTANCE = 10.0
const REACHED_TARGET_COMMAND_DISTANCE = 30.0

@export var attack_cooldown_timer: Timer
@export var sleep_timer: Timer
@export var haul_slot: Marker2D

@export var animation_player: AnimationPlayer
@export var squish_animation_player: AnimationPlayer

func _process(delta: float) -> void:
  var direction = global_position - last_position
  if direction.length() > 0:
    flip_node.scale.x = sign(direction.x)
  last_position = global_position

  if not sleep_timer.is_stopped():
    debug_label.text = 'SLEEPING'
    play_animation('idle')
    return

  match state:
    State.IDLE:
      debug_label.text = 'IDLE'
      idle_state()
    State.WANDERING:
      debug_label.text = 'WANDERING'
      wandering_state(delta)
    State.MOVING_TO_COMMAND:
      debug_label.text = 'MOVING_TO_COMMAND'
      moving_to_command_state(delta)
    State.MOVING_TO_HIVE:
      debug_label.text = 'MOVING_TO_HIVE'
      moving_to_hive_state(delta)
    State.PERFORMING_JOB:
      debug_label.text = 'PERFORMING_JOB'
      performing_job_state(delta)

func idle_state():
  play_animation('idle')
  var available_commands = get_tree().get_nodes_in_group('command')
  if available_commands.size() == 0:
    state = State.WANDERING
    wander_timer.start(randf_range(MIN_WANDER_TIME, MAX_WANDER_TIME))
    return
  target = available_commands.pick_random()
  state = State.MOVING_TO_COMMAND

func wandering_state(delta: float):
  if move_to_position(delta, wander_position):
    play_animation('idle')
  else:
    play_animation('run')

func moving_to_command_state(delta: float):
  if not target or not target is Command:
    state = State.MOVING_TO_HIVE
    target = Game.hive
    return

  var reached = move_to_target(delta)
  if not reached:
    play_animation('run')
    return

  var available = target.get_available_jobs()

  if available.size() == 0:
    sleep_timer.start(randf_range(0.5, 1.0))
    state = State.MOVING_TO_HIVE
    target = Game.hive
    return

  current_job = available.pick_random()
  current_job.workers.append(self)
  current_job.cancelled.connect(_on_job_cancelled)
  current_job.completed.connect(_on_job_completed)
  state = State.PERFORMING_JOB

func moving_to_hive_state(delta: float):
  if not target:
    target = Game.hive

  var reached = move_to_target(delta)
  if not reached:
    play_animation('run')
    return

  if is_carrying_item():
    var item = haul_slot.get_child(0)
    Game.hive.collect_resource(item)
  state = State.IDLE
  sleep_timer.start(randf_range(0.2, 0.5))

func performing_job_state(delta: float):
  if not current_job:
    state = State.MOVING_TO_HIVE
    target = Game.hive
    return

  if not current_job.target:
    current_job.cancelled.disconnect(_on_job_cancelled)
    current_job.completed.disconnect(_on_job_completed)
    current_job.completed.emit()
    sleep_timer.start(randf_range(0.2, 0.5))
    # find a new job from the same command
    # TODO: there's an edge case: if we just destroyed a resource which spawned resource items, these will not have jobs registered yet
    if current_job.command:
      var available = current_job.command.get_available_jobs()
      if available.size() > 0:
        current_job = available.pick_random()
        current_job.workers.append(self)
        current_job.cancelled.connect(_on_job_cancelled)
        current_job.completed.connect(_on_job_completed)
      else:
        current_job = null
        state = State.MOVING_TO_HIVE
        target = Game.hive
        return
    else:
      current_job = null
      state = State.MOVING_TO_HIVE
      target = Game.hive
      return

  var reached = move_to_position(delta, current_job.target.global_position)
  if not reached:
    play_animation('run')
    return

  interact_with_job_target()

func is_carrying_item() -> bool:
  return haul_slot.get_child_count() > 0

func interact_with_job_target():
  if not current_job or not current_job.target:
    current_job = null
    state = State.MOVING_TO_HIVE
    target = Game.hive
    return

  if current_job.target is ResourceObject:
    if attack_cooldown_timer.is_stopped():
      attack_cooldown_timer.start()
      current_job.target.take_damage(1) # TODO: this will be upgradable
      play_animation('attack')
    return

  if current_job.target is ResourceItem:
    if is_carrying_item():
      state = State.MOVING_TO_HIVE
      target = Game.hive
      return

    current_job.target.pickup()
    current_job.target.reparent(haul_slot)
    current_job.target.position = Vector2.ZERO
    # complete the job immediately and remove it from command
    current_job.cancelled.disconnect(_on_job_cancelled)
    current_job.completed.disconnect(_on_job_completed)
    current_job.completed.emit()
    current_job = null
    target = Game.hive
    state = State.MOVING_TO_HIVE
    return

  # fallback
  current_job = null
  state = State.MOVING_TO_HIVE
  target = Game.hive

func _on_wander_timer_timeout():
  state = State.IDLE

func move_to_target(delta: float):
  return move_to_position(delta, target.global_position)

func move_to_position(delta: float, target_position: Vector2):
  # TODO: simple flocking behavior
  var direction = target_position - global_position
  var distance = direction.length()
  if state == State.MOVING_TO_COMMAND:
    if distance < REACHED_TARGET_COMMAND_DISTANCE:
      return true
  if distance < REACHED_TARGET_DISTANCE:
    return true
  else:
    global_position += direction.normalized() * MOVE_SPEED * delta
    return false

func _on_wander_position_timer_timeout() -> void:
  wander_position = global_position + Vector2.UP.rotated(randf_range(0, 2 * PI)) * randf_range(0, MAX_WANDER_POSITION_DISTANCE)
  wander_position_timer.wait_time = randf_range(MIN_WANDER_POSITION_TIME, MAX_WANDER_POSITION_TIME)

func _on_job_cancelled():
  if not current_job:
    return

  current_job.cancelled.disconnect(_on_job_cancelled)
  current_job.completed.disconnect(_on_job_completed)
  current_job = null
  state = State.MOVING_TO_HIVE
  target = Game.hive

func _on_job_completed():
  if not current_job:
    return

  current_job.cancelled.disconnect(_on_job_cancelled)
  current_job.completed.disconnect(_on_job_completed)

  # pick a new job from the same command, someone else completed this job
  if current_job.command:
    var available = current_job.command.get_available_jobs()
    if available.size() > 0:
      current_job = available.pick_random()
      current_job.workers.append(self)
      current_job.cancelled.connect(_on_job_cancelled)
      current_job.completed.connect(_on_job_completed)
    else:
      current_job = null
      state = State.MOVING_TO_HIVE
      target = Game.hive
      return
  else:
    current_job = null
    state = State.MOVING_TO_HIVE
    target = Game.hive
    return

func play_animation(animation_name: String):
  if animation_name == 'run' and is_carrying_item():
    animation_name = 'carry_run'
  animation_player.play(animation_name)
