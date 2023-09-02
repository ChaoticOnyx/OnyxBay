/datum/map_template/random_room
	var/room_id //UNIQUE SSmapping random_room_template list is ordered by this var
	var/spawned //Whether this template (on the random_room template list) has been spawned
	var/centerspawner = FALSE
	var/template_height = 0
	var/template_width = 0
	var/weight = 10 //weight a room has to appear
	var/stock = 1 //how many times this room can appear in a round

/datum/map_template/random_room/sk_rdm001
	name = "Maintenance Storage"
	room_id = "sk_rdm001_9storage"
	mappaths = list("maps/random_rooms/3x3/sk_rdm001_9storage.dmm")

	template_height = 3
	template_width = 3
	weight = 2

/datum/map_template/random_room/sk_rdm002
	name = "Maintenance Shrine"
	room_id = "sk_rdm002_shrine"
	mappaths = list("maps/random_rooms/3x3/sk_rdm002_shrine.dmm")

	template_height = 3
	template_width = 3
	weight = 2

/datum/map_template/random_room/sk_rdm003
	name = "Maintenance"
	room_id = "sk_rdm003_plasma"
	mappaths = list("maps/random_rooms/3x3/sk_rdm003_plasma.dmm")

	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm004
	name = "Maintenance Tanning Booth"
	room_id = "sk_rdm004_tanning"
	mappaths = list("maps/random_rooms/3x3/sk_rdm004_tanning.dmm")

	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm005
	name = "Maintenance Washroom"
	room_id = "sk_rdm005_wash"
	mappaths = list("maps/random_rooms/3x3/sk_rdm005_wash.dmm")

	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm006
	name = "Maintenance"
	room_id = "sk_rdm006_gibs"
	mappaths = list("maps/random_rooms/3x3/sk_rdm006_gibs.dmm")

	template_height = 3
	template_width = 3
	stock = 2

/datum/map_template/random_room/sk_rdm007
	name = "Maintenance"
	room_id = "sk_rdm007_radspill"
	mappaths = list("maps/random_rooms/3x3/sk_rdm007_radspill.dmm")

	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm008
	name = "Maintenance Storage"
	room_id = "sk_rdm008_2storage"
	mappaths = list("maps/random_rooms/3x3/sk_rdm008_2storage.dmm")

	template_height = 3
	template_width = 3
	stock = 2

/datum/map_template/random_room/sk_rdm009
	name = "Air Refilling Station"
	room_id = "sk_rdm009_airstation"
	mappaths = list("maps/random_rooms/3x3/sk_rdm009_airstation.dmm")

	template_height = 3
	template_width = 3
	stock = 2

/datum/map_template/random_room/sk_rdm010
	name = "Maintenance HAZMAT"
	room_id = "sk_rdm010_hazmat"
	mappaths = list("maps/random_rooms/3x3/sk_rdm010_hazmat.dmm")

	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm013
	name = "Box Kitchen"
	room_id = "sk_rdm013_boxkitchen"
	mappaths = list("maps/random_rooms/3x5/sk_rdm013_boxkitchen.dmm")

	template_height = 5
	template_width = 3

/datum/map_template/random_room/sk_rdm014
	name = "Box Window"
	room_id = "sk_rdm014_boxwindow"
	mappaths = list("maps/random_rooms/3x3/sk_rdm014_boxwindow.dmm")

	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm015
	name = "Box Clutter 1"
	room_id = "sk_rdm015_boxclutter1"
	mappaths = list("maps/random_rooms/5x3/sk_rdm015_boxclutter1.dmm")

	template_height = 3
	template_width = 5
	stock = 2

/datum/map_template/random_room/sk_rdm016
	name = "Box Clutter 2"
	room_id = "sk_rdm016_boxclutter2"
	mappaths = list("maps/random_rooms/3x3/sk_rdm016_boxclutter2.dmm")

	template_height = 3
	template_width = 3
	stock = 2

