
// Convert a human into a vampire.
/datum/vampire_power/embrace
	name = "The Embrace"
	desc = "Spread your corruption to an innocent soul, turning them into a spawn of the Veil, much akin to yourself."
	icon_state = "vamp_embrace"
	blood_cost = 120

/datum/vampire_power/embrace/activate()
	if(!..())
		return
	// Re-using blood drain code.
	var/obj/item/grab/G = my_mob.get_active_hand()
	if(!istype(G))
		to_chat(my_mob, SPAN("warning", "You must be grabbing a victim in your active hand to drain their blood"))
		return
	if(!G.can_absorb())
		to_chat(my_mob, SPAN("warning", "You must have a tighter grip on victim to drain their blood."))
		return

	var/mob/living/carbon/human/T = G.affecting
	if(!vampire.can_affect(T, check_thrall = FALSE))
		return

	if(!T.client)
		to_chat(my_mob, SPAN("warning", "[T] is a mindless husk. The Veil has no purpose for them."))
		return

	if(T.is_ic_dead())
		to_chat(my_mob, SPAN("warning", "[T]'s body is broken and damaged beyond salvation. You have no use for them."))
		return

	if(T.isSynthetic() || T.species.species_flags & SPECIES_FLAG_NO_BLOOD)
		to_chat(my_mob, SPAN("warning", "[T] has no blood and can not be affected by your powers!"))
		return

	if(vampire.vamp_status & VAMP_DRAINING)
		to_chat(my_mob, SPAN("warning", "Your fangs are already sunk into a victim's neck!"))
		return

	if(jobban_isbanned(T, MODE_VAMPIRE))
		to_chat(my_mob, SPAN_WARNING("[T]'s mind is tainted. They cannot be forced into a blood bond."))
		return

	if(T.mind.vampire)
		var/datum/vampire/draining_vamp = T.mind.vampire

		if(draining_vamp.vamp_status & VAMP_ISTHRALL)
			var/choice_text = ""
			var/denial_response = ""
			if(draining_vamp.master?.resolve() == my_mob)
				choice_text = "[T] is your thrall. Do you wish to release them from the blood bond and give them the chance to become your equal?"
				denial_response = "You opt against giving [T] a chance to ascend, and choose to keep them as a servant."
			else
				choice_text = "You can feel the taint of another master running in the veins of [T]. Do you wish to release them of their blood bond, and convert them into a vampire, in spite of their master?"
				denial_response = "You choose not to continue with the Embrace, and permit [T] to keep serving their master."

			if(alert(my_mob, choice_text, "Choices", "Yes", "No") == "No")
				to_chat(my_mob, SPAN("notice", "[denial_response]"))
				return

			GLOB.thralls.remove_antagonist(T.mind, 0, 0)
			draining_vamp.vamp_status &= ~VAMP_ISTHRALL
		else
			to_chat(my_mob, SPAN("warning", "You feel corruption running in [T]'s blood. Much like yourself, \he[T] is already a spawn of the Veil, and cannot be Embraced."))
			return

	vampire.vamp_status |= VAMP_DRAINING

	my_mob.visible_message(SPAN("danger", "[my_mob] bites [T]'s neck!"),\
						   SPAN("danger", "You bite [T]'s neck and begin to drain their blood, as the first step of introducing the corruption of the Veil to them."),\
						   SPAN("notice", "You hear a soft puncture and a wet sucking noise."))

	to_chat(T, SPAN("notice", "You are currently being turned into a vampire. You will die in the course of this, but you will be revived by the end. Please do not ghost out of your body until the process is complete."))

	while(do_mob(my_mob, T, 50))
		if(!my_mob.mind.vampire)
			to_chat(my_mob, SPAN("alert", "Your fangs have disappeared!"))
			return
		if (!T.vessel.get_reagent_amount(/datum/reagent/blood))
			to_chat(my_mob, SPAN("alert", "[T] is now drained of blood. You begin forcing your own blood into their body, spreading the corruption of the Veil to their body."))
			break

		T.vessel.remove_reagent(/datum/reagent/blood, 50)

	if(!istype(T))
		vampire.vamp_status &= ~VAMP_DRAINING
		return

	if(T.isSynthetic() || T.species.species_flags & SPECIES_FLAG_NO_BLOOD)
		to_chat(my_mob, SPAN("warning", "[T] has no blood and can not be affected by your powers!"))
		vampire.vamp_status &= ~VAMP_DRAINING
		return

	if(jobban_isbanned(T, MODE_VAMPIRE))
		to_chat(my_mob, SPAN_WARNING("[T]'s mind is tainted. They cannot be forced into a blood bond."))
		vampire.vamp_status &= ~VAMP_DRAINING
		return

	T.revive()

	// You ain't goin' anywhere, bud.
	if(!T.client && T.mind)
		for(var/mob/ghost in GLOB.player_list)
			if(ghost.mind == T.mind)
				ghost.mind.transfer_to(T)
				to_chat(T, SPAN("danger", "A dark force pushes you back into your body. You find yourself somehow still clinging to life."))

	T.Weaken(15)
	T.Stun(15)
	var/datum/antagonist/vampire/VAMP = GLOB.all_antag_types_[MODE_VAMPIRE]
	if(!VAMP.add_antagonist(T.mind, 1, 1, 0, 0, 1))
		to_chat(my_mob, SPAN("warning", "[T] is not a creature you can embrace."))
		return

	admin_attack_log(my_mob, T, "successfully embraced [key_name(T)]", "was successfully embraced by [key_name(my_mob)]", "successfully embraced and turned into a vampire")

	to_chat(T, SPAN("danger", "You awaken. Moments ago, you were dead, your conciousness still forced stuck inside your body. Now you live. You feel different, a strange, dark force now present within you. You have an insatiable desire to drain the blood of mortals, and to grow in power."))
	to_chat(my_mob, SPAN("warning", "You have corrupted another mortal with the taint of the Veil. Beware: they will awaken hungry and maddened; not bound to any master."))

	T.mind.vampire.use_blood(T.mind.vampire.blood_usable)
	T.mind.vampire.frenzy = 50
	T.mind.vampire.check_frenzy()

	vampire.vamp_status &= ~VAMP_DRAINING
	use_blood()
