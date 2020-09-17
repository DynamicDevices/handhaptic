extends Spatial

var arvrinterfacename = "none"
var arvrinterface = null

var ovr_init_config = null
var ovr_performance = null
var ovr_hand_tracking = null

var perform_runtime_config


func checkloadinterface(larvrinterfacename):
	var available_interfaces = ARVRServer.get_interfaces()
	for x in available_interfaces:
		if x["name"] == larvrinterfacename:
			arvrinterface = ARVRServer.find_interface(larvrinterfacename)
			if arvrinterface != null:
				arvrinterfacename = larvrinterfacename
				print("Found VR interface ", x)
				return true
	return false


func _ready():
	print("  Available Interfaces are %s: " % str(ARVRServer.get_interfaces()));
	print("Initializing VR");

	if checkloadinterface("OVRMobile"):
		print("found quest, initializing")
		ovr_init_config = load("res://addons/godot_ovrmobile/OvrInitConfig.gdns").new()
		ovr_performance = load("res://addons/godot_ovrmobile/OvrPerformance.gdns").new()
		ovr_hand_tracking = load("res://addons/godot_ovrmobile/OvrHandTracking.gdns").new();
		perform_runtime_config = false
		ovr_init_config.set_render_target_size_multiplier(1)
		if arvrinterface.initialize():
			get_viewport().arvr = true
			Engine.target_fps = 72
			Engine.iterations_per_second = 72
			print("  Success initializing Quest Interface.")
			$Players/PlayerMe.initovrhandtracking(ovr_hand_tracking)
		else:
			arvrinterface = null

func _process(_delta):
	if !perform_runtime_config and ovr_performance != null:
		ovr_performance.set_clock_levels(1, 1)
		ovr_performance.set_extra_latency_mode(1)
		perform_runtime_config = true
	set_process(false)