/datum/map_template/random_room/sk_rdm017
	name = "Box Clutter 3"
	room_id = "sk_rdm017_boxclutter3"
	mappaths = list("maps/random_rooms/3x3/sk_rdm017_boxclutter3.dmm")

	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm018
	name = "Box Clutter 4"
	room_id = "sk_rdm018_boxclutter4"
	mappaths = list("maps/random_rooms/3x3/sk_rdm018_boxclutter4.dmm")

	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm019
	name = "Box Clutter 5"
	room_id = "sk_rdm019_boxclutter5"
	mappaths = list("maps/random_rooms/3x3/sk_rdm019_boxclutter5.dmm")

	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm020
	name = "Box Clutter 6"
	room_id = "sk_rdm020_boxclutter6"
	mappaths = list("maps/random_rooms/3x3/sk_rdm020_boxclutter6.dmm")

	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm022
	name = "Box Chem Closet"
	room_id = "sk_rdm022_boxchemcloset"
	mappaths = list("maps/random_rooms/3x3/sk_rdm022_boxchemcloset.dmm")

	template_height = 3
	template_width = 3
	weight = 7

/datum/map_template/random_room/sk_rdm023
	name = "Box Clutter 7"
	room_id = "sk_rdm023_boxclutter7"
	mappaths = list("maps/random_rooms/3x5/sk_rdm023_boxclutter7.dmm")

	template_height = 5
	template_width = 3
	stock = 2

/datum/map_template/random_room/sk_rdm024
	name = "Box Bedroom"
	room_id = "sk_rdm024_boxbedroom"
	mappaths = list("maps/random_rooms/3x3/sk_rdm024_boxbedroom.dmm")

	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm025
	name = "Box Clutter 8"
	room_id = "sk_rdm025_boxclutter8"
	mappaths = list("maps/random_rooms/3x3/sk_rdm025_boxclutter8.dmm")

	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm028
	name = "Tranquility"
	room_id = "sk_rdm028_tranquility"
	mappaths = list("maps/random_rooms/3x3/sk_rdm028_tranquility.dmm")

	template_height = 3
	template_width = 3
	weight = 1

/datum/map_template/random_room/sk_rdm036
	name = "Delta Owl Office"
	room_id = "sk_rdm036_justiceoffice"
	mappaths = list("maps/random_rooms/3x3/sk_rdm036_justiceoffice.dmm")

	template_height = 3
	template_width = 3
	weight = 7

/datum/map_template/random_room/sk_rdm037
	name = "Delta Janitor Closet"
	room_id = "sk_rdm037_deltajanniecloset"
	mappaths = list("maps/random_rooms/3x3/sk_rdm037_deltajanniecloset.dmm")

	template_height = 3
	template_width = 3
	weight = 8

/datum/map_template/random_room/sk_rdm042
	name = "Delta Clutter 2"
	room_id = "sk_rdm042_deltaclutter2"
	mappaths = list("maps/random_rooms/5x3/sk_rdm042_deltaclutter2.dmm")

	template_height = 3
	template_width = 5

/datum/map_template/random_room/sk_rdm043
	name = "Delta Clutter 3"
	room_id = "sk_rdm043_deltaclutter3"
	mappaths = list("maps/random_rooms/5x3/sk_rdm043_deltaclutter3.dmm")

	template_height = 3
	template_width = 5

/datum/map_template/random_room/sk_rdm044
	name = "Delta Organ Trade"
	room_id = "sk_rdm044_deltaorgantrade"
	mappaths = list("maps/random_rooms/3x3/sk_rdm044_deltaorgantrade.dmm")

	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm050
	name = "Meta Medical Closet"
	room_id = "sk_rdm050_medicloset"
	mappaths = list("maps/random_rooms/3x3/sk_rdm050_medicloset.dmm")

	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm051
	name = "Meta Gamer Gear"
	room_id = "sk_rdm051_metagamergear"
	mappaths = list("maps/random_rooms/3x3/sk_rdm051_metagamergear.dmm")

	template_height = 3
	template_width = 3
	weight = 6

/datum/map_template/random_room/sk_rdm052
	name = "Meta Clutter 1"
	room_id = "sk_rdm052_metaclutter1"
	mappaths = list("maps/random_rooms/5x3/sk_rdm052_metaclutter1.dmm")

	template_height = 3
	template_width = 5
	stock = 2

