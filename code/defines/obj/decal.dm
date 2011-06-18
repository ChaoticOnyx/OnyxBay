/obj/decal/ash
	name = "Ashes"
	desc = "Ashes to ashes, dust to dust."
	icon = 'objects.dmi'
	icon_state = "ash"
	anchored = 1

/obj/decal/point
	name = "point"
	icon = 'screen1.dmi'
	icon_state = "arrow"
	layer = 16.0
	anchored = 1

/obj/decal/cleanable
	var/list/random_icon_states = list()

/obj/decal/cleanable/blood
	name = "blood"
	desc = "It's red."
	density = 0
	anchored = 1
	layer = 2
	icon = 'blood.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	var/datum/disease/virus = null
	var/datum/disease2/virus2 = null
	blood_DNA = null
	blood_type = null
	var/mob/blood_owner = null
/obj/decal/cleanable/blood/drip
	name = "drips of blood"
	desc = "It's red."
	density = 0
	anchored = 1
	layer = 2
	icon = 'drip.dmi'
	icon_state = "1"
	blood_DNA = null
	blood_type = null
/obj/decal/cleanable/blood/splatter
	random_icon_states = list("gibbl1", "gibbl2", "gibbl3", "gibbl4", "gibbl5")

/obj/decal/cleanable/blood/tracks
	icon_state = "tracks"
	random_icon_states = null

/obj/decal/cleanable/blood/gibs
	name = "gibs"
	desc = "Grisly..."
	density = 0
	anchored = 0
	layer = 2
	icon = 'blood.dmi'
	icon_state = "gibbl5"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6")

/obj/decal/cleanable/blood/gibs/body
	random_icon_states = list("gibhead", "gibtorso")

/obj/decal/cleanable/blood/gibs/limb
	random_icon_states = list("gibleg", "gibarm")

/obj/decal/cleanable/blood/gibs/core
	random_icon_states = list("gibmid1", "gibmid2", "gibmid3")

/obj/decal/cleanable/robot_debris
	name = "robot debris"
	desc = "Useless heap of junk."
	density = 0
	anchored = 0
	layer = 2
	icon = 'robots.dmi'
	icon_state = "gib1"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gib7")

/obj/decal/cleanable/robot_debris/limb
	random_icon_states = list("gibarm", "gibleg")

/obj/decal/cleanable/oil
	name = "motor oil"
	desc = "It's black."
	density = 0
	anchored = 1
	layer = 2
	icon = 'oil.dmi'
	icon_state = "floor1"
	var/datum/disease/virus = null
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")

/obj/decal/cleanable/oil/streak
	random_icon_states = list("streak1", "streak2", "streak3", "streak4", "streak5")

/obj/decal/cleanable/generic
	name = "clutter"
	desc = "Someone should clean that up."
	density = 0
	anchored = 1
	layer = 2
	icon = 'objects.dmi'
	icon_state = "shards"

/obj/decal/cleanable/dirt
	name = "dirt"
	desc = "Someone should clean that up."
	density = 0
	anchored = 1
	layer = 2
	icon = 'old_or_unused.dmi'
	icon_state = "dirt"

/obj/decal/cleanable/greenglow
	name = "green glow"
	desc = "Eerie."
	density = 0
	anchored = 1
	layer = 2
	icon = 'effects.dmi'
	icon_state = "greenglow"

/obj/decal/cleanable/cobweb
	name = "cobweb"
	desc = "Someone should remove that."
	density = 0
	anchored = 1
	layer = 3
	icon = 'old_or_unused.dmi'
	icon_state = "cobweb1"

/obj/decal/cleanable/molten_item
	name = "gooey grey mass"
	desc = "huh."
	density = 0
	anchored = 1
	layer = 3
	icon = 'chemical.dmi'
	icon_state = "molten"

/obj/decal/cleanable/cobweb2
	name = "cobweb"
	desc = "Someone should remove that."
	density = 0
	anchored = 1
	layer = 3
	icon = 'old_or_unused.dmi'
	icon_state = "cobweb2"
/obj/decal/cleanable/water
	name = "a pool of water"
	desc = "Someone could get hurt that."
	density = 0
	anchored = 1
	layer = 3
	icon = 'water.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2")
