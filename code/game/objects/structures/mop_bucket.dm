#define OXYLOS_PER_HEAD_DIP 10

/obj/structure/mopbucket
	name = "mop bucket"
	desc = "Fill it with water, but don't forget a mop!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mopbucket"
	density = 1
	w_class = ITEM_SIZE_NORMAL
	atom_flags = ATOM_FLAG_CLIMBABLE
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	pull_slowdown = PULL_SLOWDOWN_TINY
	turf_height_offset = 14
	var/amount_per_transfer_from_this = 5	//shit I dunno, adding this so syringes stop runtime erroring. --NeoFite


/obj/structure/mopbucket/Initialize()
	. = ..()
	create_reagents(180)

/obj/structure/mopbucket/examine(mob/user, infix)
	. = ..()

	if(get_dist(src, user) <= 1)
		. += "[src] \icon[src] contains [reagents.total_volume] unit\s of water!"

/obj/structure/mopbucket/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/mop))
		if(reagents.total_volume < 1)
			show_splash_text(user, "no water!", SPAN("warning", "\The [src] is empty!"))
			return

		else
			reagents.trans_to_obj(I, 5)
			show_splash_text(user, "you wet the mop!", SPAN("notice", "You wet \the [I] in \the [src]."))
			playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
			return

	else return ..()

/obj/structure/mopbucket/grab_attack(obj/item/grab/G)
	var/mob/user = G.assailant
	if(!isliving(G.affecting))
		return FALSE

	if(istype(G.current_grab, /datum/grab/normal/passive))
		to_chat(user, SPAN_NOTICE("You need a tighter grip!"))
		return TRUE

	if(reagents.total_volume < 1)
		show_splash_text(user, "no water!", SPAN("warning", "\The [src] is empty!"))
		return TRUE

	user.visible_message(SPAN_DANGER("[user] starts to put [G.affecting.name]'s head into \the [src]!"), \
					SPAN_DANGER("You start to put [G.affecting.name]'s head into \the [src]!"))
	reagents.trans_to(G.affecting, min(reagents.total_volume, 5))
	playsound(get_turf(src), GET_SFX(SFX_FOOTSTEP_WATER), 100, TRUE)

	if(!do_after(user, 3 SECONDS, src, TRUE))
		return TRUE

	if(QDELETED(src) || !G?.affecting)
		return TRUE

	user.visible_message(SPAN_DANGER("[user] finally raises [G.affecting.name]'s head out of \the [src]!"), \
							SPAN_DANGER("You raise [G.affecting.name]'s head out of \the [src]!"))
	reagents.trans_to(G.affecting, min(reagents.total_volume, 5))
	playsound(get_turf(src), GET_SFX(SFX_FOOTSTEP_WATER), 100, TRUE)
	var/mob/living/carbon/human/H = G.get_affecting_mob()
	if(!H?.internal && !H.isSynthetic())
		H?.adjustOxyLoss(OXYLOS_PER_HEAD_DIP)
		H?.emote("gasp")
	return TRUE

#undef OXYLOS_PER_HEAD_DIP