/datum/map_template/random_room/sk_rdm053
	name = "Meta Clutter 2"
	room_id = "sk_rdm053_metaclutter2"
	mappaths = list("maps/random_rooms/3x3/sk_rdm053_metaclutter2.dmm")

	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm054
	name = "Meta Clutter 3"
	room_id = "sk_rdm054_metaclutter3"
	mappaths = list("maps/random_rooms/5x3/sk_rdm054_metaclutter3.dmm")

	template_height = 3
	template_width = 5

/datum/map_template/random_room/sk_rdm056
	name = "Toys Clutter"
	room_id = "sk_rdm055_toysroom"
	mappaths = list("maps/random_rooms/3x3/sk_rdm055_toysroom.dmm")

	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm056
	name = "Meta Clutter 4"
	room_id = "sk_rdm056_metaclutter4"
	mappaths = list("maps/random_rooms/3x3/sk_rdm056_metaclutter4.dmm")

	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm057
	name = "Pubby Clutter 1"
	room_id = "sk_rdm057_pubbyclutter1"
	mappaths = list("maps/random_rooms/3x3/sk_rdm057_pubbyclutter1.dmm")

	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm058
	name = "Pubby Clutter 2"
	room_id = "sk_rdm058_pubbyclutter2"
	mappaths = list("maps/random_rooms/3x3/sk_rdm058_pubbyclutter2.dmm")

	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm059
	name = "Pubby Clutter 3"
	room_id = "sk_rdm059_pubbyclutter3"
	mappaths = list("maps/random_rooms/3x3/sk_rdm059_pubbyclutter3.dmm")

	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm061
	name = "Pubby Clutter 4"
	room_id = "sk_rdm061_pubbyclutter4"
	mappaths = list("maps/random_rooms/5x3/sk_rdm061_pubbyclutter4.dmm")

	template_height = 3
	template_width = 5

/datum/map_template/random_room/sk_rdm063
	name = "Pubby Clutter 5"
	room_id = "sk_rdm063_pubbyclutter5"
	mappaths = list("maps/random_rooms/3x5/sk_rdm063_pubbyclutter5.dmm")

	template_height = 5
	template_width = 3

/datum/map_template/random_room/sk_rdm064
	name = "Pubby Robotics"
	room_id = "sk_rdm064_pubbyrobotics"
	mappaths = list("maps/random_rooms/3x5/sk_rdm064_pubbyrobotics.dmm")

	template_height = 5
	template_width = 3

/datum/map_template/random_room/sk_rdm065
	name = "Pubby Clutter 6"
	room_id = "sk_rdm065_pubbyclutter6"
	mappaths = list("maps/random_rooms/3x5/sk_rdm065_pubbyclutter6.dmm")

	template_height = 5
	template_width = 3
	stock = 2

/datum/map_template/random_room/sk_rdm068
	name = "Fluff Altar"
	room_id = "sk_rdm068_fluffmaltar"
	mappaths = list("maps/random_rooms/3x3/sk_rdm068_fluffmaltar.dmm")

	template_height = 3
	template_width = 3
	weight = 1

/datum/map_template/random_room/sk_rdm069
	name = "Pubby Art Room"
	room_id = "sk_rdm069_pubbyartism"
	mappaths = list("maps/random_rooms/3x3/sk_rdm069_pubbyartism.dmm")

	template_height = 3
	template_width = 3

datum/map_template/random_room/sk_rdm072 //donut is such a shit map, this was the ONLY room in its maintenance that was suitable.
	name = "Donut Capgun"
	room_id = "sk_rdm072_donutcapgun"
	mappaths = list("maps/random_rooms/3x3/sk_rdm072_donutcapgun.dmm")

	template_height = 3
	template_width = 3
	weight = 6

/datum/map_template/random_room/sk_rdm073
	name = "Kilo Mech Recharger"
	room_id = "sk_rdm073_kilomechcharger"
	mappaths = list("maps/random_rooms/3x3/sk_rdm073_kilomechcharger.dmm")

	template_height = 3
	template_width = 3
	stock = 2

