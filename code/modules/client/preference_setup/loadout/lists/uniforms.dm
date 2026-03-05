/datum/gear/uniform
	sort_category = "Uniforms"
	slot = slot_w_uniform

/datum/gear/uniform/jumpsuit
	display_name = "jumpsuit, colour select"
	path = /obj/item/clothing/under/color
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/uniform/jumpskirt
	display_name = "jumpskirt, colour select"
	path = /obj/item/clothing/under/jumpskirt
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/uniform/jumpdress
	display_name = "jumpdress, colour select"
	path = /obj/item/clothing/under/jumpdress
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/uniform/department_dress
	display_name = "departmental dress & skirts selection"
	path = /obj/item/clothing/under/jumpdress

/datum/gear/uniform/department_dress/New()
	..()
	var/list/paths_to_jobs = list(
	/datum/job = list(/obj/item/clothing/under/jumpdress),
	/datum/job/captain = list(
		/obj/item/clothing/under/rank/captain/dress,
		/obj/item/clothing/under/rank/captain/skirt),
	/datum/job/hos = list(
		/obj/item/clothing/under/rank/head_of_security/dress,
		/obj/item/clothing/under/rank/head_of_security/jensen/dress,
		/obj/item/clothing/under/rank/head_of_security/skirt),
	/datum/job/warden = list(
		/obj/item/clothing/under/rank/warden/dress,
		/obj/item/clothing/under/rank/warden/skirt),
	/datum/job/detective = list(
		/obj/item/clothing/under/rank/det/dress,
		/obj/item/clothing/under/rank/det/skirt),
	/datum/job/officer = list(
		/obj/item/clothing/under/rank/security/dress,
		/obj/item/clothing/under/rank/security/skirt),
	/datum/job/chief_engineer = list(
		/obj/item/clothing/under/rank/chief_engineer/dress,
		/obj/item/clothing/under/rank/chief_engineer/skirt),
	/datum/job/engineer = list(
		/obj/item/clothing/under/rank/engineer/dress,
		/obj/item/clothing/under/rank/atmospheric_technician/dress,
		/obj/item/clothing/under/rank/engineer/skirt,
		/obj/item/clothing/under/rank/atmospheric_technician/skirt),
	/datum/job/hop = list(
		/obj/item/clothing/under/rank/hop/dress,
		/obj/item/clothing/under/rank/hop/skirt),
	/datum/job/cargo_tech = list(
		/obj/item/clothing/under/rank/cargotech/dress,
		/obj/item/clothing/under/rank/cargotech/skirt),
	/datum/job/mining = list(/obj/item/clothing/under/rank/miner/dress),
	/datum/job/iaa = list(
		/obj/item/clothing/under/rank/internalaffairs/dress,
		/obj/item/clothing/under/rank/internalaffairs/skirt),
	/datum/job/lawyer = list(
		/obj/item/clothing/under/lawyer/bluesuit/dress,
		/obj/item/clothing/under/lawyer/bluesuit/skirt),
	/datum/job/janitor = list(
		/obj/item/clothing/under/rank/janitor/dress,
		/obj/item/clothing/under/rank/janitor/skirt),
	/datum/job/hydro = list(
		/obj/item/clothing/under/rank/hydroponics/dress,
		/obj/item/clothing/under/rank/hydroponics/skirt),
	/datum/job/chef = list(
		/obj/item/clothing/under/rank/chef/dress,
		/obj/item/clothing/under/rank/chef/skirt),
	/datum/job/librarian = list(
		/obj/item/clothing/under/librarian/dress,
		/obj/item/clothing/under/librarian/skirt),
	/datum/job/chaplain = list(
		/obj/item/clothing/under/rank/chaplain/dress,
		/obj/item/clothing/under/rank/chaplain/skirt),
	/datum/job/bartender = list(
		/obj/item/clothing/under/rank/bartender/dress,
		/obj/item/clothing/under/rank/bartender/skirt),
	/datum/job/cmo = list(
		/obj/item/clothing/under/rank/chief_medical_officer/dress,
		/obj/item/clothing/under/rank/chief_medical_officer/skirt),
	/datum/job/doctor = list(
		/obj/item/clothing/under/rank/medical/dress,
		/obj/item/clothing/under/rank/medical/skirt),
	/datum/job/psychiatrist = list(
		/obj/item/clothing/under/rank/psych/dress,
		/obj/item/clothing/under/rank/psych/skirt),
	/datum/job/chemist = list(
		/obj/item/clothing/under/rank/chemist/dress,
		/obj/item/clothing/under/rank/chemist/skirt),
	/datum/job/virologist = list(
		/obj/item/clothing/under/rank/virologist/dress,
		/obj/item/clothing/under/rank/virologist/skirt),
	/datum/job/paramedic = list(
		/obj/item/clothing/under/rank/medical/paramedic/dress,
		/obj/item/clothing/under/rank/medical/paramedic/skirt),
	/datum/job/rd = list(
		/obj/item/clothing/under/rank/research_director/dress,
		/obj/item/clothing/under/rank/research_director/skirt),
	/datum/job/scientist = list(
		/obj/item/clothing/under/rank/scientist/dress,
		/obj/item/clothing/under/rank/scientist/skirt),
	/datum/job/xenobiologist = list(
		/obj/item/clothing/under/rank/scientist/dress,
		/obj/item/clothing/under/rank/scientist/skirt),
	/datum/job/roboticist = list(
		/obj/item/clothing/under/rank/roboticist/dress,
		/obj/item/clothing/under/rank/scientist/dress),
	/datum/job/merchant = list(
		/obj/item/clothing/under/jumpdress/black,
		/obj/item/clothing/under/jumpskirt/black)
	)

	gear_tweaks += new /datum/gear_tweak/departmental(paths_to_jobs)

