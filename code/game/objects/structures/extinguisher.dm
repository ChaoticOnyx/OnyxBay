#define MIN_EMAGGED_REAGENTS_VOLUME 1
#define MAX_EMAGGED_REAGENTS_VOLUME 300

/obj/structure/extinguisher_cabinet
	name = "extinguisher cabinet"
	desc = "A small wall mounted cabinet designed to hold a fire extinguisher."
	icon = 'icons/obj/closet.dmi'
	icon_state = "extinguisher_closed"
	anchored = TRUE
	density = FALSE
	/// Extinguisher stored in the cabinet.
	var/obj/item/extinguisher/has_extinguisher
	/// State of the cabinet's lid
	var/opened = FALSE
	/// Whether this cabinet can automatically refill extinguishers
	var/automatic_refill = TRUE
	/// Won't refill ff reagents that are not in this list.
	var/list/refillable_reagents = list(/datum/reagent/water/firefoam,  /datum/reagent/water/firefoam)
	/// Tracks whether the refill process was interrupted by something.
	var/refill_interrupted = FALSE
	/// The amount of time this cabinet takes to refill extinguishers
	var/refill_duration = 30 SECONDS
	/// Whether this cabinet was emagged or not.
	var/emagged = FALSE
	/// Types of reagents that will be filled by an emagged cabinet.
	var/static/list/refillable_reagents_emagged = list(/datum/reagent/acid = 3, /datum/reagent/fuel = 4, /datum/reagent/lube = 2)

/obj/structure/extinguisher_cabinet/Initialize()
	. = ..()

	has_extinguisher = new /obj/item/extinguisher(src)

/obj/structure/extinguisher_cabinet/Destroy()
	QDEL_NULL(has_extinguisher)
	set_next_think(0)
	return ..()

/obj/structure/extinguisher_cabinet/think()
	if(refill_interrupted || !has_extinguisher)
		return

	if(!has_extinguisher.reagents.get_free_space() || !is_path_in_list(has_extinguisher.ff_reagent, refillable_reagents))
		return

	if(emagged)
		var/reagents_amount = Clamp(has_extinguisher.reagents.get_free_space() / 10, MIN_EMAGGED_REAGENTS_VOLUME, MAX_EMAGGED_REAGENTS_VOLUME)
		has_extinguisher.reagents.add_reagent(util_pick_weight(refillable_reagents_emagged), reagents_amount)
		emagged = FALSE
	else
		has_extinguisher.reagents.add_reagent(has_extinguisher?.ff_reagent, has_extinguisher.reagents.get_free_space())

	playsound(loc, 'sound/effects/refill.ogg', 50, 1, -6)

/obj/structure/extinguisher_cabinet/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/extinguisher))
		if(!has_extinguisher && opened)
			if(!user.drop(O, src))
				return

			has_extinguisher = O
			to_chat(user, SPAN_NOTICE("You place [O] in [src]."))
			playsound(src.loc, 'sound/effects/extin.ogg', 50, 0)
			if(automatic_refill && has_extinguisher.reagents?.get_free_space() && is_path_in_list(has_extinguisher.ff_reagent, refillable_reagents))
				refill_interrupted = FALSE
				set_next_think(world.time + refill_duration)
		else
			opened = !opened
	else
		opened = !opened
	update_icon()

/obj/structure/extinguisher_cabinet/attack_hand(mob/user)
	if(isrobot(user))
		return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/temp = H.organs_by_name[BP_R_HAND]
		if(user.hand)
			temp = H.organs_by_name[BP_L_HAND]
		if(temp && !temp.is_usable())
			to_chat(user, SPAN_NOTICE("You try to move your [temp.name], but cannot!"))
			return

	if(has_extinguisher)
		if(!user.IsAdvancedToolUser(TRUE))
			to_chat(user, FEEDBACK_YOU_LACK_DEXTERITY)
			return

		user.pick_or_drop(has_extinguisher)
		to_chat(user, SPAN_NOTICE("You take [has_extinguisher] from [src]."))
		playsound(src.loc, 'sound/effects/extout.ogg', 50, 0)
		refill_interrupted = TRUE
		set_next_think(0)
		has_extinguisher = null
		opened = TRUE
	else
		opened = !opened
	update_icon()

/obj/structure/extinguisher_cabinet/attack_tk(mob/user)
	if(has_extinguisher)
		has_extinguisher.dropInto(loc)
		to_chat(user, SPAN_NOTICE("You telekinetically remove [has_extinguisher] from [src]."))
		has_extinguisher = null
		refill_interrupted = TRUE
		set_next_think(0)
		opened = TRUE
	else
		opened = !opened
	update_icon()

/obj/structure/extinguisher_cabinet/emag_act(remaining_charges, mob/user, emag_source)
	if(emagged)
		return NO_EMAG_ACT

	show_splash_text(user, "cabinet emagged!", "You hack \the [src] reagent fabricator!")
	emagged = TRUE
	return TRUE

/obj/structure/extinguisher_cabinet/AltClick(mob/user)
	if(CanPhysicallyInteract(user))
		opened = !opened
		update_icon()

/obj/structure/extinguisher_cabinet/on_update_icon()
	if(!opened)
		icon_state = "extinguisher_closed"
		return
	if(has_extinguisher)
		if(istype(has_extinguisher, /obj/item/extinguisher/mini))
			icon_state = "extinguisher_mini"
		else
			icon_state = "extinguisher_full"
	else
		icon_state = "extinguisher_empty"
