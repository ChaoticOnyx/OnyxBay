/obj/item/organ/internal/heart/gland
	name = "fleshy mass"
	desc = "A nausea-inducing hunk of twisting flesh and metal."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "gland"
	status = ORGAN_ROBOTIC | ORGAN_CUT_AWAY
	/// Shows name of the gland as well as a description of what it does upon examination by abductor scientists and observers.
	var/abductor_hint = "baseline placebo referencer"

	/// The minimum time between activations
	var/cooldown_low = 30 SECONDS
	var/on_cooldown = TRUE
	var/cooldown_high = 30 SECONDS
	/// The number of remaining uses this gland has.
	var/uses = 0 // -1 For infinite
	var/human_only = FALSE
	var/active = FALSE
	override_species_icon = TRUE
	var/mind_control_uses = 1
	var/mind_control_duration = 1800
	var/active_mind_control = FALSE

/obj/item/organ/internal/heart/gland/Initialize(mapload)
	. = ..()
	icon_state = pick(list("health", "spider", "slime", "emp", "species", "egg", "vent", "mindshock", "viral"))
	if(owner)
		Start()

/obj/item/organ/internal/heart/gland/_examine_text(mob/user)
	. = ..()
	if(isobserver(user))
		. += SPAN_NOTICE("It is \a [abductor_hint]")

/obj/item/organ/internal/heart/gland/proc/ownerCheck()
	if(ishuman(owner))
		return TRUE
	if(!human_only && iscarbon(owner))
		return TRUE
	return FALSE

/obj/item/organ/internal/heart/gland/proc/Start()
	active = TRUE
	addtimer(CALLBACK(src, .proc/do_after_cooldown),rand(cooldown_low, cooldown_high))
	BITSET(owner.hud_updateflag, GLAND_HUD)

/obj/item/organ/internal/heart/gland/proc/update_gland_hud()
	if(!owner)
		return
	var/image/holder = owner.hud_list[GLAND_HUD]
	var/icon/I = icon(owner.icon, owner.icon_state, owner.dir)
	holder.pixel_y = I.Height() - world.icon_size
	if(active_mind_control)
		holder.icon_state = "hudgland_active"
	else if(mind_control_uses)
		holder.icon_state = "hudgland_ready"
	else
		holder.icon_state = "hudgland_spent"

/obj/item/organ/internal/heart/gland/proc/mind_control(command, mob/living/user)
	if(!ownerCheck() || !mind_control_uses || active_mind_control)
		return FALSE
	mind_control_uses--
	to_chat(owner, SPAN_DANGER("You suddenly feel an irresistible compulsion to follow an order..."))
	to_chat(owner, SPAN_NOTICE(FONT_LARGE("[command]")))
	active_mind_control = TRUE
	message_admins("[key_name(user)] sent an abductor mind control message to [key_name(owner)]: [command]")
	log_game("[key_name(user)] sent an abductor mind control message to [key_name(owner)]: [command]")
	update_gland_hud()
	addtimer(CALLBACK(src, .proc/clear_mind_control), mind_control_duration)
	return TRUE

/obj/item/organ/internal/heart/gland/proc/clear_mind_control()
	if(!ownerCheck() || !active_mind_control)
		return FALSE
	to_chat(owner, SPAN_DANGER("You feel the compulsion fade, and you <i>completely forget</i> about your previous orders."))
	active_mind_control = FALSE
	return TRUE

/obj/item/organ/internal/heart/gland/removed(mob/living/user, drop_organ = TRUE, detach = TRUE, special = FALSE)
	active = FALSE
	if(initial(uses) == 1)
		uses = initial(uses)
	clear_mind_control()
	SetName("fleshy mass")
	..()

/obj/item/organ/internal/heart/gland/replaced(mob/living/carbon/human/target, obj/item/organ/external/affected, special = FALSE)
	..()
	if(uses)
		Start()
	SetName("heart")
	update_gland_hud()

/obj/item/organ/internal/heart/gland/Process()
	if(!pulse || pulse != PULSE_NORM)
		pulse = PULSE_NORM
	if(!active)
		return
	if(!owner)
		active = FALSE
		return
	if(!on_cooldown)
		activate()
		uses--
		on_cooldown = TRUE
		addtimer(CALLBACK(src,.proc/do_after_cooldown), rand(cooldown_low, cooldown_high))
	if(!uses)
		active = FALSE
	..()

/obj/item/organ/internal/heart/gland/emp_act(severity)
	return 0

/obj/item/organ/internal/heart/gland/proc/do_after_cooldown()
	on_cooldown = FALSE

/obj/item/organ/internal/heart/gland/proc/activate()
	return
