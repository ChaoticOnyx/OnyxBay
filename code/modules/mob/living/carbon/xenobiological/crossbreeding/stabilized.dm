/*
Stabilized extracts:
	Provides a passive buff to the holder.
*/

//To add: Create an effect in crossbreeding/_modifiers.dm with the name "/datum/modifier/status_effect/stabilized/[color]"
//Status effect will automatically be applied while held, and lost on drop.

/obj/item/metroidcross/stabilized
	name = "stabilized extract"
	desc = "It seems inert, but anything it touches glows softly..."
	effect = "stabilized"
	icon_state = "stabilized"
	var/datum/modifier/status_effect/linked_effect
	var/mob/living/owner
	var/datum/modifier/effectpath

/obj/item/metroidcross/stabilized/Initialize(mapload)
	. = ..()
	set_next_think(world.time + 1 SECOND)

/obj/item/metroidcross/stabilized/Destroy()
	set_next_think(0)
	qdel(linked_effect)
	return ..()

/obj/item/metroidcross/stabilized/think()
	var/humanfound = null
	if(ishuman(loc))
		humanfound = loc
	if(ishuman(loc.loc)) //Check if in backpack.
		humanfound = (loc.loc)

	if(!humanfound)
		set_next_think(world.time + 1 SECOND)
		return

	var/mob/living/carbon/human/H = humanfound
	var/static/list/effects = subtypesof(/datum/modifier/status_effect/stabilized)

	if(isnull(effectpath))
		for(var/X in effects)
			var/datum/modifier/status_effect/stabilized/S = X
			if(initial(S.colour) == colour)
				effectpath = S
				break

	if(!H.has_modifier_of_type(effectpath))
		var/datum/modifier/status_effect/stabilized/S = H.add_modifier(effectpath)
		owner = H
		S.linked_extract = src
		S.set_next_think(world.time + 1 SECOND)

	set_next_think(world.time + 1 SECOND)


//Colors and subtypes:
/obj/item/metroidcross/stabilized/green
	colour = "green"
	effect_desc = "Makes metroids friendly to the owner"

/obj/item/metroidcross/stabilized/orange
	colour = "orange"
	effect_desc = "Passively tries to increase or decrease the owner's body temperature to normal"

/obj/item/metroidcross/stabilized/purple
	colour = "purple"
	effect_desc = "Provides a regeneration effect"

/obj/item/metroidcross/stabilized/blue
	colour = "blue"
	effect_desc = "Makes the owner immune to slipping on water, soap or foam. Space lube and ice are still too slippery."

/obj/item/metroidcross/stabilized/metal
	colour = "metal"
	effect_desc = "Every 30 seconds, adds a sheet of material to a random stack in the owner's backpack or hands."

/obj/item/metroidcross/stabilized/yellow
	colour = "yellow"
	effect_desc = "Every ten seconds it recharges a device on the owner by 10%."

/obj/item/metroidcross/stabilized/darkpurple
	colour = "dark purple"
	effect_desc = "Gives you burning fingertips, automatically cooking any microwavable food you hold."

/obj/item/metroidcross/stabilized/darkblue
	colour = "dark blue"
	effect_desc = "Slowly extinguishes the owner if they are on fire, also wets items like monkey cubes, creating a monkey."

/obj/item/metroidcross/stabilized/silver
	colour = "silver"
	effect_desc = "Slows the rate at which the owner loses nutrition"

/obj/item/metroidcross/stabilized/bluespace
	colour = "bluespace"
	effect_desc = "On a two minute cooldown, when the owner has taken enough damage, they are teleported to a safe place."

/obj/item/metroidcross/stabilized/sepia
	colour = "sepia"
	effect_desc = "Randomly adjusts the owner's speed."

/obj/item/metroidcross/stabilized/cerulean
	colour = "cerulean"
	effect_desc = "Creates a duplicate of the owner. If the owner dies they will take control of the duplicate, unless the death was from beheading or gibbing."

/obj/item/metroidcross/stabilized/pyrite
	colour = "pyrite"
	effect_desc = "Randomly colors the owner every few seconds."