/datum/gear/uniform/suit
	display_name = "clothes selection"
	path = /obj/item/clothing/under

/datum/gear/uniform/suit/New()
	..()
	var/suits = list()
	suits += /obj/item/clothing/under/sl_suit
	suits += /obj/item/clothing/under/suit_jacket
	suits += /obj/item/clothing/under/lawyer/blue
	suits += /obj/item/clothing/under/suit_jacket/really_black
	suits += /obj/item/clothing/under/suit_jacket/female
	suits += /obj/item/clothing/under/gentlesuit
	suits += /obj/item/clothing/under/lawyer/oldman
	suits += /obj/item/clothing/under/lawyer/purpsuit
	suits += /obj/item/clothing/under/suit_jacket/red
	suits += /obj/item/clothing/under/lawyer/red
	suits += /obj/item/clothing/under/lawyer/black
	suits += /obj/item/clothing/under/scratch
	suits += /obj/item/clothing/under/lawyer/bluesuit
	suits += /obj/item/clothing/under/blazer
	suits += /obj/item/clothing/under/kilt
	suits += /obj/item/clothing/under/dress/dress_hr
	gear_tweaks += new /datum/gear_tweak/path/specified_types_list(suits)

/datum/gear/uniform/scrubs
	display_name = "standard medical scrubs"
	path = /obj/item/clothing/under/rank/medical/scrubs
	flags = GEAR_HAS_TYPE_SELECTION

/datum/gear/uniform/scrubs/custom
	display_name = "scrubs, colour select"
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/uniform/dress_selection
	display_name = "dress selection"
	path = /obj/item/clothing/under

/datum/gear/uniform/dress_selection/New()
	..()
	var/dresses = list()
	dresses += /obj/item/clothing/under/sundress_white
	dresses += /obj/item/clothing/under/dress/dress_fire
	dresses += /obj/item/clothing/under/dress/dress_green
	dresses += /obj/item/clothing/under/dress/dress_orange
	dresses += /obj/item/clothing/under/dress/dress_pink
	dresses += /obj/item/clothing/under/dress/dress_purple
	dresses += /obj/item/clothing/under/sundress
	gear_tweaks += new /datum/gear_tweak/path/specified_types_list(dresses)

/datum/gear/uniform/skirt
	display_name = "skirt selection"
	path = /obj/item/clothing/under/skirt
	flags = GEAR_HAS_TYPE_SELECTION

