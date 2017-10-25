"""
The root of all the rhythm in the level. intended to be one conductorscript version per level
just with different songs.
"""

extends StreamPlayer

# songposition (not streamplayer position)
var songposition=0
# opus have metadata which makes them start late? also this song might have blank space at beginning
var offset=2.5 +0
# bpm of the song, how do you not know what this is? look it up ya dumbo
var bpm= 155.0
# duration of a beat (otherwise known as crotchet)
var beatduration = 0.0
# time of last beat
var lastbeat = 0.0
# what actual beat are we on?
var beat = 0

# time taken for audio to be outputted to system. typically less than visual. to be obtained from LatencyTest.gd
var audio_lag  = 0.0
# time taken for video to be outputted to system. to be obtained from LatencyTest.gd
var visual_lag =  0.0
# time between audio and visual
var difference_lag = visual_lag - audio_lag
# a delay to compensate for players being a little behind. 0.05 good? to be inputted by game dev
var input_delay = 0.0

func _ready():
	## to test LagMeasure
	# get_tree().change_scene("res://LagMeasure.tscn")
	
	# set beatduration to its duration in seconds
	beatduration = 60.0/bpm
	play(2.5)
	set_process(true)

func _process(delta):
	songposition = get_pos() - offset
	
	if(songposition>lastbeat+beatduration): 
		# audio is the root of all sync so it has no alterations. it happens after visual, codewise
		beat+=1
		output_audio()
	if(songposition>lastbeat+beatduration-difference_lag): 
		# visual is a bit slower so make it earlier by its difference with audio. this happens first
		output_visual()
	if(songposition>lastbeat+beatduration+input_delay+audio_lag):
		"""
		a beat function for inputs. used to check if player hit it on time
		its behind because audio lag and for input delay because of inconsistency in players hits.
		
		"""
		output_player()
		# start the next beat here because this function goes last
		lastbeat+=beatduration 
		"""
		Could do 'lastbeat = songposition - (songposition % beatduration)'
		instead if you have problems with beats being skipped due to lag or something
		in which the beats catch up all at once when lag stops.
		If you do the beat incrementer might need to be changed.
		"""
	
	# testing stuff
	get_node("Songposition").set_text(str(songposition))
	get_node("beat").set_text(str(beat))

func output_audio():
	"""
	activate all the child nodes if they have the on_beat_visual method.
	use it for your audios. this function happens second of the three
	"""
	for node in get_children():
		if(node.has_method("on_beat_audio")):
			node.on_beat_audio(beat)

func output_visual():
	"""
	activate all the child nodes if they have the on_beat_visual method.
	use it for your visuals as they will be lagged otherwise. his function happens first of the three
	"""
	for node in get_children():
		if(node.has_method("on_beat_visual")):
			node.on_beat_visual(beat)

func output_player():
	"""
	activate all the child nodes if they have the on_beat_player method.
	use it for your playerclass to check if their hit is on beat. (it'll be behind  on stuff codewise
	but hopefully it will feel in sync
	his function happens third of the three
	"""
	for node in get_children():
		if(node.has_method("on_beat_player")): # ***how do i parse a string so i can combine these functions? ***
			node.on_beat_player(beat)

func load_options():
	var options = File.new()
	if !options.file_exists("user://options.save"):
		return(0)
	var currentline = {}
	options.open("user://options.save", File.READ)
	while (!options.eof_reached()):
		