/obj/decal/sign
	icon = 'decals.dmi'
	anchored = 1.0
	opacity = 0
	density = 0

/obj/decal/sign/bio
	desc = "A warning sign which reads 'BIO HAZARD'"
	name = "BIO HAZARD"
	icon_state = "bio"

/obj/decal/sign/deck1
	desc = "A silver sign which reads 'DECK I'"
	name = "DECK I"
	icon_state = "deck1"

/obj/decal/sign/deck2
	desc = "A silver sign which reads 'DECK II'"
	name = "DECK II"
	icon_state = "deck2"

/obj/decal/sign/deck3
	desc = "A silver sign which reads 'DECK III'"
	name = "DECK III"
	icon_state = "deck3"

/obj/decal/sign/deck4
	desc = "A silver sign which reads 'DECK IV'"
	name = "DECK IV"
	icon_state = "deck4"

/obj/decal/sign/electrical
	desc = "A warning sign which reads 'ELECTRICAL HAZARD'"
	name = "ELECTRICAL HAZARD"
	icon_state = "shock"

/obj/decal/sign/flammable
	desc = "A warning sign which reads 'FLAMMABLE AREA'"
	name = "FLAMMABLE AREA"
	icon_state = "fire"

/obj/decal/sign/nosmoking
	desc = "A warning sign which reads 'NO SMOKING'"
	name = "NO SMOKING"
	icon_state = "nosmoking"

/obj/decal/sign/securearea
	desc = "A warning sign which reads 'SECURE AREA'"
	name = "SECURE AREA"
	icon_state = "securearea"

/obj/decal/sign/space
	desc = "A warning sign which reads 'SPACE DEPRESSURIZATION'"
	name = "SPACE DEPRESSURIZATION"
	icon_state = "space"

/obj/decal/sign/memetic
	desc = "A warning sign of memetic danger, which reads 'MEMETIC DANGER, USE MESONS'."
	name = "MEMETIC DANGER, USE MESONS."
	icon_state = "memetic"

/obj/decal/sign/stairsup
	desc = "A sign which shows an arrow pointing up stairs"
	name = "Stairs Up"
	icon_state = "sup"

/obj/decal/sign/stairsdown
	desc = "A sign which shows an arrow pointing down stairs"
	name = "Stairs Down"
	icon_state = "sdown"

/obj/decal/sign/deck/sub
	desc = "A sign which reads SUB DECK"
	name = "SUB DECK"
	part1
		icon_state = "sub0"
	part2
		icon_state = "sub1"

/obj/decal/sign/deck/main
	desc = "A sign which reads MAIN DECK"
	name = "MAIN DECK"
	part1
		icon_state = "main0"
	part2
		icon_state = "main1"

/obj/decal/sign/deck/enge
	desc = "A sign which reads ENGINEERING DECK"
	name = "ENGINEERING DECK"
	part1
		icon_state = "enge0"
	part2
		icon_state = "enge1"
	part3
		icon_state = "enge2"
	part4
		icon_state = "enge3"

/obj/decal/sign/deck/bridge
	desc = "A sign which reads BRIDGE DECK"
	name = "BRIDGE DECK"
	part1
		icon_state = "bridge0"
	part2
		icon_state = "bridge1"
	part3
		icon_state = "bridge2"

/obj/decal/sign/pinkflamingo1 // sign is 32.64, hence two objects
	desc = "The Pink Flamingo, Space Cantina"
	name = "The Pink Flamingo"
	icon = 'decals.dmi'
	icon_state = "pinkflamingo1"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/decal/sign/pinkflamingo2
	desc = "The Pink Flamingo, Space Cantina"
	name = "The Pink Flamingo"
	icon = 'decals.dmi'
	icon_state = "pinkflamingo2"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/decal/sign/magmasea1 // sign is 32.64, hence two objects
	desc = "The Magma Sea, Space Cantina"
	name = "The Magma Sea"
	icon = 'decals.dmi'
	icon_state = "magmasea1"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/decal/sign/magmasea2
	desc = "The Magma Sea, Space Cantina"
	name = "The Magma Sea"
	icon = 'decals.dmi'
	icon_state = "magmasea2"
	anchored = 1.0
	opacity = 0
	density = 0