/obj/item/metroidcross/stabilized/red
	colour = "red"
	effect_desc = "Nullifies all equipment based slowdowns."

/obj/item/metroidcross/stabilized/grey
	colour = "grey"
	effect_desc = "Changes the owner's name and appearance while holding this extract."

/obj/item/metroidcross/stabilized/pink
	colour = "pink"
	effect_desc = "It's doing nothing!"

/obj/item/metroidcross/stabilized/gold
	colour = "gold"
	effect_desc = "Creates a pet when held."
	var/mob_type
	var/datum/mind/saved_mind
	var/mob_name = "Familiar"

/obj/item/metroidcross/stabilized/gold/proc/generate_mobtype()
	var/static/list/mob_spawn_pets = list()
	if(!length(mob_spawn_pets))
		mob_spawn_pets = subtypesof(/mob/living/simple_animal)-subtypesof(/mob/living/simple_animal/hostile)
	mob_type = pick(mob_spawn_pets)

/obj/item/metroidcross/stabilized/gold/Initialize(mapload)
	. = ..()
	generate_mobtype()

/obj/item/metroidcross/stabilized/gold/attack_self(mob/user)
	var/choice = tgui_input_list(user, "Which do you want to reset?", "Familiar Adjustment", sort_list(list("Familiar Location", "Familiar Species", "Familiar Sentience", "Familiar Name")))
	if(isnull(choice))
		return
	if(!CanUseTopic(user))
		return
	if(isliving(user))
		var/mob/living/L = user
		if(L.has_modifier_of_type(/datum/modifier/status_effect/stabilized/gold))
			L.remove_a_modifier_of_type(/datum/modifier/status_effect/stabilized/gold)
	if(choice == "Familiar Location")
		to_chat(user, SPAN_NOTICE("You prod [src], and it shudders slightly."))
		var/datum/modifier/status_effect/stabilized/gold/G = linked_effect
		do_teleport(G.familiar, get_turf(src))
		set_next_think(world.time + 1 SECOND)

	if(choice == "Familiar Species")
		to_chat(user, SPAN_NOTICE("You squeeze [src], and a shape seems to shift around inside."))
		generate_mobtype()
		set_next_think(world.time + 1 SECOND)

	if(choice == "Familiar Sentience")
		to_chat(user, SPAN_NOTICE("You poke [src], and it lets out a glowing pulse."))
		saved_mind = null
		set_next_think(world.time + 1 SECOND)

	if(choice == "Familiar Name")
		var/newname = sanitize_name(input(user, "Would you like to change the name of [mob_name]", "Name change", mob_name) as text)
		if(newname)
			mob_name = newname
		to_chat(user, SPAN_NOTICE("You speak softly into [src], and it shakes slightly in response."))
		set_next_think(world.time + 1 SECOND)

/obj/item/metroidcross/stabilized/oil
	colour = "oil"
	effect_desc = "The owner will violently explode when they die while holding this extract."

/obj/item/metroidcross/stabilized/black
	colour = "black"
	effect_desc = "While strangling someone, the owner's hands melt around their neck, draining their life in exchange for food and healing."

/obj/item/metroidcross/stabilized/lightpink
	colour = "light pink"
	effect_desc = "The owner moves at high speeds while holding this extract, also stabilizes anyone in critical condition around you using Epinephrine."

/obj/item/metroidcross/stabilized/adamantine
	colour = "adamantine"
	effect_desc = "Owner gains a slight boost in damage resistance to all types."

/obj/item/metroidcross/stabilized/rainbow
	colour = "rainbow"
	effect_desc = "Accepts a regenerative extract and automatically uses it if the owner enters a critical condition."
	var/obj/item/metroidcross/regenerative/regencore

/obj/item/metroidcross/stabilized/rainbow/attackby(obj/item/O, mob/user)
	var/obj/item/metroidcross/regenerative/regen = O
	if(istype(regen) && !regencore)
		to_chat(user, SPAN_NOTICE("You place [O] in [src], prepping the extract for automatic application!"))
		regencore = regen
		user.drop(regen)
		regen.forceMove(src)
		return
	return ..()
