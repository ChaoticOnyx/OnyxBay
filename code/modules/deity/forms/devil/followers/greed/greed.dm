/datum/evolution_holder/greed
	evolution_categories = list(
		/datum/evolution_category/greed
	)
	default_modifiers = list(/datum/modifier/sin/greed)

/datum/evolution_category/greed
	name = "Sin of Greed"
	items = list(
		/datum/evolution_package/infernal_lathe,
		/datum/evolution_package/interdimensional_locker,
		/datum/evolution_package/sleight_of_hand,
	)

/datum/evolution_package/infernal_lathe
	name = "Infernal Lathe"
	desc = "Create everything (almost) ex nihilo."
	actions = list(
		/datum/action/cooldown/spell/infernal_lathe
	)

/datum/evolution_package/interdimensional_locker
	name = "Interdimensional Locker"
	desc = "Store your precious things in a neat bluespace locker."
	actions = list(
		/datum/action/cooldown/spell/interdimensional_locker
	)

/datum/evolution_package/sleight_of_hand
	name = "Sleight of Hand"
	desc = "Become proficient at stealing items from others."
	actions = list(
		/datum/action/cooldown/spell/sleight_of_hand
	)

/datum/modifier/sin/greed
	name = "Greed"
	var/weakref/item_to_find
	var/item_points = 0

/datum/modifier/sin/greed/New(new_holder, new_origin)
	. = ..()
	find_target()
	add_think_ctx("not_found_ctx", CALLBACK(src, nameof(.proc/not_found_ctx)), 0)

/datum/modifier/sin/greed/Destroy()
	item_to_find = null
	return ..()

/datum/modifier/sin/greed/think()
	find_target()

/datum/modifier/sin/greed/proc/find_target()
	var/atom/former_target = item_to_find
	if(istype(former_target))
		unregister_signal(former_target, SIGNAL_QDELETING)
		unregister_signal(former_target, SIGNAL_ITEM_PICKED)

	item_to_find = null

	var/list/seeing_objs = list()
	var/list/seeing_mobs = list()
	get_mobs_and_objs_in_view_fast(get_turf(holder), world.view, seeing_mobs, seeing_objs)
	for(var/atom/I in seeing_objs)
		if(!isitem(I))
			seeing_objs.Remove(I)
			continue

		if(I.invisibility > 0)
			seeing_objs.Remove(I)
			continue

		if(!isturf(I.loc) && !ismob(I.loc))
			seeing_objs.Remove(I)
			continue

		var/atom/movable/movable = I
		if(movable?.anchored)
			seeing_objs.Remove(I)
			continue

	if(!seeing_objs.len)
		set_next_think(world.time + 15 SECONDS)
		set_next_think_ctx("not_found_ctx", 0)
		return

	var/obj/item/target = safepick(seeing_objs)
	register_signal(target, SIGNAL_QDELETING, nameof(.proc/forget_target))
	register_signal(target, SIGNAL_ITEM_PICKED, nameof(.proc/item_picked))
	item_to_find = weakref(target)
	to_chat(holder, SPAN_DANGER("I need \the [target]!"))

	var/list/images_to_show = list()
	var/image/IMG = image(null, target, layer = target.layer)
	IMG.appearance_flags |= KEEP_TOGETHER | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	IMG.vis_contents += target

	IMG.filters += filter(type = "outline", size = 2, color = COLOR_RED)
	images_to_show += IMG

	var/image/pointer = image('icons/effects/effects.dmi', target, "arrow", layer = HUD_ABOVE_ITEM_LAYER)
	pointer.pixel_x = target.pixel_x
	pointer.pixel_y = target.pixel_y
	QDEL_IN(pointer, 2 SECONDS)
	images_to_show += pointer

	holder.client?.images |= images_to_show
	set_next_think_ctx("not_found_ctx", world.time + 3 MINUTES)

/datum/modifier/sin/greed/proc/forget_target()
	var/atom/former_target = item_to_find
	if(istype(former_target))
		unregister_signal(former_target, SIGNAL_QDELETING)
		unregister_signal(former_target, SIGNAL_ITEM_PICKED)
	item_to_find = null
	to_chat(holder, SPAN_DANGER("Forget about it!"))
	find_target()

/datum/modifier/sin/greed/proc/item_picked(obj/item/I, mob/user)
	if(user != holder)
		return

	unregister_signal(I, SIGNAL_QDELETING)
	unregister_signal(I, SIGNAL_ITEM_PICKED)
	to_chat(holder, SPAN_DANGER("I found my precious [I.name]!"))
	item_to_find = null
	item_points += 3000
	QDEL_IN(I, 5)
	set_next_think_ctx("not_found_ctx", 0)
	set_next_think(world.time + 30 SECONDS)

/datum/modifier/sin/greed/proc/not_found_ctx()
	forget_target()
