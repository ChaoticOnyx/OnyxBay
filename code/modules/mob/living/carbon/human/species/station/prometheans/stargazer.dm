
//Stargazers are the telepathic branch of jellypeople, able to project psychic messages and to link minds with willing participants.

/datum/species/promethean/stargazer
	name = SPECIES_STARGAZER
	name_plural = "Stargazers"
	icobase = 'icons/mob/human_races/prometheans/r_stargazer.dmi'
	/// Special "project thought" telepathy action for stargazers.
	appearance_flags = HAS_SKIN_COLOR | HAS_EYE_COLOR | HAS_HAIR_COLOR | RADIATION_GLOWS
	var/datum/action/innate/project_thought/project_action

/datum/species/promethean/stargazer/handle_post_spawn(mob/living/carbon/H)
	. = ..()
	project_action = new(src)
	project_action.Grant(H)

	H.AddComponent(/datum/component/mind_linker, \
		network_name = "Slime Link", \
		linker_action_path = /datum/action/innate/link_minds\
	)

//Species datums don't normally implement destroy, but JELLIES SUCK ASS OUT OF A STEEL STRAW
/datum/species/promethean/stargazer/Destroy()
	QDEL_NULL(project_action)
	return ..()

/datum/action/innate/project_thought
	name = "Send Thought"
	//desc = "Send a private psychic message to someone you can see."
	button_icon_state = "send_mind"
	button_icon = 'icons/mob/actions.dmi'
	background_icon_state = "bg_alien"


/datum/action/innate/project_thought/Activate()
	var/mob/living/carbon/human/telepath = owner

	if(telepath.stat == DEAD)
		return
	if(!is_species(telepath, /datum/species/promethean/stargazer))
		return

	var/list/recipient_options = list()
	for(var/mob/living/recipient in oview(telepath))
		recipient_options.Add(recipient)

	if(!length(recipient_options))
		to_chat(telepath, SPAN_WARNING("You don't see anyone to send your thought to."))
		return

	var/mob/living/recipient = tgui_input_list(telepath, "Choose a telepathic message recipient", "Telepathy", sort_list(recipient_options))

	if(isnull(recipient))
		return

	var/msg = input(telepath,"Telepathy") as text|null
	if(isnull(msg))
		return

	if(ishuman(recipient))
		var/mob/living/carbon/human/H = recipient
		if(istype(H.head, /obj/item/clothing/head/tinfoil))
			to_chat(telepath, SPAN_WARNING("As you reach into [H]'s mind, you are stopped by a mental blockage. It seems you've been foiled."))
			return

	log_say("(metroid telepathy): [telepath] send \"[msg]\"to [recipient]")
	to_chat(recipient, "[SPAN_NOTICE("You hear an alien voice in your head... ")]<font color=#008CA2>[msg]</font>")
	to_chat(telepath, SPAN_NOTICE("You telepathically said: \"[msg]\" to [recipient]"))

	for(var/dead in GLOB.dead_mob_list_)
		if(!isobserver(dead))
			continue
		var/follow_link_user = ghost_follow_link(telepath, dead)
		var/follow_link_target = ghost_follow_link(dead, recipient, dead)
		to_chat(dead, "[follow_link_user] [SPAN("name","[telepath]")][SPAN_NOTICE("Slime Telepathy --> ")] [follow_link_target] [SPAN("name","[recipient]")] [SPAN_NOTICE("[msg]")]")

/datum/action/innate/link_minds
	name = "Link Minds"
	//desc = "Link someone's mind to your Slime Link, allowing them to communicate telepathically with other linked minds."
	button_icon_state = "mindlink"
	button_icon = 'icons/mob/actions.dmi'
	background_icon_state = "bg_alien"
	/// The species required to use this ability. Typepath.
	var/req_species = /datum/species/promethean/stargazer
	/// Whether we're currently linking to someone.
	var/currently_linking = FALSE

/datum/action/innate/link_minds/New(Target)
	. = ..()
	if(!istype(Target, /datum/component/mind_linker))
		qdel(src)
		error("[name] ([type]) was instantiated on a non-mind_linker target, this doesn't work.")

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

	var/obj/item/grab/G
	if(istype(owner.l_hand, /obj/item/grab))
		G = owner.l_hand
	else
		if(istype(owner.r_hand, /obj/item/grab))
			G = owner.r_hand
	if(G.current_grab.state_name != NORM_AGGRESSIVE)
		to_chat(owner, SPAN_WARNING("You need to aggressively grab someone to link minds!"))
		return

	var/mob/living/living_target = G.affecting
	if(living_target.stat == DEAD)
		to_chat(owner, SPAN_WARNING("They're dead!"))
		return

	to_chat(owner, SPAN_NOTICE("You begin linking [living_target]'s mind to yours..."))
	to_chat(living_target, SPAN_WARNING("You feel a foreign presence within your mind..."))
	currently_linking = TRUE


	if(!do_after(owner, 6 SECONDS, living_target) && link_check(living_target))
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

/datum/action/innate/link_minds/proc/link_check(mob/living/linkee)
	if(!is_species(owner, req_species))
		return FALSE

	var/obj/item/grab/G
	if(istype(owner.l_hand, /obj/item/grab))
		G = owner.l_hand
	else
		if(istype(owner.r_hand, /obj/item/grab))
			G = owner.r_hand
	if(G.current_grab.state_name != NORM_AGGRESSIVE || G.current_grab.state_name != NORM_NECK || G.current_grab.state_name != NORM_KILL)
		return FALSE

	if(!G.affecting)
		return FALSE
	if(G.affecting != linkee)
		return FALSE

	if(linkee.stat == DEAD)
		return FALSE

	return TRUE
