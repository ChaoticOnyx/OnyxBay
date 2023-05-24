/datum/map_template/random_room
	var/room_id //UNIQUE SSmapping random_room_template list is ordered by this var
	var/spawned //Whether this template (on the random_room template list) has been spawned
	var/centerspawner = TRUE
	var/template_height = 0
	var/template_width = 0
	var/weight = 10 //weight a room has to appear
	var/stock = 1 //how many times this room can appear in a round

/datum/map_template/random_room/sk_rdm001
	name = "Maintenance Storage"
	room_id = "sk_rdm001_9storage"
	mappaths = list("maps/random_rooms/3x3/sk_rdm001_9storage.dmm")
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 2

/datum/map_template/random_room/sk_rdm002
	name = "Maintenance Shrine"
	room_id = "sk_rdm002_shrine"
	mappaths = list("maps/random_rooms/3x3/sk_rdm002_shrine.dmm")
	centerspawner = FALSE
	template_height = 3
	template_width = 3
	weight = 2

/datum/map_template/random_room/sk_rdm003
	name = "Maintenance"
	room_id = "sk_rdm003_plasma"
	mappaths = list("maps/random_rooms/3x3/sk_rdm003_plasma.dmm")
	centerspawner = FALSE
	template_height = 3
	template_width = 3
