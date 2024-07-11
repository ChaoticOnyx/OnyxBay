#define SHOWER_MAX_WORKING_TIME 30 SECONDS
#define MIST_SPAWN_DELAY 10 SECONDS
#define SHOWER_WASH_FLOOR_INTERVAL 10 SECONDS
#define TOILET_BRUTELOSS_PER_LIDSTOMP 8
#define TOILET_OXYLOSS_PER_SWIRLIE 10
/obj/structure/toilet
	name = "toilet"
	desc = "The HT-451, a torque rotation-based, waste disposal unit for small matter. This one seems remarkably clean."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "toilet00"
	base_icon_state = "toilet"
	density = FALSE
	anchored = TRUE
	/// State of the lid (raised or lowered)
	var/lid_open = FALSE
	/// State of the cistern bit (closed or lid_open)
	var/cistern = FALSE
	// combined w_class of all the items in the cistern
	var/w_items = 0
	/// The mob being given a swirlie
	var/mob/living/swirlie = null

/obj/structure/toilet/Initialize()
	. = ..()
	lid_open = round(rand(FALSE, TRUE))
	register_signal(get_turf(src), SIGNAL_ENTERED, nameof(.proc/on_turf_enter))
	register_signal(src, SIGNAL_MOVED, nameof(.proc/re_register_enter_signal))
	create_reagents(100)
	update_icon()
	AddComponent(/datum/component/plumbing/simple_supply, SECOND_DUCT_LAYER)

/obj/structure/toilet/Destroy()
	unregister_signal(get_turf(src), SIGNAL_ENTERED)
	return ..()

/obj/structure/toilet/attack_hand(mob/living/user)
	if(swirlie)
		THROTTLE(cooldown, 0.5 SECONDS)
		if(!cooldown)
			return

		visible_message(SPAN_DANGER("[user] slams the toilet seat onto [swirlie.name]'s head!"), \
		"You hear reverberating porcelain.")
		swirlie.adjustBruteLoss(TOILET_BRUTELOSS_PER_LIDSTOMP)
		playsound(get_turf(src), GET_SFX(SFX_FIGHTING_PUNCH), 100, TRUE)
		return

	if(cistern && !lid_open)
		if(!contents.len)
			show_splash_text(user, "the cistern is empty!", SPAN("notice", "The cistern is empty."))
			return
		else
			var/obj/item/I = pick(contents)
			if(ishuman(user))
				user.pick_or_drop(I)
			else
				I.dropInto(loc)
			to_chat(user, "<span class='notice'>You find \an [I] in the cistern.</span>")
			w_items -= I.w_class
			return

	lid_open = !lid_open
	update_icon()

/obj/structure/toilet/proc/on_turf_enter()
	THROTTLE(cooldown, 15 SECONDS)
	if(!cooldown)
		return

	reagents.add_reagent(/datum/reagent/toxin/fertilizer/compost, 10)
	playsound(src, 'sound/effects/toilet_flush.ogg', 100, TRUE)

/obj/structure/toilet/proc/re_register_enter_signal(atom/movable/self, atom/former_turf, atom/new_turf)
	unregister_signal(former_turf, SIGNAL_ENTERED)
	register_signal(new_turf, SIGNAL_ENTERED)

/obj/structure/toilet/on_update_icon()
	icon_state = "[base_icon_state][lid_open][cistern]"

/obj/structure/toilet/attackby(obj/item/I, mob/living/user)
	if(isCrowbar(I))
		show_splash_text(user, "[cistern? "replacing the lid" : "lifting the lid"]", SPAN("notice", "You start to [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]."))
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, 1)
		if(!do_after(user, 3 SECONDS, src))
			return

		if(QDELETED(src))
			return

		visible_message(SPAN_NOTICE("[user] [cistern ? "replaces the lid on the cistern" : "lifts the lid off the cistern"]!"), \
		"You hear grinding porcelain.")
		cistern = !cistern
		update_icon()
		return

	else if(istype(I, /obj/item/grab) && lid_open && !swirlie)
		var/obj/item/grab/G = I

		if(!isliving(G.affecting))
			return

		if(G.current_grab.state_name == NORM_PASSIVE)
			show_splash_text(user, "tighter grip is needed!", SPAN("warning", "You need a tigher grip!"))
			return

		if(get_dist(G.affecting, get_turf(src)) > 1)
			show_splash_text(user, "victim needs to be on the toilet!", SPAN("warning", "The victim must be held right above the toilet!"))
			return

		if(lid_open && !swirlie)
			user.visible_message(SPAN_DANGER("[user] starts to give [G.affecting.name] a swirlie!"), \
									SPAN_DANGER("You start to give [G.affecting.name] a swirlie!"))
			swirlie = G.affecting
			if(!do_after(user, 3 SECONDS, src, FALSE))
				swirlie = null
				return

			if(QDELETED(src) || !G?.affecting)
				swirlie = null
				return

			user.visible_message(SPAN_DANGER("[user] gives [G.affecting.name] a swirlie!"), \
									SPAN_DANGER("You give [G.affecting.name] a swirlie!"))
			playsound(src, 'sound/effects/toilet_flush.ogg', 100, TRUE)
			if(!G?.affecting?.internal && !G.affecting.isSynthetic())
				G.affecting.adjustOxyLoss(TOILET_OXYLOSS_PER_SWIRLIE)
				G.affecting.emote("gasp")
			swirlie = null
			return
		else
			user.visible_message(SPAN_DANGER("[user] slams [G.affecting.name] into the [src]!"), \
									SPAN_DANGER("You slam [G.affecting.name] into the [src]!"))
			G.affecting.adjustBruteLoss(TOILET_BRUTELOSS_PER_LIDSTOMP)
			return

	if(cistern && !istype(user, /mob/living/silicon/robot)) //STOP PUTTING YOUR MODULES IN THE TOILET.
		if(I.w_class > ITEM_SIZE_NORMAL)
			show_splash_text(user, "won't fit!", SPAN("notice", "\The [I] does not fit."))
			return

		if(w_items + I.w_class > 5)
			show_splash_text(user, "cistern is full!", SPAN("notice", "The cistern is full."))
			return

		if(!user.drop(I, src))
			return
		w_items += I.w_class
		show_splash_text(user, "item placed into the cistern", "You carefully place \the [I] into the cistern.")
		return

	return ..()

/obj/structure/toilet/gold
	name = "golden toilet"
	desc = "The HT-451, a torque rotation-based, waste disposal unit for small matter. This one is LUXURIOUS."
	icon_state = "goldtoilet00"
	base_icon_state = "goldtoilet"


/obj/structure/urinal
	name = "urinal"
	desc = "The HU-452, an experimental urinal."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "urinal"
	density = 0
	anchored = 1

/obj/item/bikehorn/rubberducky
	name = "rubber ducky"
	desc = "Rubber ducky you're so fine, you make bathtime lots of fuuun. Rubber ducky I'm awfully fooooond of yooooouuuu~"	//thanks doohl
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rubberducky"
	item_state = "rubberducky"
	slot_flags = SLOT_HEAD

#undef SHOWER_MAX_WORKING_TIME
#undef MIST_SPAWN_DELAY
#undef SHOWER_WASH_FLOOR_INTERVAL
#undef TOILET_BRUTELOSS_PER_LIDSTOMP
#undef TOILET_OXYLOSS_PER_SWIRLIE