/datum/gear/uniform/skirt_c/dress
	display_name = "simple dress, colour select"
	path = /obj/item/clothing/under/skirt_c/dress
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/uniform/skirts_color
	display_name = "skirt selection, colour select"
	path = /obj/item/clothing/under/skirt_c
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/uniform/skirts_color/New()
	..()
	var/skirts_colorable = list()
	skirts_colorable += /obj/item/clothing/under/skirt_c
	skirts_colorable += /obj/item/clothing/under/skirt_c/pencil
	skirts_colorable += /obj/item/clothing/under/skirt_c/casual
	skirts_colorable += /obj/item/clothing/under/skirt_c/high
	skirts_colorable += /obj/item/clothing/under/skirt_c/long
	skirts_colorable += /obj/item/clothing/under/skirt_c/swept
	skirts_colorable += /obj/item/clothing/under/skirt_c/plaid
	skirts_colorable += /obj/item/clothing/under/skirt_c/skater
	skirts_colorable += /obj/item/clothing/under/skirt_c/tube
	gear_tweaks += new /datum/gear_tweak/path/specified_types_list(skirts_colorable)

/datum/gear/uniform/casual_pants
	display_name = "casual pants selection"
	path = /obj/item/clothing/under/casual_pants
	flags = GEAR_HAS_TYPE_SELECTION

/datum/gear/uniform/track_pants
	display_name = "track pants selection"
	path = /obj/item/clothing/under/track_pants
	flags = GEAR_HAS_TYPE_SELECTION

/datum/gear/uniform/formal_pants
	display_name = "formal pants selection"
	path = /obj/item/clothing/under/formal_pants
	flags = GEAR_HAS_TYPE_SELECTION

/datum/gear/uniform/formal_pants/custom
	display_name = "suit pants, colour select"
	path = /obj/item/clothing/under/formal_pants
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/uniform/shorts
	display_name = "shorts selection"
	path = /obj/item/clothing/under/shorts/jeans
	flags = GEAR_HAS_TYPE_SELECTION

/datum/gear/uniform/shorts/custom
	display_name = "athletic shorts, colour select"
	path = /obj/item/clothing/under/shorts/
	flags = GEAR_HAS_COLOR_SELECTION

/datum/gear/uniform/veles_jumpsuit
	display_name = "veles jumpsuit"
	path = /obj/item/clothing/under

/datum/gear/uniform/veles_jumpsuit/New()
	..()
	var/veles = list()
	veles += /obj/item/clothing/under/veles
	veles += /obj/item/clothing/under/veles/veles_blue
	gear_tweaks += new /datum/gear_tweak/path/specified_types_list(veles)

/datum/gear/uniform/tacticool_turtleneck
	display_name = "tacticool turtleneck"
	path = /obj/item/clothing/under/syndicate/tacticool

/datum/gear/uniform/hazard
	display_name = "hazard jumpsuit"
	path = /obj/item/clothing/under/hazard

// /datum/gear/uniform/frontier
// 	display_name = "frontier clothes"
// 	path = /obj/item/clothing/under/frontier


//
// Donator's shop
//

/datum/gear/uniform/rank/vice
	display_name = "vice officer's jumpsuit"
	path = /obj/item/clothing/under/rank/vice
	price = 18

/datum/gear/uniform/pirate
	display_name = "pirate outfit"
	path = /obj/item/clothing/under/pirate
	price = 13

/datum/gear/uniform/waiter
	display_name = "waiter's outfit"
	path = /obj/item/clothing/under/waiter
	price = 12

/datum/gear/uniform/rank/centcom/officer
	display_name = "officer's dress uniform"
	path = /obj/item/clothing/under/rank/centcom/officer
	price = 39

/datum/gear/uniform/schoolgirl
	display_name = "schoolgirl uniform"
	path = /obj/item/clothing/under/schoolgirl
	price = 20

/datum/gear/uniform/soviet
	display_name = "soviet uniform"
	path = /obj/item/clothing/under/soviet
	price = 13

/datum/gear/uniform/gladiator
	display_name = "gladiator uniform"
	path = /obj/item/clothing/under/gladiator
	price = 10

/datum/gear/uniform/assistantformal
	display_name = "assistant's formal uniform"
	path = /obj/item/clothing/under/assistantformal
	price = 10

/datum/gear/uniform/psyche
	display_name = "psychedelic jumpsuit"
	path = /obj/item/clothing/under/psyche
	price = 100

/datum/gear/uniform/captain_fly
	display_name = "rogue's uniform"
	path = /obj/item/clothing/under/captain_fly
	price = 15

