/obj/item/gun/launcher/money
	name = "money cannon"
	desc = "A blocky, plastic novelty launcher that claims to be able to shoot credits at considerable velocities."
	description_info = "Load money into the cannon by picking it up with the gun, or feeding it directly by hand. Use in your hand to configure how much money you want to fire per shot."
	description_fluff = "These devices were invented several centuries ago and are a distinctly human cultural infection. They have produced knockoffs as timeless and as insipid as the potato gun and the paddle ball, showing up in all corners of the galaxy. The Money Cannon variation is noteworthy for its sturdiness and build quality, but is, at the end of the day, just another knockoff of the ancient originals."
	description_antag = "Sliding a cryptographic sequencer into the receptacle will short the motors and override their speed. If you set the cannon to dispense 100 credits or more, this might make a handy weapon."
	icon_state = "money_launcher"
	item_state = "money_launcher"
	origin_tech = list(TECH_COMBAT = 1, TECH_MATERIAL = 1)
	slot_flags = SLOT_BELT
	w_class = ITEM_SIZE_SMALL
	release_force = 80
	fire_sound_text = "a whoosh and a crisp, papery rustle"
	fire_delay = 1
	fire_sound = 'sound/effects/weapons/misc/money_launcher.ogg'
	mod_weight = 0.7
	mod_reach = 0.5
	mod_handy = 1.0
	var/emagged = 0

	var/receptacle_value = 0
	var/dispensing = 20

/obj/item/gun/launcher/money/hacked
	emagged = 1

/obj/item/gun/launcher/money/proc/vomit_cash(mob/vomit_onto, projectile_vomit)
	var/bundle_worth = Floor(receptacle_value / 10)
	var/turf/T = get_turf(vomit_onto)
	for(var/i = 1 to 10)
		var/nv = bundle_worth
		if (i <= (receptacle_value - 10 * bundle_worth))
			nv++
		if (!nv)
			break
		var/obj/item/spacecash/bundle/bling = new(T)
		bling.worth = nv
		bling.update_icon()
		if(projectile_vomit)
			for(var/j = 1, j <= rand(2, 4), j++)
				step(bling, pick(GLOB.cardinal))

	if(projectile_vomit)
		vomit_onto.AdjustStunned(3)
		vomit_onto.AdjustWeakened(3)
		vomit_onto.visible_message(SPAN("danger", "\The [vomit_onto] blasts themselves full in the face with \the [src]!"))
		playsound(T, "sound/effects/weapons/misc/money_launcher_jackpot.ogg", 100, 1)
	else
		vomit_onto.visible_message(SPAN("danger", "\The [vomit_onto] ejects a few credits into their face."))
		playsound(T, 'sound/effects/weapons/misc/money_launcher.ogg', 100, 1)

	receptacle_value = 0

/obj/item/gun/launcher/money/proc/make_it_rain(mob/user)
	vomit_cash(user, receptacle_value >= 10)

/obj/item/gun/launcher/money/update_release_force()
	if(!emagged)
		release_force = 0
		return

	// Must launch at least 100 credits to incur damage.
	release_force = dispensing / 100

/obj/item/gun/launcher/money/proc/unload_receptacle(mob/user)
	if(receptacle_value < 1)
		to_chat(user, SPAN("warning", "There's no money in [src]."))
		return

	var/obj/item/spacecash/bling = new /obj/item/spacecash/bundle()
	bling.worth = receptacle_value
	bling.update_icon()
	user.pick_or_drop(bling, loc)
	to_chat(user, SPAN("notice", "You eject [receptacle_value] credits from [src]'s receptacle."))
	receptacle_value = 0

/obj/item/gun/launcher/money/proc/absorb_cash(obj/item/spacecash/bling, mob/user)
	if(!istype(bling) || !bling.worth || bling.worth < 1)
		to_chat(user, SPAN("warning", "[src] refuses to pick up [bling]."))
		return

	src.receptacle_value += bling.worth
	to_chat(user, SPAN("notice", "You load [bling] into [src]."))
	qdel(bling)

/obj/item/gun/launcher/money/consume_next_projectile(mob/user=null)
	if(!receptacle_value || receptacle_value < 1)
		return null

	var/obj/item/spacecash/bling = new /obj/item/spacecash/bundle()
	if(receptacle_value >= dispensing)
		bling.worth = dispensing
		receptacle_value -= dispensing
	else
		bling.worth = receptacle_value
		receptacle_value = 0

	bling.update_icon()
	update_release_force(bling.worth)
	if(release_force >= 1)
		var/datum/effect/effect/system/spark_spread/s = new()
		s.set_up(3, 1, src)
		s.start()

	return bling

/obj/item/gun/launcher/money/attack_self(mob/user as mob)
	src.dispensing = min(input(user, "How many credits do you want to dispense at a time? (1 to [src.receptacle_value])", "Money Cannon Settings", 20) as num, receptacle_value)
	if(dispensing <= 0 || dispensing > src.receptacle_value)
		dispensing = 1
		to_chat(user, SPAN("notice", "Your value is not in range (1 to [src.receptacle_value]). Setting to dispense 1 credits at a time."))
	else
		to_chat(user, SPAN("notice", "You set [src] to dispense [dispensing] credits at a time."))

/obj/item/gun/launcher/money/attack_hand(mob/user as mob)
	if(user.get_inactive_hand() == src)
		unload_receptacle(user)
	else
		return ..()

/obj/item/gun/launcher/money/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/spacecash/))
		var/obj/item/spacecash/bling = W
		if(bling.worth < 1)
			to_chat(user, SPAN("warning", "You can't seem to get the bills to slide into the receptacle."))
			return

		receptacle_value += bling.worth
		to_chat(user, SPAN("notice", "You slide [bling.worth] credits into [src]'s receptacle."))
		bling.worth = 0
		qdel(bling)

	else
		to_chat(user, SPAN("warning", "That's not going to fit in there."))

/obj/item/gun/launcher/money/examine(mob/user, infix)
	. = ..()

	. += "It is configured to dispense [dispensing] credits at a time."

	if(receptacle_value >= 1)
		. += "The receptacle is loaded with [receptacle_value] credits."

	else
		. += "The receptacle is empty."

	if(emagged)
		. += SPAN("notice", "Its motors are severely overloaded.")

/obj/item/gun/launcher/money/handle_suicide(mob/living/user)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/M = user
	M.visible_message(SPAN("danger", "[user] sticks [src] in their mouth, ready to pull the trigger..."))

	if(!do_after(user, 40, progress = 0, luck_check_type = LUCK_CHECK_COMBAT))
		M.visible_message(SPAN("notice", "[user] decided life was worth living."))
		return

	make_it_rain(user)

/obj/item/gun/launcher/money/handle_war_crime(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/M = user
	M.visible_message(SPAN("danger", "[user] sticks their gun in [target]'s mouth, ready to pull the trigger..."))

	if(!do_after(user, 40, progress = 0, luck_check_type = LUCK_CHECK_COMBAT))
		M.visible_message(SPAN("notice", "[user] decided [target]'s life was worth living."))
		return

	make_it_rain(user)

/obj/item/gun/launcher/money/emag_act(remaining_charges, mob/user)
	// Overloads the motors, causing it to shoot money harder and do harm.
	if(!emagged)
		emagged = 1
		to_chat(user, SPAN("notice", "You slide the sequencer into [src]... only for it to spit it back out and emit a motorized squeal!"))
		var/datum/effect/effect/system/spark_spread/s = new()
		s.set_up(3, 1, src)
		s.start()
	else
		to_chat(user, SPAN("notice", "[src] seems to have been tampered with already."))
