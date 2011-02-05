obj/bodybag
	icon = 'bodybag.dmi'
	icon_state = "b00"
	desc = "A body bag designed to contain those with a less fortunate fate."
	name = "body bag"
	var/mob/captured
	var/writhe_time = 0
	var/open = 0

/obj/bodybag/alterMobEmote(var/message, var/type, var/m_type, var/mob/living/user)
	if(m_type == 1) // visible emote, disabled here
		return ""
	else			// auditive emote, enabled here
		return "You hear an unintelligible sound coming from somewhere nearby."

	..()

/obj/bodybag/overrideMobSay(var/message, var/mob/living/user)
	user << "You try to say \"[message]\"."
	message = stars(message, 50)
	for(var/mob/M in hearers(null, src))
		M.show_message("You hear \"[message]\" coming from somewhere nearby.", 2)

/obj/bodybag/relaymove(mob/user as mob)
	if(user.stat)
		return
	if (open == 0 && world.timeofday - writhe_time >= 20)
		user << "\blue You are stuck inside!"
		for(var/mob/M in viewers(null, src))
			M << text("<FONT size=[]>The bodybag writhes!</FONT>", max(0, 4 - get_dist(src, M)))

		user.unlock_medal("It's a trap!", 0, "Get locked or welded into a locker...", "easy")
		writhe_time = world.timeofday

		return
	return

obj/bodybag/attack_hand(mob/user)
	src.add_fingerprint(user)

	if(open)
		close()
	else
		open()

obj/bodybag/proc/open()
	if(captured)
		captured.loc = src.loc
		captured = null
	open = 1
	icon_state = "b[open]0"

obj/bodybag/proc/close()
	for (var/obj/item/I in src.loc)
		if (!I.anchored)
			I.loc = src

	for(var/mob/M in src.loc)
		if(M.lying)
			captured = M
			M.loc = src
			break

	var/hasmob = 0
	open = 0
	if(captured) hasmob=1
	icon_state = "b[open][hasmob]"