/datum/gear/uniform/mailman
	display_name = "mailman's jumpsuit"
	path = /obj/item/clothing/under/rank/mailman
	price = 10

/datum/gear/uniform/nasa
	display_name = "NASA jumpsuit"
	path = /obj/item/clothing/under/space
	price = 10

/datum/gear/uniform/sexyclown
	display_name = "sexy clown outfit"
	path = /obj/item/clothing/under/sexyclown
	price = 20

/datum/gear/uniform/sexymime
	display_name = "sexy mime outfit"
	path = /obj/item/clothing/under/sexymime
	price = 20

/datum/gear/uniform/owl
	display_name = "owl uniform"
	path = /obj/item/clothing/under/owl
	price = 5

/datum/gear/uniform/psycho
	display_name = "psycho suit"
	path = /obj/item/clothing/under/psysuit
	price = 10

/datum/gear/uniform/johnny
	display_name = "johnny jumpsuit"
	path = /obj/item/clothing/under/johnny
	price = 10

/datum/gear/uniform/dress/maid
	display_name = "maid uniform"
	path = /obj/item/clothing/under/dress/maid
	price = 15

/datum/gear/uniform/dress/gothic_d
	display_name = "gothic dress"
	path = /obj/item/clothing/under/dress/gothic_d
	price = 10

/datum/gear/uniform/dress/bride_white
	display_name = "silky wedding dress"
	path = /obj/item/clothing/under/wedding/bride_white
	price = 20

/datum/gear/uniform/dress/bride_blue
	display_name = "blue wedding dress"
	path = /obj/item/clothing/under/wedding/bride_blue
	price = 12

/datum/gear/uniform/dress/bride_red
	display_name = "red wedding dress"
	path = /obj/item/clothing/under/wedding/bride_red
	price = 12

/datum/gear/uniform/dress/bride_purple
	display_name = "purple wedding dress"
	path = /obj/item/clothing/under/wedding/bride_purple
	price = 12

/datum/gear/uniform/dress/bride_orange
	display_name = "orange wedding dress"
	path = /obj/item/clothing/under/wedding/bride_orange
	price = 12

/datum/gear/uniform/dress/long_gown
	display_name = "silk gown"
	path = /obj/item/clothing/under/skirt_c/dress/long/gown
	price = 10

/datum/gear/uniform/dress/black
	display_name = "black short dress"
	path = /obj/item/clothing/under/skirt_c/dress/black
	price = 10

/datum/gear/uniform/dress/long_black
	display_name = "black maxi dress"
	path = /obj/item/clothing/under/skirt_c/dress/long/black
	price = 20

/datum/gear/uniform/dress/long_eggshell
	display_name = "eggshell maxi dress"
	path = /obj/item/clothing/under/skirt_c/dress/long/eggshell
	price = 8

/datum/gear/uniform/dress/mintcream
	display_name = "mint short dress"
	path = /obj/item/clothing/under/skirt_c/dress/mintcream
	price = 10

/datum/gear/uniform/dress/long_mintcream
	display_name = "mint maxi dress"
	path = /obj/item/clothing/under/skirt_c/dress/long/mintcream
	price = 10

/datum/gear/uniform/dress/long
	display_name = "maxi dress"
	path = /obj/item/clothing/under/skirt_c/dress/long
	price = 20

/datum/gear/uniform/hosformal
	display_name = "HoS's formal uniform"
	allowed_roles = list(/datum/job/hos)
	price = 15

/datum/gear/uniform/hosformal/New()
	..()
	var/suits = list()
	suits += /obj/item/clothing/under/hosformalmale
	suits += /obj/item/clothing/under/hosformalfem
	gear_tweaks += new /datum/gear_tweak/path/specified_types_list(suits)

/datum/gear/uniform/dress/rosa
	display_name = "rosa dress"
	path = /obj/item/clothing/under/rank/rosa
	price = 10

/datum/gear/uniform/dress/black_tango
	display_name = "tango dress"
	path = /obj/item/clothing/under/dress/black_tango
	price = 10

/datum/gear/uniform/shortjumpskirt
	display_name = "short jumpskirt"
	path = /obj/item/clothing/under/jumpskirt/grey
	price = 10

/datum/gear/uniform/charcoal
	display_name = "charcoal suit"
	path = /obj/item/clothing/under/suit_jacket/charcoal
	price = 10

