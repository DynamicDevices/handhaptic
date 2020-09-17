extends Spatial



# Called when the node enters the scene tree for the first time.
func _ready():
	#$HissSound.play()
	#inbodyshape = true
	pass
	
var col1 = Color("#17256f")
var col2 = Color("#ee256f")
var inbodyshape = false


func _on_Area_body_shape_entered(body_id, body, body_shape, area_shape):
	print("_on_Area_body_shape_entered", [body_id, body, body_shape, area_shape])
	$Finger1/Area/CollisionShape/MeshInstance.get_surface_material(0).albedo_color = col2
	if not body.get_parent().get_name() == "Rope":
		$ClickSound.global_transform.origin = $Finger1.global_transform.origin
		$ClickSound.play()
		$HissSound.global_transform.origin = $Finger1.global_transform.origin
		$HissSound.play()
		inbodyshape = true
	
func _on_Area_body_shape_exited(body_id, body, body_shape, area_shape):
	print("   _on_Area_body_shape_exited", [body_id, body, body_shape, area_shape])
	$Finger1/Area/CollisionShape/MeshInstance.get_surface_material(0).albedo_color = col1
	$HissSound.stop()
	inbodyshape = false

func _on_HissSound_finished():
	if inbodyshape:
		$HissSound.play()

var tt = 0
var prevfingerpos = Vector3(0,0,0)
func _physics_process(delta):
	var fingertrans = $Finger1.global_transform
	var vel = (fingertrans.origin - prevfingerpos)/delta
	$Finger1Kinematic.global_transform = fingertrans
	var nvel = $Finger1Kinematic.move_and_slide(vel)
	prevfingerpos = fingertrans.origin

	tt += delta
	if tt > 4:
		print(vel, nvel)	
		tt = 0
	
