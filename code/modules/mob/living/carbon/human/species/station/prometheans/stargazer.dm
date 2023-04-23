
//Stargazers are the telepathic branch of jellypeople, able to project psychic messages and to link minds with willing participants.

/datum/species/jelly/stargazer
	name = "\improper Stargazer"
	plural_form = null
	id = SPECIES_STARGAZER
	examine_limb_id = SPECIES_JELLYPERSON
	/// Special "project thought" telepathy action for stargazers.
	var/datum/action/innate/project_thought/project_action

/datum/species/jelly/stargazer/on_species_gain(mob/living/carbon/grant_to, datum/species/old_species)
	. = ..()
	project_action = new(src)
	project_action.Grant(grant_to)

	grant_to.AddComponent(/datum/component/mind_linker, \
		network_name = "Slime Link", \
		linker_action_path = /datum/action/innate/link_minds, \
		signals_which_destroy_us = list(COMSIG_SPECIES_LOSS), \
	)

//Species datums don't normally implement destroy, but JELLIES SUCK ASS OUT OF A STEEL STRAW
/datum/species/jelly/stargazer/Destroy()
	QDEL_NULL(project_action)
	return ..()

/datum/species/jelly/stargazer/on_species_loss(mob/living/carbon/remove_from)
	QDEL_NULL(project_action)
	return ..()

/datum/action/innate/project_thought
	name = "Send Thought"
	desc = "Send a private psychic message to someone you can see."
	button_icon_state = "send_mind"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"

/datum/action/innate/project_thought/Activate()
	var/mob/living/carbon/human/telepath = owner
	if(telepath.stat == DEAD)
		return
	if(!is_species(telepath, /datum/species/jelly/stargazer))
		return
	var/list/recipient_options = list()
	for(var/mob/living/recipient in oview(telepath))
		recipient_options.Add(recipient)
	if(!length(recipient_options))
		to_chat(telepath, SPAN_WARNING("You don't see anyone to send your thought to."))
		return
	var/mob/living/recipient = tgui_input_list(telepath, "Choose a telepathic message recipient", "Telepathy", sort_names(recipient_options))
	if(isnull(recipient))
		return
	var/msg = tgui_input_text(telepath, title = "Telepathy")
	if(isnull(msg))
		return
	if(recipient.can_block_magic(MAGIC_RESISTANCE_MIND, charge_cost = 0))
		to_chat(telepath, SPAN_WARNING("As you reach into [recipient]'s mind, you are stopped by a mental blockage. It seems you've been foiled."))
		return
	log_directed_talk(telepath, recipient, msg, LOG_SAY, "slime telepathy")
	to_chat(recipient, "[SPAN_NOTICE("You hear an alien voice in your head... ")]<font color=#008CA2>[msg]</font>")
	to_chat(telepath, SPAN_NOTICE("You telepathically said: \"[msg]\" to [recipient]"))
	for(var/dead in GLOB.dead_mob_list)
		if(!isobserver(dead))
			continue
		var/follow_link_user = FOLLOW_LINK(dead, telepath)
		var/follow_link_target = FOLLOW_LINK(dead, recipient)
		to_chat(dead, "[follow_link_user] [span_name("[telepath]")] [span_alertalien("Slime Telepathy --> ")] [follow_link_target] [span_name("[recipient]")] [SPAN_NOTICEalien("[msg]")]")

/datum/action/innate/link_minds
	name = "Link Minds"
	desc = "Link someone's mind to your Slime Link, allowing them to communicate telepathically with other linked minds."
	button_icon_state = "mindlink"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	/// The species required to use this ability. Typepath.
	var/req_species = /datum/species/jelly/stargazer
	/// Whether we're currently linking to someone.
	var/currently_linking = FALSE

/datum/action/innate/link_minds/New(Target)
	. = ..()
	if(!istype(Target, /datum/component/mind_linker))
		stack_trace("[name] ([type]) was instantiated on a non-mind_linker target, this doesn't work.")
		qdel(src)

/datum/action/innate/link_minds/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return
	if(!ishuman(owner) || !is_species(owner, req_species))
		return FALSE
	if(currently_linking)
		return FALSE

	return TRUE

/datum/action/innate/link_minds/Activate()
	if(!isliving(owner.pulling) || owner.grab_state < GRAB_AGGRESSIVE)
		to_chat(owner, SPAN_WARNING("You need to aggressively grab someone to link minds!"))
		return

	var/mob/living/living_target = owner.pulling
	if(living_target.stat == DEAD)
		to_chat(owner, SPAN_WARNING("They're dead!"))
		return

	to_chat(owner, SPAN_NOTICE("You begin linking [living_target]'s mind to yours..."))
	to_chat(living_target, SPAN_WARNING("You feel a foreign presence within your mind..."))
	currently_linking = TRUE

	if(!do_after(owner, 6 SECONDS, target = living_target, extra_checks = CALLBACK(src, PROC_REF(while_link_callback), living_target)))
		to_chat(owner, SPAN_WARNING("You can't seem to link [living_target]'s mind."))
		to_chat(living_target, SPAN_WARNING("The foreign presence leaves your mind."))
		currently_linking = FALSE
		return

	currently_linking = FALSE
	if(QDELETED(src) || QDELETED(owner) || QDELETED(living_target))
		return

	var/datum/component/mind_linker/linker = target
	if(!linker.link_mob(living_target))
		to_chat(owner, SPAN_WARNING("You can't seem to link [living_target]'s mind."))
		to_chat(living_target, SPAN_WARNING("The foreign presence leaves your mind."))


/// Callback ran during the do_after of Activate() to see if we can keep linking with someone.
/datum/action/innate/link_minds/proc/while_link_callback(mob/living/linkee)
	if(!is_species(owner, req_species))
		return FALSE
	if(!owner.pulling)
		return FALSE
	if(owner.pulling != linkee)
		return FALSE
	if(owner.grab_state < GRAB_AGGRESSIVE)
		return FALSE
	if(linkee.stat == DEAD)
		return FALSE

	return TRUE
