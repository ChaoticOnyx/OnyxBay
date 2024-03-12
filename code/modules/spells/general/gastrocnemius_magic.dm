
/datum/spell/gastrocnemius_magic
	name = "Gastrocnemius Magic"
	desc = "Stomp the floor with everything your calves have to offer."
	spell_flags = 0
	charge_max = 15 SECONDS

	invocation = "GASTROCNEMIUS! SOLEUS!"
	invocation_type = SPI_SHOUT

	range = 0
	icon_state = "wiz_gastrocnemius"

/datum/spell/gastrocnemius_magic/cast(list/targets, mob/living/carbon/user)
	user.remove_nutrition(50)
	user.visible_message(SPAN("danger", "[user] stomps the floor!"))

	for(var/mob/M in GLOB.player_list)
		if(M.client && !M.stat && M.z == user.z)
			shake_camera(M, 5, 1)

	var/list/victims = list()
	for(var/mob/living/L in view(5, user))
		L.Weaken(6)
		L.Stun(3)
		L.throw_at(get_turf(L), 5, 1, src)
		victims += L
		if(L.client && !L.stat)
			to_chat(L, SPAN("danger", "You are sent flying!"))
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			H.damage_poise(25)

	admin_attacker_log_many_victims(user, victims, "used Gastrocnemius Magic to stun", "was stunned by [key_name(user)] using Gastrocnemius Magic", "used Gastrocnemius Magic to stun")