/datum/gear/uniform/navy
	display_name = "navy suit"
	path = /obj/item/clothing/under/suit_jacket/navy
	price = 10

/datum/gear/uniform/burgundy
	display_name = "burgundy suit"
	path = /obj/item/clothing/under/suit_jacket/burgundy
	price = 10

/datum/gear/uniform/NAME
	display_name = "checkered suit"
	path = /obj/item/clothing/under/suit_jacket/checkered
	price = 10

/datum/gear/uniform/tan
	display_name = "tan suit"
	path = /obj/item/clothing/under/suit_jacket/tan
	price = 10

/datum/gear/uniform/dress/abaya
	display_name = "abaya dress"
	path = /obj/item/clothing/under/abaya
	price = 10

/datum/gear/uniform/grayson
	display_name = "grayson overalls"
	path = /obj/item/clothing/under/grayson
	price = 10

/datum/gear/uniform/confederacy
	display_name = "confederate uniform"
	path = /obj/item/clothing/under/confederacy
	price = 10

/datum/gear/uniform/saare
	display_name = "saare uniform"
	path = /obj/item/clothing/under/saare
	price = 10

/datum/gear/uniform/aether
	display_name = "aether jumpsuit"
	path = /obj/item/clothing/under/aether
	price = 10

/datum/gear/uniform/focal
	display_name = "focal point jumpsuit"
	path = /obj/item/clothing/under/focal
	price = 10

/datum/gear/uniform/hephaestus
	display_name = "hephaestus jumpsuit"
	path = /obj/item/clothing/under/hephaestus
	price = 10

/datum/gear/uniform/savage_hunter
	display_name = "savage hunter's hides"
	price = 10

/datum/gear/uniform/savage_hunter/New()
	..()
	var/suits = list()
	suits += /obj/item/clothing/under/savage_hunter
	suits += /obj/item/clothing/under/savage_hunter/female
	gear_tweaks += new /datum/gear_tweak/path/specified_types_list(suits)

/datum/gear/uniform/dress/cheongsam
	display_name = "cheongsam dress"
	path = /obj/item/clothing/under/cheongsam
	price = 25

/datum/gear/uniform/frontier
	display_name = "frontier clothes"
	path = /obj/item/clothing/under/frontier
	price = 25

/datum/gear/uniform/dress/bar_f
	display_name = "black bartender dress"
	path = /obj/item/clothing/under/dress/bar_f
	price = 25

/datum/gear/uniform/tactical/jumpsuit
	sort_category = "Uniforms" // Since we don't want those who's bought this POS to lose it due to path change;
	display_name = "tactical jumpsuit"
	path = /obj/item/clothing/under/tactical
	price = 15

/datum/gear/uniform/dress/franziska_dress
	display_name = "prosecutor's dress"
	path = /obj/item/clothing/under/dress/franziska_dress
	price = 25

/datum/gear/uniform/captain_formal_alt
	display_name = "captain's formal uniform"
	path = /obj/item/clothing/under/captainformal/captain_formal_alt
	price = 10
	allowed_roles = list(/datum/job/captain)

/datum/gear/uniform/dress/captain_dress_alt
	display_name = "captain's formal dress"
	path = /obj/item/clothing/under/dress/captain_dress_alt
	price = 10
	allowed_roles = list(/datum/job/captain)

/datum/gear/uniform/latex_suit
	display_name = "latex suit"
	path = /obj/item/clothing/under/latex_suit
	price = 10

/datum/gear/uniform/fig_leaf
	display_name = "fig leaf"
	path = /obj/item/clothing/under/fig_leaf
	price = 5

/datum/gear/uniform/captain_alt
	display_name = "old captain's uniform"
	path = /obj/item/clothing/under/rank/captain/alt
	price = 10
	allowed_roles = list(/datum/job/captain)

/datum/gear/uniform/camouflage
	display_name = "camouflage jumpsuits"
	price = 15

/datum/gear/uniform/camouflage/New()
	..()
	var/camo = list()
	camo += /obj/item/clothing/under/camo
	camo += /obj/item/clothing/under/camo/firestarter
	camo += /obj/item/clothing/under/camo/urban
	gear_tweaks += new /datum/gear_tweak/path/specified_types_list(camo)
