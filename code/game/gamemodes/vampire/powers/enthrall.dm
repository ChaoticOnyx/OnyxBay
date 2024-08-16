
// Enthralls a person, giving the vampire a mortal slave.
/datum/vampire_power/enthrall
	name = "Enthrall"
	desc = "Bind a mortal soul with a bloodbond to obey your every command."
	icon_state = "vamp_enthrall"
	blood_cost = 120

/datum/vampire_power/enthrall/activate()
	if(!..())
		return

	var/obj/item/grab/G = my_mob.get_active_hand()
	if(!istype(G))
		to_chat(my_mob, SPAN("warning", "You must be grabbing a victim in your active hand to enthrall them."))
		return
	if(!G.can_absorb())
		to_chat(my_mob, SPAN("warning", "You must have a tighter grip on victim to enthrall them."))
		return

	var/mob/living/carbon/human/T = G.affecting
	if(!istype(T) || T.isSynthetic())
		to_chat(my_mob, SPAN("warning", "[T] is not a creature you can enthrall."))
		return

	if(!vampire.can_affect(T, TRUE, TRUE))
		return

	if(!T.client || !T.mind)
		to_chat(my_mob, SPAN("warning", "[T]'s mind is empty and useless. They cannot be forced into a blood bond."))
		return

	if(vampire.vamp_status & VAMP_DRAINING)
		to_chat(my_mob, SPAN("warning", "Your fangs are already sunk into a victim's neck!"))
		return

	if(jobban_isbanned(T, MODE_THRALL))
		to_chat(my_mob, SPAN_WARNING("[T]'s mind is tainted. They cannot be forced into a blood bond."))
		return

	my_mob.visible_message(SPAN("danger", "[my_mob] tears the flesh on their wrist, and holds it up to [T]. In a gruesome display, [T] starts lapping up the blood that's oozing from the fresh wound."),\
						   SPAN("warning", "You inflict a wound upon yourself, and force them to drink your blood, thus starting the conversion process"))
	to_chat(T, SPAN("warning", "You feel an irresistable desire to drink the blood pooling out of [my_mob]'s wound. Against your better judgement, you give in and start doing so."))

	if(!do_mob(my_mob, T, 50))
		my_mob.visible_message(SPAN("warning", "[my_mob] yanks away their hand from [T]'s mouth as they're interrupted, the wound quickly sealing itself!"),\
							   SPAN("danger", "You are interrupted!"))
		return

	if(!istype(T) || T.isSynthetic())
		to_chat(my_mob, SPAN("warning", "[T] is not a creature you can enthrall."))
		return

	if(!vampire.can_affect(T, TRUE, TRUE))
		return

	if(!T.client || !T.mind)
		to_chat(my_mob, SPAN("warning", "[T]'s mind is empty and useless. They cannot be forced into a blood bond."))
		return

	to_chat(T, SPAN("danger", "Your mind blanks as you finish feeding from [my_mob]'s wrist."))
	if(!GLOB.thralls.add_antagonist(T.mind, 1, 1, 0, 1, 1))
		to_chat(my_mob, SPAN("warning", "[T] is not a creature you can enthrall."))
		return

	T.mind.vampire.master = weakref(my_mob)
	vampire.thralls += T
	to_chat(T, SPAN("notice", "You have been forced into a blood bond by [my_mob], and are thus their thrall. While a thrall may feel a myriad of emotions towards their master, ranging from fear, to hate, to love; the supernatural bond between them still forces the thrall to obey their master, and to listen to the master's commands.<br><br>You must obey your master's orders, you must protect them, you cannot harm them."))
	to_chat(my_mob, SPAN("notice", "You have completed the thralling process. They are now your slave and will obey your commands."))
	admin_attack_log(my_mob, T, "enthralled [key_name(T)]", "was enthralled by [key_name(my_mob)]", "successfully enthralled")

	use_blood()
	set_cooldown(240 SECONDS)
