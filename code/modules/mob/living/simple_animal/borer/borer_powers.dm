GLOBAL_LIST_INIT(borer_reagent_types_by_name, setup_borer_reagents())

/proc/setup_borer_reagents()
	. = list()
	for(var/reagent_type in list(/datum/reagent/alkysine, /datum/reagent/bicaridine, /datum/reagent/hyperzine, /datum/reagent/painkiller/tramadol))
		var/datum/reagent/R = reagent_type
		.[initial(R.name)] = reagent_type

#define BORER_ALL_ABILITIES \
list(\
"in_host" = list(\
/mob/living/simple_animal/borer/verb/release_host,\
/mob/living/simple_animal/borer/verb/secrete_chemicals,\
),\
"controlling" = list(\
/mob/living/carbon/proc/punish_host,\
/mob/living/carbon/proc/spawn_larvae,\
/mob/living/carbon/proc/release_control,\
),\
"not_controlling" = list(\
/mob/living/simple_animal/borer/verb/bond_brain,\
),\
"out_host" = list(\
/mob/living/simple_animal/borer/verb/infest,\
/mob/living/simple_animal/borer/verb/dominate_victim,\
/mob/living/proc/ventcrawl,\
/mob/living/proc/hide,\
),\
"husk" = list(\
/mob/living/carbon/human/proc/psychic_whisper,\
/mob/living/carbon/human/proc/tackle,\
/mob/living/carbon/proc/spawn_larvae,\
)\
)

/mob/living/simple_animal/borer/verb/release_host()
	set category = "Abilities"
	set name = "Release Host"
	set desc = "Slither out of your host."

	var/needed_location = "in_host"
	if(!can_use_abilities(needed_location))
		return

	to_chat(src, "You begin disconnecting from [host]'s synapses and prodding at their internal ear canal.")

	if(!host.stat)
		to_chat(host, "An odd, uncomfortable pressure begins to build inside your skull, behind your ear...")

	spawn(100)
		if(!can_use_abilities(needed_location))
			return

		to_chat(src, "You wiggle out of [host]'s ear and plop to the ground.")
		if(host.mind)
			if(!host.stat)
				to_chat(host, SPAN("danger", "Something slimy wiggles out of your ear and plops to the ground!"))
			else
				to_chat(host, SPAN("danger", "As though waking from a dream, you shake off the insidious mind control of the brain worm. Your thoughts are your own again."))
		detatch()
		leave_host()
		update_abilities()

/mob/living/simple_animal/borer/verb/infest()
	set category = "Abilities"
	set name = "Infest"
	set desc = "Infest a suitable humanoid host."

	var/needed_location = "out_host"
	if(!can_use_abilities(needed_location))
		return

	var/list/choices = list()
	for(var/mob/living/carbon/human/H in view(1,src))
		if(src.Adjacent(H))
			choices += H

	if(!choices.len)
		to_chat(src, "There are no viable hosts within range...")
		return

	var/mob/living/carbon/human/H = input(src,"Who do you wish to infest?") in null|choices

	if(!H || !src)
		return

	if(!(src.Adjacent(H)))
		return

	if(H.has_brain_worms())
		to_chat(src, "You cannot infest someone who is already infested!")
		return

	var/obj/item/organ/external/E = H.organs_by_name[BP_HEAD]
	if(!E || E.is_stump())
		to_chat(src, "\The [H] does not have a head!")
		return

	if(BP_IS_ROBOTIC(E))
		to_chat(src, "\The [H]'s head is not living!")
		return

	if(!H.should_have_organ(BP_BRAIN))
		to_chat(src, "\The [H] does not seem to have an ear canal to breach.")
		return

	if(H.check_head_coverage())
		to_chat(src, "You cannot get through that host's protective gear.")
		return

	to_chat(H, "Something slimy begins probing at the opening of your ear canal...")
	to_chat(src, "You slither up [H] and begin probing at their ear canal...")

	if(!do_after(src,30, progress = 0))
		to_chat(src, "As [H] moves away, you are dislodged and fall to the ground.")
		return

	if(!H || !src)
		return

	if(src.stat)
		to_chat(src, "You cannot infest a target in your current state.")
		return

	if(H in view(1, src))
		to_chat(src, "You wiggle into [H]'s ear.")
		if(!H.stat)
			to_chat(H, "Something disgusting and slimy wiggles into your ear!")

		src.host = H
		src.host.status_flags |= PASSEMOTES
		src.loc = H

		//Update their traitor status.
		if(host.mind)
			GLOB.borers.add_antagonist_mind(host.mind, 1, GLOB.borers.faction_role_text, GLOB.borers.faction_welcome)

		update_abilities()

		var/obj/item/organ/I = H.internal_organs_by_name[BP_BRAIN]
		if(!I) // No brain organ, so the borer moves in and replaces it permanently.
			replace_brain()
		else
			// If they're in normally, implant removal can get them out.
			var/obj/item/organ/external/head = H.get_organ(BP_HEAD)
			head.implants |= src

	else
		to_chat(src, "They are no longer in range!")

