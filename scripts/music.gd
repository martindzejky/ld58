# music autoload
extends Node

@export var notes_player: AudioStreamPlayer
@export var note_timer_min: float = 1.2
@export var note_timer_max: float = 2.0

func _ready():
  await note_timer()
  play_note()

func note_timer():
  await get_tree().create_timer(randf_range(note_timer_min, note_timer_max)).timeout

func play_note():
  if notes_player.playing: return
  notes_player.play()
  await notes_player.finished
  await note_timer()
  call_deferred('play_note')
