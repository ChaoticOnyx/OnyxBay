
/proc/alien_queen_exists(ignore_self,mob/living/carbon/human/self)
	for(var/mob/living/carbon/human/Q in GLOB.living_mob_list_)
		if(self && ignore_self && self == Q)
			continue
		if(Q.species.name != SPECIES_XENO_QUEEN)
			continue
		if(!Q.key || !Q.client || Q.stat)
			continue
		return TRUE
	return FALSE

/mob/living/carbon/human/proc/gain_plasma(amount)

	var/obj/item/organ/internal/xenos/plasmavessel/I = internal_organs_by_name[BP_PLASMA]
	if(!istype(I))
		return

	if(amount)
		I.stored_plasma += amount
	I.stored_plasma = max(0, min(I.stored_plasma, I.max_plasma))

/mob/living/carbon/human/proc/check_alien_ability(cost, needs_organ = null, needs_foundation = FALSE, silent = FALSE) //Returns 1 if the ability is clear for usage.
	if(stat)
		if(!silent)
			to_chat(src, SPAN("danger", "I cannot to this while incapacitated!"))
		return

	var/obj/item/organ/internal/xenos/plasmavessel/P = internal_organs_by_name[BP_PLASMA]
	if(!istype(P))
		if(!silent)
			to_chat(src, SPAN("danger", "My plasma vessel is missing!"))
		return

	if(needs_organ)
		var/obj/item/organ/internal/I = internal_organs_by_name[needs_organ]
		if(!I)
			if(!silent)
				to_chat(src, SPAN("danger", "My [needs_organ] is missing!"))
			return
		else if((I.status & ORGAN_CUT_AWAY) || I.is_broken())
			if(!silent)
				to_chat(src, SPAN("danger", "My [needs_organ] is too damaged to function!"))
			return

	if(P.stored_plasma < cost)
		if(!silent)
			to_chat(src, SPAN("danger", "I don't have enough plasma stored to do that."))
		return FALSE

	if(needs_foundation)
		if(!isturf(loc))
			if(!silent)
				to_chat(src, SPAN("danger", "I cannot do it here!"))
			return FALSE
		var/turf/T = get_turf(src)
		var/has_foundation
		if(T)
			//TODO: Work out the actual conditions this needs.
			if(!(istype(T, /turf/space)))
				has_foundation = 1
		if(!has_foundation)
			if(!silent)
				to_chat(src, SPAN("danger", "I need a solid foundation to do that on."))
			return FALSE

	P.stored_plasma -= cost
	return TRUE

// Free abilities.
/mob/living/carbon/human/proc/transfer_plasma(mob/living/carbon/human/M = null)
	set name = "Transfer Plasma"
	set desc = "Transfer Plasma to another alien"
	set category = "Abilities"

	if(!M)
		var/list/choices = list()
		for(var/mob/living/carbon/human/H in view(1, src))
			var/obj/item/organ/internal/xenos/plasmavessel/I = H.internal_organs_by_name[BP_PLASMA]
			if(istype(I))
				choices += H
		choices -= src
		M = input(src, "Whom do I wish to share plasma with?") as null|anything in choices

	if(!M || !ishuman(M))
		return

	if(!Adjacent(M))
		to_chat(src, SPAN("alium", "I need to be closer."))
		return

	if(!M.check_alien_ability(0, BP_PLASMA, FALSE, TRUE))
		to_chat(src, SPAN("alium", "They've got no functioning plasma vessel!"))
		return

	var/amount = input("Amount:", "Transfer Plasma to [M]") as num
	if(amount)
		amount = abs(round(amount))
		if(check_alien_ability(amount, BP_PLASMA))
			M.gain_plasma(amount)
			to_chat(M, SPAN("alium", "[src] has transfered [amount] plasma to me."))
			to_chat(src, SPAN("alium", "I have transferred [amount] plasma to [M]."))
	return

// Queen verbs.
/mob/living/carbon/human/proc/lay_egg()
	set name = "Lay Egg (75)"
	set desc = "Lay an egg to produce huggers to impregnate prey with."
	set category = "Abilities"

	if(locate(/obj/structure/alien/egg) in get_turf(src))
		to_chat(src, SPAN("alium", "There's already an egg here."))
		return

	if(check_alien_ability(75, BP_EGG, TRUE))
		visible_message(SPAN("alium", "<B>[src] has laid an egg!</B>"))
		new /obj/structure/alien/egg(loc)

	return

