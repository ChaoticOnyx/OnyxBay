/obj/item/organ/internal/heart/gland/metroid
	abductor_hint = "gastric animation galvanizer. The abductee occasionally vomits metroids. Metroids will no longer attack the abductee."
	cooldown_low = 600
	cooldown_high = 1200
	uses = 3
	icon_state = "slime"
	mind_control_uses = 1
	mind_control_duration = 2400

/obj/item/organ/internal/heart/gland/metroid/activate()
	to_chat(owner, SPAN_WARNING("You feel nauseated!"))
	owner.vomit()

	var/mob/living/carbon/metroid/metroid = new(get_turf(owner))
	metroid.Friends |= (list(owner))
	metroid.Leader = owner
