/datum/deity_power/phenomena/burning_glare
	name = "Burning Glare"
	desc = "Burn a victim. If they are burnt enough, you'll set them ablaze."
	expected_type = /mob/living

/datum/deity_power/phenomena/burning_glare/manifest(atom/target, mob/living/deity/D)
	if(!..())
		return

	var/mob/living/L = target
	to_chat(L, SPAN_DANGER("You are burning!"))
	L.adjustFireLoss(10)
	if(L.getFireLoss() > 60)
		L.fire_stacks += 50
		L.IgniteMob()
