# music autoload
extends Node

@export var timer: Timer
@export var notes_player: AudioStreamPlayer
@export var note_timer_min: float = 4
@export var note_timer_max: float = 8

func play_note():
  if notes_player.playing: return
  notes_player.play()
  print('playing note', Time.get_ticks_msec())

func _on_timer_timeout() -> void:
  timer.wait_time = randf_range(note_timer_min, note_timer_max)
  play_note()
