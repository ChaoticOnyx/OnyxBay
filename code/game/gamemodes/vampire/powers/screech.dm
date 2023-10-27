
// Chiropteran Screech
/datum/vampire_power/screech
	name = "Chiropteran Screech"
	desc = "Emit a powerful screech which shatters glass within a seven-tile radius, and stuns hearers in a four-tile radius."
	icon_state = "vamp_screech"
	blood_cost = 70

/datum/vampire_power/screech/activate()
	if(!..())
		return

	my_mob.visible_message(SPAN("danger", "[my_mob] lets out an ear-piercing shriek!"),\
						   SPAN("danger", "You let out an ear-shattering shriek!"),\
						   SPAN("danger", "You hear a painfully loud shriek!"))

	var/list/victims = list()

	for(var/mob/living/carbon/human/T in hearers(4, my_mob))
		if(T == my_mob)
			continue
		if(T.get_ear_protection() > 2)
			continue
		if(!vampire.can_affect(T, FALSE))
			continue

		to_chat(T, SPAN("danger", "You hear an ear piercing shriek and feel your senses go dull!"))
		T.Weaken(5)
		T.ear_deaf = 20
		T.stuttering = 20
		T.Stun(5)

		victims += T

	for(var/obj/structure/window in view(7))
		W.ex_act(2)

	for(var/obj/structure/window_frame/W in view(7))
		W.ex_act(2)

	for(var/obj/machinery/light/L in view(7))
		L.broken()

	playsound(my_mob.loc, 'sound/effects/creepyshriek.ogg', 100, 1)
	use_blood()

	if(victims.len)
		admin_attacker_log_many_victims(my_mob, victims, "used chriopteran screech to stun", "was stunned by [key_name(my_mob)] using chriopteran screech", "used chiropteran screech to stun")
	else
		log_and_message_admins("used chiropteran screech.")

	set_cooldown(180 SECONDS)