/*
/mob/living/simple_animal/borer/verb/devour_brain()
	set category = "Abilities"
	set name = "Devour Brain"
	set desc = "Take permanent control of a dead host."

	if(!host)
		to_chat(src, "You are not inside a host body.")
		return

	if(host.stat != DEAD)
		to_chat(src, "Your host is still alive.")
		return

	if(stat)
		to_chat(src, "You cannot do that in your current state.")

	if(docile)
		to_chat(src, SPAN("notice", "You are feeling far too docile to do that."))
		return


	to_chat(src, SPAN("danger", "It only takes a few moments to render the dead host brain down into a nutrient-rich slurry..."))
	replace_brain()
*/

// BRAIN WORM ZOMBIES AAAAH.
/mob/living/simple_animal/borer/proc/replace_brain()

	var/mob/living/carbon/human/H = host

	if(!istype(host))
		to_chat(src, "This host does not have a suitable brain.")
		return

	to_chat(src, SPAN("danger", "You settle into the empty brainpan and begin to expand, fusing inextricably with the dead flesh of [H]."))

	H.add_language("Cortical Link")

	if(host.stat == DEAD)
		H.verbs |= /mob/living/carbon/human/proc/jumpstart

	H.verbs |= BORER_ALL_ABILITIES["husk"]

	if(H.client)
		H.ghostize(0)

	if(src.mind)
		src.mind.special_role = "Borer Husk"
		src.mind.transfer_to(host)

	H.ChangeToHusk()

	var/obj/item/organ/internal/borer/B = new(H)
	H.internal_organs_by_name[BP_BRAIN] = B
	H.internal_organs |= B

	var/obj/item/organ/external/affecting = H.get_organ(BP_HEAD)
	affecting.implants -= src

	var/s2h_id = src.computer_id
	var/s2h_ip= src.lastKnownIP
	src.computer_id = null
	src.lastKnownIP = null

	if(!H.computer_id)
		H.computer_id = s2h_id

	if(!H.lastKnownIP)
		H.lastKnownIP = s2h_ip

/mob/living/simple_animal/borer/verb/secrete_chemicals()
	set category = "Abilities"
	set name = "Secrete Chemicals"
	set desc = "Push some chemicals into your host's bloodstream."

	var/needed_location = "in_host"
	if(!can_use_abilities(needed_location))
		return

	if(chemicals < 50)
		to_chat(src, "You don't have enough chemicals!")
		return

	var/chem = input("Select a chemical to secrete.", "Chemicals") as null|anything in GLOB.borer_reagent_types_by_name

	if(!chem || chemicals < 50 || !can_use_abilities(needed_location) || controlling) //Sanity check.
		return

	to_chat(src, SPAN("danger", "You squirt a measure of [chem] from your reservoirs into \the [host]'s bloodstream."))
	host.reagents.add_reagent(GLOB.borer_reagent_types_by_name[chem], 10)
	chemicals -= 50

/mob/living/simple_animal/borer/verb/dominate_victim()
	set category = "Abilities"
	set name = "Paralyze Victim"
	set desc = "Freeze the limbs of a potential host with supernatural fear."

	var/needed_location = "out_host"
	if(!can_use_abilities(needed_location))
		return

	if(world.time - used_dominate < 150)
		to_chat(src, "You cannot use that ability again so soon.")
		return

	var/list/choices = list()
	for(var/mob/living/carbon/human/H in view(3,src))
		if(H.stat != DEAD)
			choices += H

	var/mob/living/carbon/human/H = input(src,"Who do you wish to dominate?") in null|choices

	if(world.time - used_dominate < 150)
		to_chat(src, "You cannot use that ability again so soon.")
		return

	if(!H || !src)
		return

	if(H.has_brain_worms())
		to_chat(src, "You cannot dominate someone who is already infested!")
		return

	to_chat(src, SPAN("warning", "You focus your psychic lance on [H] and freeze their limbs with a wave of terrible dread."))
	to_chat(H, SPAN("warning", "You feel a creeping, horrible sense of dread come over you, freezing your limbs and setting your heart racing."))
	H.Weaken(10)
	H.Stun(10)

	used_dominate = world.time

