tool
extends MeshInstance

func _ready():
	pass

var t = 0
func _process(delta):
	t += delta
	rotation_degrees.z = sin(t)*20
	rotation_degrees.x = sin(0.3*t)*10
