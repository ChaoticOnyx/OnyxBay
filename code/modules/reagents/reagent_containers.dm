/obj/item/reagent_containers
	name = "Container"
	desc = "..."
	icon = 'icons/obj/chemical.dmi'
	icon_state = null
	w_class = ITEM_SIZE_SMALL
	var/amount_per_transfer_from_this = 5
	var/possible_transfer_amounts = "5;10;15;25;30"
	var/volume = 30
	var/label_text
	var/can_be_splashed = FALSE
	var/list/startswith // List of reagents to start with

/obj/item/reagent_containers/verb/set_APTFT() //set amount_per_transfer_from_this
	set name = "Set transfer amount"
	set category = "Object"
	set src in usr

	var/N = tgui_input_list(usr, "Amount per transfer from this:", "[src]", cached_number_list_decode(possible_transfer_amounts))
	if(N)
		amount_per_transfer_from_this = N

/obj/item/reagent_containers/Initialize(mapload, spawn_empty = FALSE)
	. = ..(mapload)
	if(!possible_transfer_amounts)
		src.verbs -= /obj/item/reagent_containers/verb/set_APTFT
	create_reagents(volume)
	if(startswith && !spawn_empty)
		for(var/thing in startswith)
			reagents.add_reagent(thing, startswith[thing] ? startswith[thing] : volume)
		startswith = null // Unnecessary lists bad
		update_icon()

/obj/item/reagent_containers/attack_self(mob/user)
	return

/obj/item/reagent_containers/afterattack(obj/target, mob/user, flag)
	if(can_be_splashed && user.a_intent != I_HELP)
		if(standard_splash_mob(user,target))
			return
		if(reagents && reagents.total_volume)
			to_chat(user, SPAN_NOTICE("You splash the contents of \the [src] onto [target].")) // They are not on help intent, aka wanting to spill it.
			reagents.splash(target, reagents.total_volume)
			return

/obj/item/reagent_containers/proc/reagentlist() // For attack logs
	if(reagents)
		return reagents.get_reagents()
	return "No reagent holder"

/obj/item/reagent_containers/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/pen) || istype(W, /obj/item/device/flashlight/pen))
		var/tmp_label = sanitizeSafe(input(user, "Enter a label for [name]", "Label", label_text), MAX_NAME_LEN)
		if(length(tmp_label) > 10)
			to_chat(user, "<span class='notice'>The label can be at most 10 characters long.</span>")
		else
			to_chat(user, "<span class='notice'>You set the label to \"[tmp_label]\".</span>")
			label_text = tmp_label
			update_name_label()
	else
		return ..()

/obj/item/reagent_containers/proc/update_name_label()
	if(label_text == "")
		SetName(initial(name))
	else
		SetName("[initial(name)] ([label_text])")

/obj/item/reagent_containers/proc/standard_dispenser_refill(mob/user, obj/structure/reagent_dispensers/target) // This goes into afterattack
	if(!istype(target))
		return 0

	if(!target.reagents || !target.reagents.total_volume)
		to_chat(user, "<span class='notice'>[target] is empty.</span>")
		return 1

	if(reagents && !reagents.get_free_space())
		to_chat(user, "<span class='notice'>[src] is full.</span>")
		return 1

	var/trans = target.reagents.trans_to_obj(src, target:amount_per_transfer_from_this)
	playsound(target, 'sound/effects/using/sink/fast_filling1.ogg', 75, TRUE)
	to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the contents of [target].</span>")
	return 1

/obj/item/reagent_containers/proc/standard_splash_mob(mob/user, mob/target) // This goes into afterattack
	if(!istype(target))
		return

	if(user.a_intent == I_HELP)
		to_chat(user, "<span class='notice'>You can't splash people on help intent.</span>")
		return 1

	if(!reagents || !reagents.total_volume)
		to_chat(user, "<span class='notice'>[src] is empty.</span>")
		return 1

	if(target.reagents && !target.reagents.get_free_space())
		to_chat(user, "<span class='notice'>[target] is full.</span>")
		return 1

	var/contained = reagentlist()
	admin_attack_log(user, target, "Used \the [name] containing [contained] to splash the victim.", "Was splashed by \the [name] containing [contained].", "used \the [name] containing [contained] to splash")

	user.visible_message("<span class='danger'>[target] has been splashed with something by [user]!</span>", "<span class = 'notice'>You splash the solution onto [target].</span>")
	reagents.splash(target, reagents.total_volume)
	return 1

/obj/item/reagent_containers/proc/self_feed_message(mob/user, feed_volume = 0)
	to_chat(user, "<span class='notice'>You eat \the [src]</span>")

/obj/item/reagent_containers/proc/other_feed_message_start(mob/user, mob/target)
	user.visible_message("<span class='warning'>[user] is trying to feed [target] \the [src]!</span>")

