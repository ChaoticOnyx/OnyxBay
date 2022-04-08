/mob/living/carbon/metroid/regenerate_icons()
	if (stat == DEAD)
		icon_state = "[colour] baby metroid dead"
	else
		icon_state = "[colour] [is_adult ? "adult" : "baby"] metroid[Victim ? " eat" : ""]"
	overlays.len = 0
	if (mood)
		overlays += image('icons/mob/metroids.dmi', icon_state = "ametroid-[mood]")
	..()