/datum/map_template/random_room/sk_rdm074
	name = "Kilo Theatre"
	room_id = "sk_rdm074_kilotheatre"
	mappaths = list("maps/random_rooms/3x3/sk_rdm074_kilotheatre.dmm")

	template_height = 3
	template_width = 3

/datum/map_template/random_room/sk_rdm077
	name = "Kilo Maid Den"
	room_id = "sk_rdm077_kilolustymaid"
	mappaths = list("maps/random_rooms/3x3/sk_rdm077_kilolustymaid.dmm")

	template_height = 3
	template_width = 3
	weight = 4

/datum/map_template/random_room/sk_rdm079 //comment this out if you want to avoid tiders dying to a simplemob once in awhile
	name = "Kilo Mob Den"
	room_id = "sk_rdm079_kilomobden"
	mappaths = list("maps/random_rooms/3x5/sk_rdm079_kilomobden.dmm")

	template_height = 5
	template_width = 3
	weight = 3
	stock = 2

/datum/map_template/random_room/sk_rdm084
	name = "Monky Paradise"
	room_id = "sk_rdm084_monky"
	mappaths = list("maps/random_rooms/3x5/sk_rdm084_monky.dmm")

	template_height = 5
	template_width = 3
	weight = 4

/datum/map_template/random_room/sk_rdm085
	name = "Hank's Room"
	room_id = "sk_rdm085_hank"
	mappaths = list("maps/random_rooms/3x5/sk_rdm085_hank.dmm")

	template_height = 5
	template_width = 3
	weight = 1

/datum/map_template/random_room/sk_rdm086
	name = "Max Tide's Last Stand"
	room_id = "sk_rdm086_laststand"
	mappaths = list("maps/random_rooms/3x5/sk_rdm086_laststand.dmm")

	template_height = 5
	template_width = 3
	weight = 3

/datum/map_template/random_room/sk_rdm087
	name = "Junk Closet"
	room_id = "sk_rdm087_junkcloset"
	mappaths = list("maps/random_rooms/3x5/sk_rdm087_junkcloset.dmm")

	template_height = 5
	template_width = 3
	stock = 2

/datum/map_template/random_room/sk_rdm092
	name = "Hobo Den"
	room_id = "sk_rdm092_hobohut"
	mappaths = list("maps/random_rooms/3x3/sk_rdm092_hobohut.dmm")

	template_height = 3
	template_width = 3
	weight = 8

/datum/map_template/random_room/sk_rdm093
	name = "Mimic Altar"
	room_id = "sk_rdm093_mimic"
	mappaths = list("maps/random_rooms/3x3/sk_rdm093_mimic.dmm")

	template_height = 3
	template_width = 3
	weight = 1

/datum/map_template/random_room/sk_rdm094
	name = "Canister Room"
	room_id = "sk_rdm094_canisterroom"
	mappaths = list("maps/random_rooms/3x5/sk_rdm094_canisterroom.dmm")

	template_height = 5
	template_width = 3
	stock = 2

/datum/map_template/random_room/sk_rdm095
	name = "Durand Wreck"
	room_id = "sk_rdm095_durandwreck"
	mappaths = list("maps/random_rooms/3x5/sk_rdm095_durandwreck.dmm")

	template_height = 5
	template_width = 3
	weight = 4

/datum/map_template/random_room/sk_rdm108
	name = "dirtycommies"
	room_id = "sk_rdm108_communism"
	mappaths = list("maps/random_rooms/3x3/sk_rdm108_communism.dmm")

	template_height = 3
	template_width = 3
	weight = 8

/datum/map_template/random_room/sk_rdm109
	name = "clown suit"
	room_id = "sk_rdm109_clown"
	mappaths = list("maps/random_rooms/3x3/sk_rdm109_clown.dmm")

	template_height = 3
	template_width = 3
	weight = 1

/datum/map_template/random_room/sk_rdm110
	name = "lipid chamber"
	room_id = "sk_rdm110_lipidchamber"
	mappaths = list("maps/random_rooms/3x3/sk_rdm110_lipidchamber.dmm")

	template_height = 3
	template_width = 3
	weight = 4

