/**
 * # Mind Linker
 *
 * A component that handles linking multiple player's minds
 * into one network which allows them to talk directly to one another.
 * Like telepathy but for multiple people at once!
 */
/datum/component/mind_linker
	/// The name of our network, displayed to all users.
	var/network_name = "Mind Link"
	/// The color of the network when talking in chat
	var/chat_color
	/// The message sent to someone when linked up.
	var/link_message
	/// The message sent to someone when unlinked.
	var/unlink_message
	/// A list of all signals that will call qdel() on our component if triggered. Optional.
	var/list/signals_which_destroy_us
	/// A callback invoked after an unlink is done. Optional.
	var/datum/callback/post_unlink_callback
	/// The icon file given to the speech action handed out.
	var/speech_action_icon = 'icons/hud/actions.dmi'
	/// The icon state applied to the speech action handed out.
	var/speech_action_icon_state = "link_speech"
	/// The icon background for the speech action handed out.
	var/speech_action_background_icon_state = "bg_alien"
	/// The master's linking action, which allows them to link people to the network.
	var/datum/action/innate/link_minds/linker_action
	/// The master's speech action. The owner of the link shouldn't lose this as long as the link remains.
	var/datum/action/innate/linked_speech/master_speech
	/// The master's speech action. The owner of the link shouldn't lose this as long as the link remains.
	var/datum/action/innate/project_thought/project_action
	/// An assoc list of [mob/living]s to [datum/action/innate/linked_speech]s. All the mobs that are linked to our network.
	var/list/mob/living/linked_mobs = list()

/datum/component/mind_linker/Initialize(
	network_name = "Mind Link",
	chat_color = "#008CA2",
	link_message,
	unlink_message,
	signals_which_destroy_us,
	datum/callback/post_unlink_callback,
	speech_action_icon = 'icons/hud/actions.dmi',
	speech_action_icon_state = "link_speech",
	speech_action_background_icon_state = "bg_alien",
	)

	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/living/owner = parent

	src.network_name = network_name
	src.chat_color = chat_color
	src.link_message = link_message || "You are now connected to [owner.real_name]'s [network_name]."
	src.unlink_message = unlink_message || "You are no longer connected to [owner.real_name]'s [network_name]."

	if(islist(signals_which_destroy_us))
		src.signals_which_destroy_us = signals_which_destroy_us
	if(post_unlink_callback)
		src.post_unlink_callback = post_unlink_callback

	src.speech_action_icon = speech_action_icon
	src.speech_action_icon_state = speech_action_icon_state
	src.speech_action_background_icon_state = speech_action_background_icon_state

	linker_action = new(src)
	linker_action.Grant(owner)

	master_speech = new(src)
	master_speech.Grant(owner)

	project_action = new(src)
	project_action.Grant(owner)

	to_chat(owner, SPAN("bold",SPAN_NOTICE("You establish a [network_name], allowing you to link minds to communicate telepathically.")))

/datum/component/mind_linker/Destroy(force, silent)
	for(var/mob/living/remaining_mob as anything in linked_mobs)
		unlink_mob(remaining_mob)
	linked_mobs.Cut()
	return ..()

/datum/component/mind_linker/register_with_parent()
	if(signals_which_destroy_us)
		register_signal(parent, signals_which_destroy_us, nameof(.proc/destroy_link))

/datum/component/mind_linker/unregister_from_parent()
	if(signals_which_destroy_us)
		unregister_signal(parent, signals_which_destroy_us)

/**
 * Attempts to link [to_link] to our network, giving them a speech action.
 *
 * Returns TRUE if successful, FALSE otherwise
 */
/datum/component/mind_linker/proc/link_mob(mob/living/to_link)
	if(QDELETED(to_link) || to_link.stat == DEAD)
		return FALSE
	if(ishuman(to_link))
		var/mob/living/carbon/human/H = to_link
		if(istype(H.head, /obj/item/clothing/head/tinfoil))
			return FALSE
	if(linked_mobs[to_link])
		return FALSE

	var/mob/living/owner = parent
	if(to_link == owner)
		return FALSE

	to_chat(to_link, SPAN_NOTICE(link_message))
	to_chat(owner, SPAN_NOTICE("You connect [to_link]'s mind to your [network_name]."))

	for(var/mob/living/other_link as anything in linked_mobs)
		to_chat(other_link, SPAN_NOTICE("You feel a new presence within [owner.real_name]'s [network_name]."))

	var/datum/action/innate/linked_speech/new_link = new(src)
	new_link.Grant(to_link)
	new_link.name = "[new_link.name]([network_name])"
	linked_mobs[to_link] = new_link
	register_signal(to_link, list(SIGNAL_MOB_DEATH, SIGNAL_QDELETING), nameof(.proc/unlink_mob))

	return TRUE