// Drone verbs.
/mob/living/carbon/human/proc/evolve()
	set name = "Evolve (500)"
	set desc = "Produce an interal egg sac capable of spawning children. Only one queen can exist at a time."
	set category = "Abilities"

	if(alien_queen_exists())
		to_chat(src, SPAN("notice", "I already have a queen to obey!"))
		return

	if(check_alien_ability(500))
		visible_message(
		                SPAN("alium", "<B>[src] begins to twist and contort!</B>"),
		                SPAN("alium", "I begin to evolve!")
		               )
		set_species(SPECIES_XENO_QUEEN)

	return

/mob/living/carbon/human/proc/plant()
	set name = "Plant Weeds (50)"
	set desc = "Plants some alien weeds"
	set category = "Abilities"

	if(check_alien_ability(50, BP_RESIN, TRUE))
		visible_message(SPAN("alium", "<B>[src] has planted some alien weeds!</B>"))
		new /obj/effect/alien/weeds/node(loc)
	return

/mob/living/carbon/human/proc/toggle_spit()
	set category = "Abilities"
	set name = "Set Spit"
	set desc = "Spit of your choice to be launched at someone (Mouse Wheel)."

	if(!src || src.stat)
		return
	active_ability = HUMAN_POWER_SPIT
	to_chat(src, "Selected special ability: <b>[active_ability]</b>.")

/mob/living/carbon/human/proc/spit()
	set name = "Spit (25)"
	set desc = "Spit of your choice to be launched at someone."
	set category = "Abilities"

	var/mob/living/target
	var/list/mob/living/targets = list()
	for(var/mob/living/L in oview(7, src))
		targets += L
	target = input(src, "Who do you wish to spit at?") as null|anything in targets

	process_spit(target)

/mob/living/carbon/human/proc/process_spit(mob/T)
	if(!T || !src || src.stat)
		return

	if(incapacitated(INCAPACITATION_DISABLED))
		to_chat(src, SPAN("warning", "I cannot spit in my current state."))
		return

	if(!spitting)
		to_chat(src, "I must choose a spit type first.")
		return

	if(!isturf(loc))
		to_chat(src, SPAN("danger", "I cannot spit from here!"))
		return

	if((last_spit + 2 SECONDS) > world.time) //To prevent YATATATATATAT spitting.
		to_chat(src, SPAN("warning", "I have not yet prepared my chemical glands. I must wait before spitting again."))
		return

	if(!check_alien_ability(25, BP_ACID, FALSE, TRUE))
		return
	last_spit = world.time
	visible_message(SPAN("warning", "[src] spits [spit_name] at \the [T]!"), SPAN("alium", "You spit [spit_name] at \the [T]."))
	var/obj/item/projectile/P = new spit_projectile(get_turf(src))
	P.launch(T, get_organ_target())
	playsound(loc, 'sound/weapons/pierce.ogg', 25, 0)

/mob/living/carbon/human/proc/corrosive_acid(O as obj|turf in oview(1)) //If they right click to corrode, an error will flash if its an invalid target./N
	set name = "Corrosive Acid (200)"
	set desc = "Drench an object in acid, destroying it over time."
	set category = "Abilities"

	if(!(O in oview(1)))
		to_chat(src, SPAN("alium", "[O] is too far away."))
		return

	// OBJ CHECK
	var/cannot_melt
	if(isobj(O))
		var/obj/I = O
		if(I.unacidable)
			cannot_melt = 1
	else
		if(istype(O, /turf/simulated/wall))
			var/turf/simulated/wall/W = O
			if(W.material.flags & MATERIAL_UNMELTABLE)
				cannot_melt = 1
		else if(istype(O, /turf/simulated/floor))
			cannot_melt = 1

	if(cannot_melt)
		to_chat(src, SPAN("alium", "I cannot dissolve this object."))
		return

	if(check_alien_ability(200, BP_ACID, FALSE))
		new /obj/effect/acid(get_turf(O), O)
		visible_message(SPAN("alium", "<B>[src] vomits globs of vile stuff all over [O]. It begins to sizzle and melt under the bubbling mess of acid!</B>"))

	return

