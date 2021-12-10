
/datum/map/exodus/helltier
	name = "Helltier"
	full_name = "NSS Helltier"
	path = "exodus/helltier2021"

	station_levels = list(1)
	admin_levels = list(3)
	contact_levels = list(1,4)
	player_levels = list(1,4,5,7,12)
	sealed_levels = list(12)
	empty_levels = list()
	accessible_z_levels = list("1" = 10, "4" = 10, "5" = 15, "7" = 60)
	//base_turf_by_z = list("1" = /turf/simulated/floor/asteroid) // Moonbase
	dynamic_z_levels = list("1" = 'helltier-1.dmm',"3" = 'helltier-3.dmm')

	station_name  = "NSS Helltier"
	station_short = "Helltier"
	dock_name     = "NAS Pumpkin"
	boss_name     = "Skeletal Commander"
	boss_short    = "Skeleton"
	company_name  = "NanoTrasen"
	company_short = "NT"
	system_name   = "Arcturus"

/datum/map/exodus/helltier/perform_map_generation()
	new /datum/random_map/automata/cave_system(null, 1, 1, 1, 300, 300) // Create the mining Z-level.
	new /datum/random_map/noise/ore(null, 1, 1, 1, 300, 300)            // Create the mining ore distribution map.
	return 1


/obj/structure/screamer
	name = "anomaly"
	desc = "Anomaly of some sort."
	icon_state = "skull_human_alt"
	icon = 'icons/obj/items.dmi'
	anchored = TRUE
	density = FALSE
	invisibility = 101
	layer = 0
	var/triggered = FALSE
	var/scream_prob_before = 10 // Has never been triggered yet
	var/scream_prob_after  = 2  // Already triggered, much less active now

/obj/structure/screamer/Crossed(atom/A)
	if(!istype(A, /mob/living))
		return
	var/mob/living/L = A
	if(!L.client)
		return
	if((!triggered && prob(scream_prob_before)) || prob(scream_prob_after))
		var/sound_to_play
		if(prob(70))
			sound_to_play = pick(
				'sound/voice/MEraaargh.ogg',
				'sound/voice/hiss6.ogg',
				'sound/voice/doomsky3.ogg',
				'sound/voice/BugHiss.ogg',
				'sound/voice/shriek1.ogg',
				'sound/hallucinations/wail.ogg',
				'sound/effects/changeling/centipede.ogg',
				'sound/effects/changeling/centipededeath.ogg',
				'sound/items/trayhit2.ogg',
				'sound/items/Ratchet.ogg',
				'sound/effects/angrybug.ogg',
				'sound/effects/creepyshriek.ogg',
				'sound/effects/ghost.ogg',
				'sound/effects/ghost2.ogg',
				'sound/effects/breaking/console/break1.ogg',
				'sound/effects/breaking/console/break2.ogg',
				'sound/effects/breaking/console/break3.ogg',
				'sound/effects/breaking/window/break1.ogg',
				'sound/effects/breaking/window/break2.ogg',
				'sound/effects/breaking/window/break3.ogg',)
		else
			sound_to_play = pick(
				'sound/hallucinations/growl1.ogg',
				'sound/hallucinations/growl2.ogg',
				'sound/hallucinations/growl3.ogg',
				'sound/hallucinations/behind_you1.ogg',
				'sound/hallucinations/behind_you2.ogg',
				'sound/hallucinations/look_up1.ogg',
				'sound/hallucinations/look_up2.ogg',
				'sound/hallucinations/far_noise.ogg',
				'sound/hallucinations/look_up1.ogg')

		playsound(L, sound_to_play, 100, 1)
		triggered = TRUE
	..()
