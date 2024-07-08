
/obj/item/metroidcrossbeaker //To be used as a result for extract reactions that make chemicals.
	name = "result extract"
	desc = "You shouldn't see this."
	icon = 'icons/obj/xenobiology/metroidcrossing.dmi'
	icon_state = "base"
	var/del_on_empty = TRUE
	var/list/list_reagents
	can_get_wet = FALSE
	can_be_wrung_out = FALSE

/obj/item/metroidcrossbeaker/Initialize(mapload)
	. = ..()
	create_reagents(50)
	if(list_reagents)
		for(var/reagent in list_reagents)
			reagents.add_reagent(reagent, list_reagents[reagent])
	if(del_on_empty)
		set_next_think(world.time + 1 SECOND)

/obj/item/metroidcrossbeaker/Destroy()
	set_next_think(0)
	return ..()

/obj/item/metroidcrossbeaker/think()
	if(!reagents.total_volume)
		visible_message(SPAN_NOTICE("[src] has been drained completely, and melts away."))
		qdel(src)

/obj/item/metroidcrossbeaker/bloodpack //Pack of 50u blood. Deletes on empty.
	name = "blood extract"
	desc = "A sphere of liquid blood, somehow managing to stay together."
	color = "#FF0000"
	list_reagents = list(/datum/reagent/nanoblood = 50)

/obj/item/metroidcrossbeaker/soporific //10u soporific
	name = "sleepy extract"
	desc = "A small blob of soporific."
	color = "#FFCCCC"
	list_reagents = list(/datum/reagent/soporific = 10)

/obj/item/metroidcrossbeaker/healing //16u dermaline+bicaridine.
	name = "healing extract"
	desc = "A gelatinous extract of pure healing."
	color = "#FF00FF"
	list_reagents = list(/datum/reagent/dermaline = 8,/datum/reagent/bicaridine=8)

/obj/item/metroidcrossbeaker/pax //30u dermaline+bicaridine.
	name = "paroxetine extract"
	desc = "Stay calm."
	color = "#ff80bf"
	list_reagents = list(/datum/reagent/paroxetine = 30)

/obj/item/metroidcrossbeaker/tricordrazine //30u tricordrazine
	name = "tricordrazine extract"
	desc = "A gelatinous extract of pure healing."
	color = "#8040ff"
	list_reagents = list(/datum/reagent/tricordrazine = 30)


/obj/item/metroidcrossbeaker/autoinjector //As with the above, but automatically injects whomever it is used on with contents.
	var/ignore_flags = FALSE
	var/self_use_only = FALSE

/obj/item/metroidcrossbeaker/autoinjector/attack(mob/living/M, mob/user)
	if(!reagents.total_volume)
		to_chat(user, SPAN_WARNING("[src] is empty!"))
		return
	if(!iscarbon(M))
		return
	if(self_use_only && M != user)
		to_chat(user, SPAN_WARNING("This can only be used on yourself."))
		return
	if(reagents.total_volume)
		reagents.trans_to_mob(M, reagents.total_volume, CHEM_BLOOD)
		admin_inject_log(user, M, src, reagents, reagents.total_volume)
		if(user != M)
			to_chat(M, SPAN_WARNING("[user] presses [src] against you!"))
			to_chat(user, SPAN_NOTICE("You press [src] against [M], injecting."))
		else
			to_chat(user, SPAN_NOTICE("You press [src] against yourself, and it flattens against you!"))
	else
		to_chat(user, SPAN_WARNING("There's no place to stick [src]!"))

/obj/item/metroidcrossbeaker/autoinjector/regenpack
	ignore_flags = TRUE //It is, after all, intended to heal.
	name = "mending solution"
	desc = "A strange glob of sweet-smelling semifluid, which seems to stick to skin rather easily."
	color = "#FF00FF"
	list_reagents = list(/datum/reagent/regen_jelly = 20)

/obj/item/metroidcrossbeaker/autoinjector/metroidjelly //Primarily for metroidpeople, but you do you.
	self_use_only = TRUE
	ignore_flags = TRUE
	name = "metroid jelly bubble"
	desc = "A sphere of metroid jelly. It seems to stick to your skin, but avoids other surfaces."
	color = "#00FF00"
	list_reagents = list(/datum/reagent/metroidjelly = 50)

/obj/item/metroidcrossbeaker/autoinjector/peaceandlove
	name = "peaceful distillation"
	desc = "A light pink gooey sphere. Simply touching it makes you a little dizzy."
	color = "#DDAAAA"
	list_reagents = list(/datum/reagent/paroxetine = 10, /datum/reagent/space_drugs = 15) //Peace, dudes

/obj/item/metroidcrossbeaker/autoinjector/metroidstimulant
	name = "invigorating gel"
	desc = "A bubbling purple mixture, designed to heal and boost movement."
	color = "#FF00FF"
	list_reagents = list(/datum/reagent/regen_jelly = 30, /datum/reagent/space_drugs = 9)
