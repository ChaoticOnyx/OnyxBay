//////////////////////////////////////////////
//////////     SLIME CROSSBREEDS    //////////
//////////////////////////////////////////////
// A system of combining two extract types. //
// Performed by feeding a slime 10 of an    //
// extract color.                           //
//////////////////////////////////////////////
/*==========================================*\
To add a crossbreed:
	The file name is automatically selected
	by the crossbreeding effect, which uses
	the format slimecross/[modifier]/[color].

	If a crossbreed doesn't exist, don't
	worry. If no file is found at that
	location, it will simple display that
	the crossbreed was too unstable.

	As a result, do not feel the need to
	try to add all of the crossbred
	effects at once, if you're here and
	trying to make a new slime type. Just
	get your slimetype in the codebase and
	get around to the crossbreeds eventually!
\*==========================================*/

/mob/living/carbon/metroid/proc/handle_crossbreeding(/obj/item/metroid_extract/core, mob/user)
	if(!effectmod)
		effectmod = core.effectmod
		applied_cores = 0
		to_chat(user, SPAN_NOTICE("\The [core] dissolves inside \the [src], something seems different!"))
		return

	if(core.effectmod != effectmod && applied_cores<3)
		effectmod = core.effectmod
		applied_cores = 0
		to_chat(user, SPAN_NOTICE("\The [core] dissolves any other extracts inside \the [src]!"))
		return

	if(core.effectmod != effectmod)
		to_chat(user, SPAN_NOTICE("You can't push \the [core] into \the [src]!"))
		return

	applied_cores++

	if(applied_cores>=SLIME_EXTRACT_CROSSING_REQUIRED)
		spawn_corecross()
	return

/mob/living/carbon/metroid/proc/spawn_corecross()
	var/static/list/crossbreeds = subtypesof(/obj/item/slimecross)
	visible_message(SPAN_DANGER("[src] shudders, its mutated core consuming the rest of its body!"))
	playsound(src, 'sound/magic/smoke.ogg', 50, TRUE)
	var/crosspath
	for(var/X in crossbreeds)
		var/obj/item/slimecross/S = X
		if(initial(S.colour) == colour && initial(S.effect) == effectmod)
			crosspath = S
			break
	if(crosspath)
		new crosspath(loc)
	else
		visible_message(SPAN_WARNING("The mutated core shudders, and collapses into a puddle, unable to maintain its form."))
	qdel(src)

/obj/item/slimecross //The base type for crossbred extracts. Mostly here for posterity, and to set base case things.
	name = "crossbred slime extract"
	desc = "An extremely potent slime extract, formed through crossbreeding."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "base"
	var/itemcolor = "null"
	var/effect = "null"
	var/effect_desc = "null"
	force = 0
	w_class = ITEM_SIZE_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 6

/obj/item/slimecross/examine(mob/user)
	. = ..()
	if(effect_desc)
		. += SPAN_NOTICE("[effect_desc]")

/obj/item/slimecross/Initialize(mapload)
	. = ..()
	name = effect + " " + itemcolor + " extract"
	color = "#FFFFFF"
	switch(itemcolor)
		if("orange")
			color = "#FFA500"
		if("purple")
			color = "#B19CD9"
		if("blue")
			color = "#ADD8E6"
		if("metal")
			color = "#7E7E7E"
		if("yellow")
			color = "#FFFF00"
		if("dark purple")
			color = "#551A8B"
		if("dark blue")
			color = "#0000FF"
		if("silver")
			color = "#D3D3D3"
		if("bluespace")
			color = "#32CD32"
		if("sepia")
			color = "#704214"
		if("cerulean")
			color = "#2956B2"
		if("pyrite")
			color = "#FAFAD2"
		if("red")
			color = "#FF0000"
		if("green")
			color = "#00FF00"
		if("pink")
			color = "#FF69B4"
		if("gold")
			color = "#FFD700"
		if("oil")
			color = "#505050"
		if("black")
			color = "#000000"
		if("light pink")
			color = "#FFB6C1"
		if("adamantine")
			color = "#008B8B"

