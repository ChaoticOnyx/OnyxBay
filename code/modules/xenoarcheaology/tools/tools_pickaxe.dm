/obj/item/pickaxe/archaeologist
	name = "brush"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "pick_hand"
	item_state = "syringe_0"
	force = 5
	throwforce = 5
	mod_weight = 0.9
	mod_reach = 1
	mod_handy = 1.2
	digspeed = 20
	w_class = ITEM_SIZE_SMALL
	drill_sound = 'sound/items/Screwdriver.ogg'
	drill_verb = "delicately picking"

/obj/item/pickaxe/archaeologist/brush
	name = "brush"
	icon_state = "pick_brush"
	slot_flags = SLOT_EARS
	desc = "Thick metallic wires for clearing away dust and loose scree (1 centimetre excavation depth)."
	excavation_amount = 1
	drill_sound = 'sound/weapons/thudswoosh.ogg'
	drill_verb = "brushing"

/obj/item/pickaxe/archaeologist/one_pick
	name = "2cm pick"
	icon_state = "pick1"
	desc = "A miniature excavation tool for precise digging (2 centimetre excavation depth)."
	excavation_amount = 2

/obj/item/pickaxe/archaeologist/two_pick
	name = "4cm pick"
	icon_state = "pick2"
	desc = "A miniature excavation tool for precise digging (4 centimetre excavation depth)."
	excavation_amount = 4

/obj/item/pickaxe/archaeologist/three_pick
	name = "6cm pick"
	icon_state = "pick3"
	desc = "A miniature excavation tool for precise digging (6 centimetre excavation depth)."
	excavation_amount = 6

/obj/item/pickaxe/archaeologist/four_pick
	name = "8cm pick"
	icon_state = "pick4"
	desc = "A miniature excavation tool for precise digging (8 centimetre excavation depth)."
	excavation_amount = 8

/obj/item/pickaxe/archaeologist/five_pick
	name = "10cm pick"
	icon_state = "pick5"
	desc = "A miniature excavation tool for precise digging (10 centimetre excavation depth)."
	excavation_amount = 10

/obj/item/pickaxe/archaeologist/six_pick
	name = "12cm pick"
	icon_state = "pick6"
	desc = "A miniature excavation tool for precise digging (12 centimetre excavation depth)."
	excavation_amount = 12

/obj/item/pickaxe/archaeologist/hand
	name = "hand pickaxe"
	icon_state = "pick_hand"
	item_state = "syringe_0"
	digspeed = 30
	desc = "A smaller, more precise version of the pickaxe (30 centimetre excavation depth)."
	excavation_amount = 30
	drill_sound = 'sound/items/Crowbar.ogg'
	drill_verb = "clearing"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Pack for holding pickaxes

/obj/item/storage/excavation
	name = "excavation pick set"
	icon = 'icons/obj/storage.dmi'
	icon_state = "excavation"
	desc = "A set of picks for excavation."
	item_state = "syringe_kit"
	storage_slots = 7
	w_class = ITEM_SIZE_SMALL
	can_hold = list(/obj/item/pickaxe/archaeologist/brush,
	/obj/item/pickaxe/archaeologist/one_pick,
	/obj/item/pickaxe/archaeologist/two_pick,
	/obj/item/pickaxe/archaeologist/three_pick,
	/obj/item/pickaxe/archaeologist/four_pick,
	/obj/item/pickaxe/archaeologist/five_pick,
	/obj/item/pickaxe/archaeologist/six_pick,
	/obj/item/pickaxe/archaeologist/hand)
	max_storage_space = 18
	max_w_class = ITEM_SIZE_SMALL
	use_to_pickup = 1

/obj/item/storage/excavation/New()
	..()
	new /obj/item/pickaxe/archaeologist/brush(src)
	new /obj/item/pickaxe/archaeologist/one_pick(src)
	new /obj/item/pickaxe/archaeologist/two_pick(src)
	new /obj/item/pickaxe/archaeologist/three_pick(src)
	new /obj/item/pickaxe/archaeologist/four_pick(src)
	new /obj/item/pickaxe/archaeologist/five_pick(src)
	new /obj/item/pickaxe/archaeologist/six_pick(src)

/obj/item/storage/excavation/handle_item_insertion()
	..()
	sort_picks()

/obj/item/storage/excavation/proc/sort_picks()
	var/list/obj/item/pickaxe/picksToSort = list()
	for(var/obj/item/pickaxe/P in src)
		picksToSort += P
		P.loc = null
	while(picksToSort.len)
		var/min = 200 // No pick is bigger than 200
		var/selected = 0
		for(var/i = 1 to picksToSort.len)
			var/obj/item/pickaxe/current = picksToSort[i]
			if(current.excavation_amount <= min)
				selected = i
				min = current.excavation_amount
		var/obj/item/pickaxe/smallest = picksToSort[selected]
		smallest.loc = src
		picksToSort -= smallest
	prepare_ui()