/mob/living/carbon/human/proc/toggle_neurotoxin()
	set name = "Set Neurotoxic Spit (40)"
	set desc = "Readies a neurotoxic spit, which paralyzes the target for a short time if they are not wearing protective gear."
	set category = "Abilities"

	if(!check_alien_ability(40, BP_ACID))
		spitting = 0
		return
	last_spit = world.time
	spitting = 1
	spit_projectile = /obj/item/projectile/energy/neurotoxin
	spit_name = "neurotoxin"
	active_ability = HUMAN_POWER_SPIT
	to_chat(src, SPAN("notice", "<i>Selected special ability: <b>[active_ability] ([spit_name])</b>.</i>"))

/mob/living/carbon/human/proc/toggle_acidspit()
	set name = "Set Acid Spit (50)"
	set desc = "Readies an acidic spit, which burns the target if they are not wearing protective gear."
	set category = "Abilities"

	if(!check_alien_ability(50, BP_ACID))
		spitting = 0
		return
	last_spit = world.time
	spitting = 1
	spit_projectile = /obj/item/projectile/energy/acid
	spit_name = "acid"
	active_ability = HUMAN_POWER_SPIT
	to_chat(src, SPAN("notice", "<i>Selected special ability: <b>[active_ability] ([spit_name])</b>.</i>"))

/mob/living/carbon/human/proc/resin() // -- TLE
	set name = "Secrete Resin (75)"
	set desc = "Secrete tough malleable resin."
	set category = "Abilities"

	var/choice = input("Choose what you wish to shape.", "Resin building") as null|anything in list("resin door", "resin wall", "resin membrane", "resin nest") //would do it through typesof but then the player choice would have the type path and we don't want the internal workings to be exposed ICly - Urist
	if(!choice)
		return

	if(!check_alien_ability(75, BP_RESIN, TRUE))
		return

	visible_message(
	                SPAN("danger", "<B>[src] vomits up a thick purple substance and begins to shape it!</B>"),
	                SPAN("alium", "I shape a [choice].")
	               )
	switch(choice)
		if("resin door")
			new /obj/machinery/door/unpowered/simple/resin(loc)
		if("resin wall")
			new /obj/structure/alien/resin/wall(loc)
		if("resin membrane")
			new /obj/structure/alien/resin/membrane(loc)
		if("resin nest")
			new /obj/structure/bed/nest(loc)
	return

/mob/living/carbon/human/proc/gut()
	set category = "Abilities"
	set name = "Gut"
	set desc = "While grabbing someone aggressively, rip their guts out or tear them apart."

	if(last_special > world.time)
		to_chat(src, SPAN("warning", "You cannot gut so soon!"))
		return

	if(stat || paralysis || stunned || weakened || lying)
		to_chat(src, SPAN("warning", "I cannot do that in my current state."))
		return

	var/obj/item/grab/G = locate() in src
	if(!G || !istype(G))
		to_chat(src, SPAN("warning", "I have no prey to gut."))
		return

	if(G.type_name < NAB_AGGRESSIVE)
		to_chat(src, SPAN("warning", "I must have a firmer grab on my prey!"))
		return

	last_special = world.time + 50

	visible_message(SPAN("danger", "<b>\The [src]</b> rips viciously at \the [G.affecting]'s body with its claws!"))

	if(istype(G.affecting,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = G.affecting
		H.apply_damage(50, BRUTE)
		if(H.stat == 2)
			H.gib()

	else
		var/mob/living/M = G.affecting
		if(!istype(M))
			return //wut
		M.apply_damage(50, BRUTE)
		if(M.stat == 2)
			M.gib()

/mob/living/carbon/proc/toggle_darksight()
	set category = "Abilities"
	set name = "Toggle Darkvision"

	var/mob/living/carbon/C = src
	C.seeDarkness = !C.seeDarkness
	if(C.seeDarkness)
		to_chat(C, SPAN("notice", "Now I'm ready to hunt."))
	else
		to_chat(C, SPAN("notice", "Now I see what the victim sees."))
	return TRUE
