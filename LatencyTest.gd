"""
A script to calculate the laggyness of the player's audio and video on their computer.
"""

extends Node

# the lagtime each time
var latencies = []
# to check so the player cant mash it
var already_hit =false

var audio_testing = false
var visual_testing = false



func _ready():
	if audio_testing or visual_testing:
		set_process_input(true)

func _input(event):
	# store when they hit the button
	if event.is_action_pressed("ui_select") and not already_hit:
		latencies.append(get_parent().songposition-get_parent().lastbeat)
		already_hit = true
	if len(latencies)>19:
		latency_sendoff()

func on_beat(beat):
	already_hit =false
# send the lag measurements to conductor, need to save in file
func latency_sendoff():
	var lag = ave_latencies()
	var options = File.new()
	options.open("user://options.save", File.WRITE)
	# need to differentiate between audio and visual in file
	options.store_line(lag.to_json())
	options.close()

func ave_latencies():
	var sum =0.0
	for i in range(0,len(latencies)):
		sum+=latencies[i]
	return sum/len(latencies)
