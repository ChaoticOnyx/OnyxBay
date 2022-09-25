/mob/living
	var/hiding

/mob/living/proc/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Abilities"

	if(incapacitated())
		return

	THROTTLE_SHARED(cooldown, 5 SECONDS, last_special)
	if(!cooldown)
		to_chat(src, SPAN_WARNING("You need to wait a bit!"))
		return

	hiding = !hiding
	if(hiding)
		to_chat(src, "<span class='notice'>You are now hiding.</span>")
	else
		to_chat(src, "<span class='notice'>You have stopped hiding.</span>")
	reset_layer()

/mob/living/proc/breath_death()
	set name = "Breath Death"
	set desc = "Infect others with your very breath."
	set category = "Abilities"

	if (last_special > world.time)
		to_chat(src, SPAN("warning", "You aren't ready to do that! Wait [round(last_special - world.time) / 10] seconds."))
		return

	if (incapacitated(INCAPACITATION_DISABLED))
		to_chat(src, SPAN("warning", "You can't do that while you're incapacitated!"))
		return

	last_special = world.time + 5 SECONDS

	var/turf/T = get_turf(src)
	var/obj/effect/effect/water/chempuff/chem = new(T)
	chem.create_reagents(10)
	chem.reagents.add_reagent(/datum/reagent/toxin/zombie, 2)
	chem.set_up(get_step(T, dir), 2, 10)
	playsound(T, 'sound/hallucinations/wail.ogg', 20, 1)