/obj/item/slimecrossbeaker //To be used as a result for extract reactions that make chemicals.
	name = "result extract"
	desc = "You shouldn't see this."
	icon = 'icons/obj/xenobiology/slimecrossing.dmi'
	icon_state = "base"
	var/del_on_empty = TRUE
	var/list/list_reagents

/obj/item/slimecrossbeaker/Initialize(mapload)
	. = ..()
	create_reagents(50)
	if(list_reagents)
		for(var/reagent in list_reagents)
			reagents.add_reagent(reagent, list_reagents[reagent])
	if(del_on_empty)
		set_next_think(world.time + 1 SECOND)

/obj/item/slimecrossbeaker/Destroy()
	set_next_think(0)
	return ..()

/obj/item/slimecrossbeaker/think()
	if(!reagents.total_volume)
		visible_message(SPAN_NOTICE("[src] has been drained completely, and melts away."))
		qdel(src)

/obj/item/slimecrossbeaker/bloodpack //Pack of 50u blood. Deletes on empty.
	name = "blood extract"
	desc = "A sphere of liquid blood, somehow managing to stay together."
	color = "#FF0000"
	list_reagents = list(/datum/reagent/blood = 50)

/obj/item/slimecrossbeaker/soporific //10u soporific
	name = "sleepy extract"
	desc = "A small blob of soporific."
	color = "#FFCCCC"
	list_reagents = list(/datum/reagent/soporific = 10)

/obj/item/slimecrossbeaker/healing //16u dermaline+bicaridine.
	name = "healing extract"
	desc = "A gelatinous extract of pure healing."
	color = "#FF00FF"
	list_reagents = list(/datum/reagent/dermaline = 8,/datum/reagent/bicaridine=8)

/obj/item/slimecrossbeaker/autoinjector //As with the above, but automatically injects whomever it is used on with contents.
	var/ignore_flags = FALSE
	var/self_use_only = FALSE

/obj/item/slimecrossbeaker/autoinjector/attack(mob/living/M, mob/user)
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

/obj/item/slimecrossbeaker/autoinjector/regenpack
	ignore_flags = TRUE //It is, after all, intended to heal.
	name = "mending solution"
	desc = "A strange glob of sweet-smelling semifluid, which seems to stick to skin rather easily."
	color = "#FF00FF"
	list_reagents = list()//fuck baymed

/obj/item/slimecrossbeaker/autoinjector/regenpack/attack(mob/living/M, mob/living/user, target_zone)
	if(!iscarbon(M))
		return
	if(user != M)
		to_chat(M, SPAN_WARNING("[user] presses [src] against you!"))
		to_chat(user, SPAN_NOTICE("You press [src] against [M], injecting."))
		M.heal_overall_damage(min(30, user.getBruteLoss()), min(30, user.getFireLoss()))
	else
		to_chat(user, SPAN_NOTICE("You press [src] against yourself, and it flattens against you!"))
		user.heal_overall_damage(min(30, user.getBruteLoss()), min(30, user.getFireLoss()))


/obj/item/slimecrossbeaker/autoinjector/metroidjelly //Primarily for slimepeople, but you do you.
	self_use_only = TRUE
	ignore_flags = TRUE
	name = "metroid jelly bubble"
	desc = "A sphere of metroid jelly. It seems to stick to your skin, but avoids other surfaces."
	color = "#00FF00"
	list_reagents = list(/datum/reagent/toxin/metroidjelly = 50)

/obj/item/slimecrossbeaker/autoinjector/peaceandlove
	name = "peaceful distillation"
	desc = "A light pink gooey sphere. Simply touching it makes you a little dizzy."
	color = "#DDAAAA"
	list_reagents = list(/datum/reagent/paroxetine = 10, /datum/reagent/space_drugs = 15) //Peace, dudes
