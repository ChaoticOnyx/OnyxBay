/mob
	//thou shall always be able to see the Geometer of Blood
	var/image/narsimage = null
	var/image/narglow = null

/mob/proc/cultify()
	return

/mob/observer/ghost/cultify()
	if(icon_state != "ghost-narsie")
		icon = 'icons/mob/mob.dmi'
		icon_state = "ghost-narsie"
		overlays = 0
		set_invisibility(0)
		to_chat(src, "<span class='sinister'>Even as a non-corporal being, you can feel Nar-Sie's presence altering you. You are now visible to everyone.</span>")

/mob/living/cultify()
	if(iscultist(src) && client)
		var/mob/living/simple_animal/construct/harvester/C = new(get_turf(src))
		mind.transfer_to(C)
		to_chat(C, "<span class='sinister'>The Geometer of Blood is overjoyed to be reunited with its followers, and accepts your body in sacrifice. As reward, you have been gifted with the shell of an Harvester.<br>Your tendrils can use and draw runes without need for a tome, your eyes can see beings through walls, and your mind can open any door. Use these assets to serve Nar-Sie and bring him any remaining living human in the world.<br>You can teleport yourself back to Nar-Sie along with any being under yourself at any time using your \"Harvest\" spell.</span>")
		dust()
	else if(client)
		var/mob/observer/ghost/G = (ghostize())
		G.icon = 'icons/mob/mob.dmi'
		G.icon_state = "ghost-narsie"
		G.overlays = 0
		G.set_invisibility(0)
		to_chat(G, "<span class='sinister'>You feel relieved as what's left of your soul finally escapes its prison of flesh.</span>")
	else
		dust()
