//////////////////////////////////////////////
//////////     metroid CROSSBREEDS    //////////
//////////////////////////////////////////////
// A system of combining two extract types. //
// Performed by feeding a metroid 10 of an    //
// extract color.                           //
//////////////////////////////////////////////
/*==========================================*\
To add a crossbreed:
	The file name is automatically selected
	by the crossbreeding effect, which uses
	the format metroidcross/[modifier]/[color].

	If a crossbreed doesn't exist, don't
	worry. If no file is found at that
	location, it will simple display that
	the crossbreed was too unstable.

	As a result, do not feel the need to
	try to add all of the crossbred
	effects at once, if you're here and
	trying to make a new metroid type. Just
	get your metroidtype in the codebase and
	get around to the crossbreeds eventually!
\*==========================================*/

/mob/living/carbon/metroid/proc/handle_crossbreeding(obj/item/metroid_extract/core, mob/user)
	if(!effectmod)
		effectmod = core.effectmod
		applied_cores = 0
		to_chat(user, SPAN_NOTICE("\The [core] dissolves inside \the [src], something seems different!"))
		qdel(core)
		return

	if(core.effectmod != effectmod && applied_cores<3)
		effectmod = core.effectmod
		applied_cores = 0
		to_chat(user, SPAN_NOTICE("\The [core] dissolves any other extracts inside \the [src]!"))
		qdel(core)
		return

	if(core.effectmod != effectmod)
		to_chat(user, SPAN_NOTICE("You can't push \the [core] into \the [src]!"))
		return

	applied_cores++
	qdel(core)

	if(applied_cores>=METROID_EXTRACT_CROSSING_REQUIRED)
		spawn_corecross()
	return

/mob/living/carbon/metroid/proc/spawn_corecross()
	if(is_ic_dead())
		return

	var/static/list/crossbreeds = subtypesof(/obj/item/metroidcross)
	visible_message(SPAN_DANGER("[src] shudders, its mutated core consuming the rest of its body!"))
	var/datum/effect/effect/system/smoke_spread/s = new /datum/effect/effect/system/smoke_spread
	s.set_up(4, 1, src, 0)
	s.start()
	playsound(src, 'sound/effects/smoke.ogg', 50, TRUE)
	var/crosspath
	for(var/X in crossbreeds)
		var/obj/item/metroidcross/S = X
		if(initial(S.colour) == colour && initial(S.effect) == effectmod)
			crosspath = S
			break
	if(crosspath)
		new crosspath(loc)
	else
		visible_message(SPAN_WARNING("The mutated core shudders, and collapses into a puddle, unable to maintain its form."))
	qdel(src)

/obj/item/metroidcross //The base type for crossbred extracts. Mostly here for posterity, and to set base case things.
	name = "crossbred metroid extract"
	desc = "An extremely potent metroid extract, formed through crossbreeding."
	icon = 'icons/obj/xenobiology/metroidcrossing.dmi'
	icon_state = "base"
	var/colour = "null"
	var/effect = "null"
	var/effect_desc = "null"
	force = 0
	w_class = ITEM_SIZE_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 6
	atom_flags = ATOM_FLAG_OPEN_CONTAINER

/obj/item/metroidcross/examine(mob/user, infix)
	. = ..()

	if(effect_desc)
		. += SPAN_NOTICE("[effect_desc]")

/obj/item/metroidcross/Initialize(mapload)
	. = ..()
	name = effect + " " + colour + " extract"
	color = "#FFFFFF"
	switch(colour)
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
			color = "#0fdee6"
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
