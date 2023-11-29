
// Makes the vampire appear 'friendlier' to others.
/datum/vampire_power/toggled/presence
	name = "Presence"
	desc = "Influences those weak of mind to look at you in a friendlier light."
	icon_state = "vamp_presence"
	blood_cost = 5
	blood_drain = 1

	text_activate = "You begin passively influencing the weak minded."
	text_deactivate = "You are no longer influencing those weak of mind."
	text_noblood = "You stop passively influencing the weak minded because you run out of blood."

	var/datum/vampire_presence_handler/handler = null

/datum/vampire_power/toggled/presence/Destroy()
	QDEL_NULL(handler)
	return ..()

/datum/vampire_power/toggled/presence/activate()
	if(!..())
		return
	QDEL_NULL(handler)
	handler = new /datum/vampire_presence_handler(src)
	log_and_message_admins("activated presence.")

/datum/vampire_power/toggled/presence/deactivate(no_message = TRUE)
	if(!..())
		return
	QDEL_NULL(handler)


/datum/vampire_presence_handler
	var/datum/vampire_power/toggled/presence/my_power = null

/datum/vampire_presence_handler/New(datum/vampire_power/toggled/presence/_my_power)
	my_power = _my_power
	set_next_think(world.time)

/datum/vampire_presence_handler/Destroy()
	my_power = null
	set_next_think(0)
	return ..()

/datum/vampire_presence_handler/think()
	if(!my_power?.active)
		qdel_self()
		return

	var/list/mob/living/carbon/human/affected = list()
	var/list/emotes = list("[my_power.my_mob] looks trusthworthy.",
							"You feel as if [my_power.my_mob] is a relatively friendly individual.",
							"You feel yourself paying more attention to what [my_power.my_mob] is saying.",
							"[my_power.my_mob] has your best interests at heart, you can feel it.")

	for(var/mob/living/carbon/human/T in view(5))
		if(T == my_power.my_mob)
			continue
		if(!my_power.vampire.can_affect(T, FALSE, TRUE))
			continue
		if(!T.client)
			continue

		var/probability = 50
		if(!(T in affected))
			affected += T
			probability = 80

		if(prob(probability))
			to_chat(T, "<font color='green'><i>[pick(emotes)]</i></font>")

	set_next_think(world.time + 20 SECONDS)