/**
 * Unlinks [to_unlink] from our network, deleting their speech action
 * and cleaning up anything involved.
 *
 * Also invokes post_unlink_callback, if supplied.
 */
/datum/component/mind_linker/proc/unlink_mob(mob/living/to_unlink)

	if(!linked_mobs[to_unlink])
		return

	to_chat(to_unlink, SPAN_WARNING(unlink_message))
	post_unlink_callback?.Invoke(to_unlink)

	unregister_signal(to_unlink, list(SIGNAL_MOB_DEATH, SIGNAL_QDELETING))

	var/datum/action/innate/linked_speech/old_link = linked_mobs[to_unlink]
	linked_mobs -= to_unlink
	qdel(old_link)

	var/mob/living/owner = parent

	to_chat(owner, SPAN_WARNING("You feel someone disconnect from your [network_name]."))
	for(var/mob/living/other_link as anything in linked_mobs)
		to_chat(other_link, SPAN_WARNING("You feel a pressence disappear from [owner.real_name]'s [network_name]."))

/**
 *  Signal proc sent from any signals given to us initialize.
 *  Destroys our component and unlinks everyone.
 */
/datum/component/mind_linker/proc/destroy_link(datum/source)
	if(isliving(source))
		var/mob/living/owner = source
		to_chat(owner, SPAN("bold",SPAN_WARNING("Your [network_name] breaks!")))

	qdel(src)

/datum/action/innate/linked_speech
	name = "Mind Link Speech"
	//desc = "Send a psychic message to everyone connected to your Link."
	button_icon_state = "link_speech"
	button_icon = 'icons/hud/actions.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/linked_speech/New(Target)
	. = ..()
	if(!istype(Target, /datum/component/mind_linker))
		error("[name] ([type]) was instantiated on a non-mind_linker target, this doesn't work.")
		qdel(src)
		return

	var/datum/component/mind_linker/linker = Target
	name = "[linker.network_name] Speech"
	//desc = "Send a psychic message to everyone connected to your [linker.network_name]."
	button_icon = linker.speech_action_icon
	button_icon_state = linker.speech_action_icon_state
	background_icon_state = linker.speech_action_background_icon_state

/datum/action/innate/linked_speech/IsAvailable(feedback = FALSE)
	return ..() && (owner.stat != DEAD)

/datum/action/innate/linked_speech/Activate()

	var/datum/component/mind_linker/linker = target
	var/mob/living/linker_parent = linker.parent

	var/message = sanitize(input(owner, "Enter a message to transmit.", "[linker.network_name] Telepathy")as text|null)
	if(!message || QDELETED(src) || QDELETED(owner) || owner.stat == DEAD)
		return

	if(QDELETED(linker))
		to_chat(owner, SPAN_WARNING("The link seems to have been severed."))
		return

	var/formatted_message = "<i><font color=[linker.chat_color]>\[[linker_parent.real_name]'s [linker.network_name]\] <b>[owner]:</b> [message]</font></i>"
	log_say("(mind link ([linker.network_name])): [owner] send \"[message]\"to [linker_parent]")
	var/list/all_who_can_hear = list_keys(linker.linked_mobs) + linker_parent

	for(var/mob/living/recipient as anything in all_who_can_hear)
		to_chat(recipient, formatted_message)

	for(var/mob/recipient as anything in GLOB.dead_mob_list_)
		to_chat(recipient, "[ ghost_follow_link(owner, recipient)] [formatted_message]")

/datum/action/innate/project_thought
	name = "Send Thought"
	//desc = "Send a private psychic message to someone you can see."
	button_icon_state = "send_mind"
	button_icon = 'icons/hud/actions.dmi'
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
	//desc = "Link someone's mind to your Stargazer Link, allowing them to communicate telepathically with other linked minds."
	button_icon_state = "mindlink"
	button_icon = 'icons/hud/actions.dmi'
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
