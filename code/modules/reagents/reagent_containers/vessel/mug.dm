
/obj/item/reagent_containers/vessel/mug
	name = "mug"
	desc = "A plain white coffee mug."
	icon = 'icons/obj/reagent_containers/mugs.dmi'
	icon_state = "coffeecup"
	item_state = "mug_empty"
	force = 5.0
	mod_weight = 0.45
	mod_reach = 0.25
	mod_handy = 0.65
	volume = 30
	center_of_mass = "x=15;y=13"
	filling_states = "20;40;80;100"
	lid_type = null
	base_icon = "coffeecup"
	item_state = "coffeecup"

/obj/item/reagent_containers/vessel/mug/black
	name = "black mug"
	desc = "A sleek black coffee mug."
	icon_state = "coffeecup_black"
	item_state = "coffeecup_black"

/obj/item/reagent_containers/vessel/mug/green
	name = "green mug"
	desc = "A pale green and pink coffee mug."
	icon_state = "coffeecup_green"
	item_state = "coffeecup_green"

/obj/item/reagent_containers/vessel/mug/heart
	name = "heart mug"
	desc = "A white coffee mug, it prominently features a red heart."
	icon_state = "coffeecup_heart"
	item_state = "coffeecup_NT"

/obj/item/reagent_containers/vessel/mug/SCG
	name = "SCG mug"
	desc = "A blue coffee mug emblazoned with the crest of the Sol Central Government."
	icon_state = "coffeecup_SCG"
	item_state = "coffeecup_SCG"

/obj/item/reagent_containers/vessel/mug/NT
	name = "NT mug"
	desc = "A red NanoTrasen coffee mug. 90% Guaranteed to not be laced with mind-control drugs."
	icon_state = "coffeecup_NT"
	item_state = "coffeecup_NT"

/obj/item/reagent_containers/vessel/mug/one
	name = "#1 mug"
	desc = "A white coffee mug, prominently featuring a #1."
	icon_state = "coffeecup_one"
	item_state = "coffeecup_one"

/obj/item/reagent_containers/vessel/mug/punitelli
	name = "#1 monkey mug"
	desc = "A white coffee mug, prominently featuring a \"#1 monkey\"."
	icon_state = "coffeecup_punitelli"
	item_state = "coffeecup"
	startswith = list(/datum/reagent/drink/juice/banana = 30)

/obj/item/reagent_containers/vessel/mug/rainbow
	name = "rainbow mug"
	desc = "A rainbow coffee mug. The colors are almost as blinding as a welder."
	icon_state = "coffeecup_rainbow"
	item_state = "coffeecup_rainbow"

/obj/item/reagent_containers/vessel/mug/metal
	name = "metal mug"
	desc = "A metal coffee mug. You're not sure which metal."
	icon_state = "coffeecup_metal"
	item_state = "coffeecup_metal"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	force = 6.5
	mod_weight = 0.55
	mod_reach = 0.25
	mod_handy = 0.65

/obj/item/reagent_containers/vessel/mug/STC
	name = "TCC mug"
	desc = "A coffee mug adorned with the flag of the Terran Colonial Confederation, for when you need some espionage charges to go with your morning coffee."
	icon_state = "coffeecup_STC"
	item_state = "coffecup_NT"

/obj/item/reagent_containers/vessel/mug/pawn
	name = "pawn mug"
	desc = "A black coffee mug adorned with the image of a red chess pawn."
	icon_state = "coffeecup_pawn"
	item_state = "coffecup_NT"

/obj/item/reagent_containers/vessel/mug/diona
	name = "diona mug"
	desc = "A green coffee mug featuring the image of a diona nymph."
	icon_state = "coffeecup_diona"
	item_state = "coffeecup_green"

/obj/item/reagent_containers/vessel/mug/britcup
	name = "british mug"
	desc = "A coffee mug with the British flag emblazoned on it."
	icon_state = "coffeecup_brit"
	item_state = "britcup"

/obj/item/reagent_containers/vessel/mug/tall
	name = "tall mug"
	desc = "An unreasonably tall coffee mug, for when you really need to wake up in the morning."
	icon_state = "coffeecup_tall"
	item_state = "coffeecup_tall"
	force = 6.0
	mod_weight = 0.55
	mod_reach = 0.35
	mod_handy = 0.65
	volume = 60
	center_of_mass = "x=15;y=19"
	filling_states = "50;70;90;100"
	base_icon = null