/obj/item/reagent_containers/proc/other_feed_message_finish(mob/user, mob/target, feed_volume = 0)
	user.visible_message("<span class='warning'>[user] has fed [target] \the [src]!</span>")

/obj/item/reagent_containers/proc/feed_sound(mob/user)
	playsound(user, SFX_DRINK, rand(45, 60), TRUE)

/obj/item/reagent_containers/proc/standard_feed_mob(mob/user, mob/target, bypass_resist = FALSE) // This goes into attack
	if(!istype(target))
		return 0

	if(!reagents || !reagents.total_volume)
		to_chat(user, "<span class='notice'>\The [src] is empty.</span>")
		return 1

	// only carbons can eat
	if(istype(target, /mob/living/carbon) && user.a_intent != I_HURT)
		if(target == user)
			var/feed_amount = min(MOUTH_CAPACITY, issmall(user) ? ceil(amount_per_transfer_from_this * 0.5) : amount_per_transfer_from_this)
			if(istype(user, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = user
				if(!H.can_eat(src))
					return
				if(!H.ingest_reagents(reagents, feed_amount))
					reagents.trans_to_mob(user, feed_amount, CHEM_INGEST)
			else
				reagents.trans_to_mob(user, feed_amount, CHEM_INGEST)

			user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN) //puts a limit on how fast people can eat/drink things
			self_feed_message(user, feed_amount)
			feed_sound(user)
			return 1


		else
			var/mob/living/carbon/H = target
			if(!H.can_force_feed(user, src))
				return

			other_feed_message_start(user, target)

			user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
			var/feed_amount = min(MOUTH_CAPACITY, amount_per_transfer_from_this)
			if(!do_mob(user, target, time = max(1.5 SECONDS, round(feed_amount / 2)))) // 1.5 to 3 seconds
				return

			if(!H.can_force_feed(user, src, check_resist = !bypass_resist)) // Secondary check since things could change during do_mob
				return

			other_feed_message_finish(user, target, feed_amount)

			var/contained = reagentlist()
			admin_attack_log(user, target, "Fed the victim with [name] (Reagents: [contained])", "Was fed [src] (Reagents: [contained])", "used [src] (Reagents: [contained]) to feed")

			if(ishuman(H))
				var/mob/living/carbon/human/HU = H
				if(!HU.ingest_reagents(reagents, feed_amount))
					reagents.trans_to_mob(target, feed_amount, CHEM_INGEST)
			else
				reagents.trans_to_mob(target, feed_amount, CHEM_INGEST)

			feed_sound(user)
			return 1

	return 0

/obj/item/reagent_containers/proc/standard_pour_into(mob/user, atom/target) // This goes into afterattack and yes, it's atom-level
	if(!target.reagents)
		return 0

	// Ensure we don't splash beakers and similar containers.
	if(!target.is_open_container() && istype(target, /obj/item/reagent_containers))
		to_chat(user, "<span class='notice'>\The [target] is closed.</span>")
		return 1
	// Otherwise don't care about splashing.
	else if(!target.is_open_container())
		return 0

	if(!reagents || !reagents.total_volume)
		to_chat(user, "<span class='notice'>[src] is empty.</span>")
		return 1

	if(!target.reagents.get_free_space())
		to_chat(user, "<span class='notice'>[target] is full.</span>")
		return 1

	var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
	playsound(target, 'sound/effects/using/bottles/transfer1.ogg')
	to_chat(user, "<span class='notice'>You transfer [trans] units of the solution to \the [target].</span>")
	return 1

/obj/item/reagent_containers/do_surgery(mob/living/carbon/M, mob/living/user)
	if(user.zone_sel.selecting != BP_MOUTH) //in case it is ever used as a surgery tool
		return ..()

/obj/item/reagent_containers/AltClick(mob/user)
	if(!CanPhysicallyInteract(user))
		return
	if(!possible_transfer_amounts)
		return

	var/list/modes = list()
	for(var/mode in params2list(possible_transfer_amounts))
		modes += text2num(mode)

	var/current_index = modes.Find(amount_per_transfer_from_this)
	if(current_index == modes.len)
		amount_per_transfer_from_this = modes[1]
	else
		amount_per_transfer_from_this = modes[current_index + 1]

	to_chat(user, SPAN("notice", "You set the next amount per tranfser from \the [name]: <b>[amount_per_transfer_from_this]<b>"))

/obj/item/reagent_containers/CtrlAltClick(mob/user)
	if(possible_transfer_amounts)
		if(CanPhysicallyInteract(user))
			set_APTFT()
	else
		return ..()

/obj/item/reagent_containers/examine(mob/user, infix)
	. = ..()

	if(hasHUD(user, HUD_SCIENCE))
		. += SPAN_NOTICE("The [src] contains: [reagents.get_reagents()].")