/mob/living/simple_animal/borer/verb/bond_brain()
	set category = "Abilities"
	set name = "Assume Control"
	set desc = "Fully connect to the brain of your host."

	var/needed_location = "not_controlling"
	if(!can_use_abilities(needed_location))
		return

	to_chat(src, "You begin delicately adjusting your connection to the host brain...")

	spawn(100+(host.getBrainLoss()*5))

		if(!can_use_abilities(needed_location))
			return

		to_chat(src, SPAN("danger", "You plunge your probosci deep into the cortex of the host brain, interfacing directly with their nervous system."))
		to_chat(host, SPAN("danger", "You feel a strange shifting sensation behind your eyes as an alien consciousness displaces yours."))
		host.add_language("Cortical Link")

		// host -> brain
		var/h2b_id = host.computer_id
		var/h2b_ip = host.lastKnownIP
		host.computer_id = null
		host.lastKnownIP = null

		host_brain = new(src)

		host_brain.ckey = host.ckey

		host_brain.SetName(host.name)

		if(!host_brain.computer_id)
			host_brain.computer_id = h2b_id

		if(!host_brain.lastKnownIP)
			host_brain.lastKnownIP = h2b_ip

		// self -> host
		var/s2h_id = src.computer_id
		var/s2h_ip = src.lastKnownIP
		src.computer_id = null
		src.lastKnownIP = null

		host.ckey = src.ckey

		if(!host.computer_id)
			host.computer_id = s2h_id

		if(!host.lastKnownIP)
			host.lastKnownIP = s2h_ip

		controlling = TRUE
		teleop = host
		update_abilities()

/mob/living/simple_animal/borer/proc/detatch()

	if(!host || !controlling)
		return

	if(host_brain)

		// these are here so bans and multikey warnings are not triggered on the wrong people when ckey is changed.
		// computer_id and IP are not updated magically on their own in offline mobs -walter0o

		// host -> self
		var/h2s_id = host.computer_id
		var/h2s_ip = host.lastKnownIP
		host.computer_id = null
		host.lastKnownIP = null

		src.ckey = host.ckey

		if(!src.computer_id)
			src.computer_id = h2s_id

		if(!host_brain.lastKnownIP)
			src.lastKnownIP = h2s_ip

		// brain -> host
		var/b2h_id = host_brain.computer_id
		var/b2h_ip = host_brain.lastKnownIP
		host_brain.computer_id = null
		host_brain.lastKnownIP = null

		host.ckey = host_brain.ckey

		if(!host.computer_id)
			host.computer_id = b2h_id

		if(!host.lastKnownIP)
			host.lastKnownIP = b2h_ip
	QDEL_NULL(host_brain)

	controlling = FALSE
	teleop = null
	host.remove_language("Cortical Link")
	update_abilities()

/mob/living/simple_animal/borer/proc/leave_host()

	if(!host)
		return

	if(host.mind)
		GLOB.borers.remove_antagonist(host.mind)

	var/mob/living/carbon/human/H = host
	var/obj/item/organ/external/head = H.get_organ(BP_HEAD)
	head.implants -= src

	src.loc = get_turf(host)

	reset_view(null)
	unset_machine()

	H.reset_view(null)
	H.unset_machine()

	H.status_flags &= ~PASSEMOTES
	host = null
	update_abilities()

/mob/living/carbon/human/proc/jumpstart()
	set category = "Abilities"
	set name = "Revive Host"
	set desc = "Send a jolt of electricity through your host, reviving them."

	verbs -= /mob/living/carbon/human/proc/jumpstart

	if(stat != DEAD)
		to_chat(usr, "Your host is already alive.")
		return

	visible_message(SPAN("warning", "With a hideous, rattling moan, [src] shudders back to life!"))

	rejuvenate()
	restore_blood()
	fixblood()
	update_canmove()

/mob/living/simple_animal/borer/proc/can_use_abilities(needed_location)
	if(!src)
		return FALSE

	switch(needed_location)
		if("in_host")
			if(!host)
				to_chat(src, "You are not inside a host body.")
				return FALSE
		if("out_host")
			if(host)
				to_chat(src, "You cannot do that from within a host body.")
				return FALSE
		if("controlling")
			if(!host)
				to_chat(src, "You are not inside a host body.")
				return FALSE
			if(!controlling)
				to_chat(src, "You need control a host body to do it.")
				return FALSE
		if("not_controlling")
			if(!host)
				to_chat(src, "You are not inside a host body.")
				return FALSE
			if(controlling)
				to_chat(src, "You already have controlled the host body.")
				return FALSE

	if(docile)
		to_chat(src, SPAN("notice", "You are feeling far too docile to do that."))
		return FALSE

	if(stat)
		to_chat(src, "You cannot do that in your current state.")
		return FALSE

	return TRUE

//TODO: if verbs will update within other objects(BYOND issue), make it to add only needed abilities.
/mob/living/simple_animal/borer/proc/update_abilities()
	clear_abilities()
	if(host)
		if(controlling)
			host.verbs |= BORER_ALL_ABILITIES["controlling"]
	verbs |= BORER_ALL_ABILITIES["not_controlling"]
	verbs |= BORER_ALL_ABILITIES["in_host"]
	verbs |= BORER_ALL_ABILITIES["out_host"]

/mob/living/simple_animal/borer/proc/clear_abilities()
	for(var/abilities_type in BORER_ALL_ABILITIES)
		verbs -= BORER_ALL_ABILITIES[abilities_type]
		if(host)
			host.verbs -= BORER_ALL_ABILITIES[abilities_type]

#undef BORER_ALL_ABILITIES
