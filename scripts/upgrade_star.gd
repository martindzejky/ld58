extends TextureRect

func _ready():
  pivot_offset = size / 2

func _process(delta: float):
  rotation += delta
