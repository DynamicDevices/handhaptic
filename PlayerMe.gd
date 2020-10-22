extends ARVROrigin

var ovr_hand_tracking = null

var t = 0.0;
onready var Laser = get_node("/root/Main/BodyObjects/Laser")
onready var doppelganger = get_node("../Doppelganger")


var handrightvalid = false
func handrightbutton_pressed(button):
	print("handrightbutton_pressed ", button)
func handrightbutton_release(button):
	print("handrightbutton_release ", button)

func handleftbutton_pressed(button):
	print("handleftbutton_pressed ", button)
	if button == 7 and $HandRight.handvalid:
		print("::::")
		print("  ", var2str($HandRight.hand_boneorientations))
		print("----")
		
func handleftbutton_release(button):
	print("handleftbutton_release ", button)

func _ready():
	$HandRightController.connect("button_pressed", self, "handrightbutton_pressed")
	$HandRightController.connect("button_release", self, "handrightbutton_release")
	$HandLeftController.connect("button_pressed", self, "handleftbutton_pressed")
	$HandLeftController.connect("button_release", self, "handleftbutton_release")


func initovrhandtracking(lovr_hand_tracking):
	ovr_hand_tracking = lovr_hand_tracking
	$HandLeft.initovrhandtracking(ovr_hand_tracking, $HandLeftController)
	$HandRight.initovrhandtracking(ovr_hand_tracking, $HandRightController)
	$HandLeft.addremotetransform("index_null", get_node("/root/Main/BodyObjects/Finger1"))
	$HandLeft.addremotetransform("thumb_null", get_node("/root/Main/BodyObjects/Finger3"))
	$HandLeft.addremotetransform("pinky_null", get_node("/root/Main/BodyObjects/Finger4"))
		
func _process(delta):
	if ovr_hand_tracking != null:
		$HandLeft.process_ovrhandtracking(delta)
		$HandRight.process_ovrhandtracking(delta)
		if $HandRight.handvalid != handrightvalid:
			handrightvalid = $HandRight.handvalid
			print("handrightvalid: ", $HandRight.handvalid) 
		var dhandright = doppelganger.get_node("HandRight")
		dhandright.handvalid = $HandRight.handvalid
		dhandright.handmodel.transform = $HandRight.handmodel.transform
		dhandright.hand_boneorientations = $HandRight.hand_boneorientations.duplicate()
		dhandright.update_handpose(delta)
	
func _input(event):
	if event is InputEventKey:
		var dhandright = $HandRight # doppelganger.get_node("HandRight")
		var ho = null
		if event.pressed and event.scancode == KEY_0:
			ho = $HandRight.handokay00
		if event.pressed and event.scancode == KEY_1:
			ho = $HandRight.handokay10
		if event.pressed and event.scancode == KEY_2:
			ho = $HandRight.handokay01
		if event.pressed and event.scancode == KEY_3:
			ho = $HandRight.handokay11
		if ho != null:
			$HandRight.handposeimmediate(ho, 200)
			
