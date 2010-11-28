/datum/data
	var/name = "data"
	var/size = 1.0
	//name = null
/datum/data/function
	name = "function"
	size = 2.0
/datum/data/function/data_control
	name = "data control"
/datum/data/function/id_changer
	name = "id changer"
/datum/data/record
	name = "record"
	size = 5.0

	var/list/fields = list(  )

/datum/data/text
	name = "text"
	var/data = null

/datum/station_state
	var/floor = 0
	var/wall = 0
	var/r_wall = 0
	var/window = 0
	var/door = 0
	var/grille = 0
	var/mach = 0

/datum/debug
	var/list/debuglist