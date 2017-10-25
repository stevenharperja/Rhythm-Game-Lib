"""
a script to show ConductorScript's effect
"""

extends Sprite

var rotate=false

func _ready():
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_select"):
		rotate=true

func on_beat(beat):
	if(rotate):
		rotate(0.2)
		rotate=false