/datum/map_template/random_room/sk_rdm111
	name = "bad"
	room_id = "sk_rdm111_naughtyroom"
	mappaths = list("maps/random_rooms/3x3/sk_rdm111_naughtyroom.dmm")

	template_height = 3
	template_width = 3
	weight = 2

/datum/map_template/random_room/sk_rdm113
	name = "organroom"
	room_id = "sk_rdm113_dissection"
	mappaths = list("maps/random_rooms/3x5/sk_rdm113_dissection.dmm")

	template_height = 5
	template_width = 3
	weight = 6

/datum/map_template/random_room/sk_rdm114
	name = "oxygen room"
	room_id = "sk_rdm114_emergencyoxy"
	mappaths = list("maps/random_rooms/3x5/sk_rdm114_emergencyoxy.dmm")

	template_height = 5
	template_width = 3

/datum/map_template/random_room/sk_rdm115
	name = "crab"
	room_id = "sk_rdm115_krebs"
	mappaths = list("maps/random_rooms/3x5/sk_rdm115_krebs.dmm")

	template_height = 5
	template_width = 3
	weight = 1

/datum/map_template/random_room/sk_rdm116
	name = "ore"
	room_id = "sk_rdm116_oreboxes"
	mappaths = list("maps/random_rooms/3x5/sk_rdm116_oreboxes.dmm")

	template_height = 5
	template_width = 3
	weight = 4

/datum/map_template/random_room/sk_rdm137
	name = "Tiny psych ward"
	room_id = "sk_rdm137_tinyshrink"
	mappaths = list("maps/random_rooms/3x5/sk_rdm137_tinyshrink.dmm")

	template_height = 5
	template_width = 3
	weight = 4

/datum/map_template/random_room/sk_rdm140 //this is hilarious
	name = "confusing crossroads"
	room_id = "sk_rdm140_crossroads"
	mappaths = list("maps/random_rooms/3x5/sk_rdm140_crossroads.dmm")

	template_height = 5
	template_width = 3
	weight = 2

/datum/map_template/random_room/sk_rdm158
	name = "Chapel Storage"
	room_id = "sk_rdm158_chapelstorage"
	mappaths = list("maps/random_rooms/3x5/sk_rdm158_kilochapelstorage.dmm")

	template_height = 5
	template_width = 3

/datum/map_template/random_room/sk_rdm160
	name = "Run Down Bar"
	room_id = "sk_rdm160_kilomaintbar"
	mappaths = list("maps/random_rooms/3x5/sk_rdm160_kilomaintbar.dmm")

	template_height = 5
	template_width = 3

/datum/map_template/random_room/sk_rdm162
	name = "Control Room"
	room_id = "sk_rdm162_control_room"
	mappaths = list("maps/random_rooms/3x3/sk_rdm162_control_room.dmm")

	template_height = 3
	template_width = 3
	weight = 6

/datum/map_template/random_room/sk_rdm163 // potentially traumatising
	name = "Corgi Butcher"
	room_id = "sk_rdm163_corgi_butcher"
	mappaths = list("maps/random_rooms/3x3/sk_rdm163_corgi_butcher.dmm")

	template_height = 3
	template_width = 3
	weight = 2

/datum/map_template/random_room/sk_rdm164
	name = "Cornucopia"
	room_id = "sk_rdm164_cornucopia"
	mappaths = list("maps/random_rooms/3x3/sk_rdm164_cornucopia.dmm")

	template_height = 3
	template_width = 3
	weight = 4

/datum/map_template/random_room/sk_rdm165
	name = "Mini Library"
	room_id = "sk_rdm165_library"
	mappaths = list("maps/random_rooms/3x3/sk_rdm165_library.dmm")

	template_height = 3
	template_width = 3
	weight = 4

/datum/map_template/random_room/sk_rdm168
	name = "Offish"
	room_id = "sk_rdm168_offish"
	mappaths = list("maps/random_rooms/3x5/sk_rdm168_offish.dmm")

	template_height = 5
	template_width = 3
	weight = 2
