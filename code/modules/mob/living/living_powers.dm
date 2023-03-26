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
