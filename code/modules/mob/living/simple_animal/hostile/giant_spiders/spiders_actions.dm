
/datum/action/innate/spider
	button_icon = 'icons/hud/actions.dmi'
	background_icon_state = "bg_alien"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_ALIVE

/datum/action/innate/spider/lay_web
	name = "Spin Web"
	//desc = "Spin a web to slow down potential prey."
	button_icon_state = "lay_web"

/datum/action/innate/spider/lay_web/Activate()
	if(!istype(owner, /mob/living/simple_animal/hostile/giant_spider))
		return
	var/mob/living/simple_animal/hostile/giant_spider/spider = owner

	if(!isturf(spider.loc))
		return
	var/turf/spider_turf = get_turf(spider)

	var/obj/structure/spider/stickyweb/web = locate() in spider_turf
	if(web)
		if(!spider.web_sealer || istype(web, /obj/structure/spider/stickyweb/sealed))
			to_chat(spider, SPAN_WARNING("There's already a web here!"))
			return

	if(!spider.is_busy)
		spider.is_busy = TRUE
		if(web)
			spider.visible_message(SPAN_NOTICE("[spider] begins to pack more webbing onto the web."),SPAN_NOTICE("You begin to seal the web."))
		else
			spider.visible_message(SPAN_NOTICE("[spider] begins to secrete a sticky substance."),SPAN_NOTICE("You begin to lay a web."))
		spider.stop_automated_movement = TRUE
		if(do_after(spider, 40 * spider.web_speed, target = spider_turf))
			if(spider.is_busy && spider.loc == spider_turf)
				if(web)
					qdel(web)
					new /obj/structure/spider/stickyweb/sealed(spider_turf)
				new /obj/structure/spider/stickyweb(spider_turf)
		spider.is_busy = FALSE
		spider.stop_automated_movement = FALSE
	else
		to_chat(spider, SPAN_WARNING("You're already doing something else!"))

/datum/action/innate/spider/wrap
	name = "Wrap"
	button_icon_state = "wrap"
	var/click_handler = /datum/click_handler/spiders/wrap

/datum/action/innate/spider/wrap/Trigger()
	if(!istype(usr, /mob/living/simple_animal/hostile/giant_spider/midwife))
		return TRUE
	var/mob/living/simple_animal/hostile/giant_spider/midwife/user = usr
	activate(user)
	return TRUE

/datum/action/innate/spider/wrap/proc/activate(mob/living/user)
	if(!IsAvailable())
		return FALSE
	if(active)
		to_chat(user, SPAN_NOTICE("You no longer prepare to wrap something in a cocoon."))
		user.PopClickHandler()
		button.update_icon()
		active = FALSE
		return FALSE
	else
		to_chat(user, SPAN_NOTICE("You prepare to wrap something in a cocoon. <B>Left-click your target to start wrapping!</B>"))
		user.PushClickHandler(/datum/click_handler/spiders/wrap)
		var/image/img = image(button_icon,button,"bg_active")
		img.pixel_x = 0
		img.pixel_y = 0
		button.AddOverlays(img)
		active = TRUE
		return TRUE

/datum/action/innate/spider/wrap/ActivateOnClick(atom/target)
	if(owner.incapacitated() || !istype(owner, /mob/living/simple_animal/hostile/giant_spider/midwife))
		return

	var/mob/living/simple_animal/hostile/giant_spider/midwife/user = owner

	if(user.Adjacent(target) && (ismob(target) || isobj(target)))
		var/atom/movable/target_atom = target
		if(target_atom.anchored)
			return
		user.cocoon_target = target_atom
		INVOKE_ASYNC(user, nameof(/mob/living/simple_animal/hostile/giant_spider/midwife.proc/cocoon))
		return TRUE


/datum/action/innate/spider/lay_eggs
	name = "Lay Eggs"
	//desc = "Lay a cluster of eggs, which will soon grow into a normal spider."
	button_icon_state = "lay_eggs"
	var/enriched = FALSE

/datum/action/innate/spider/lay_eggs/IsAvailable()
	. = ..()
	if(!.)
		return
	if(!istype(owner, /mob/living/simple_animal/hostile/giant_spider/midwife))
		return FALSE
	var/obj/structure/spider/eggcluster/eggs = locate() in get_turf(owner)
	if(eggs)
		to_chat(owner, SPAN_WARNING("There is already a cluster of eggs here!"))
		return FALSE
	var/mob/living/simple_animal/hostile/giant_spider/midwife/S = owner
	if(enriched && !S.fed)
		return FALSE
	return TRUE

/datum/action/innate/spider/lay_eggs/Activate()
	if(!istype(owner, /mob/living/simple_animal/hostile/giant_spider/midwife))
		return
	var/mob/living/simple_animal/hostile/giant_spider/midwife/spider = owner

	var/obj/structure/spider/eggcluster/eggs = locate() in get_turf(spider)
	if(eggs)
		to_chat(spider, SPAN_WARNING("There is already a cluster of eggs here!"))
	else if(enriched && !spider.fed)
		to_chat(spider, SPAN_WARNING("You are too hungry to do this!"))
	else if(!spider.is_busy)
		spider.is_busy = TRUE
		spider.visible_message(SPAN_NOTICE("[spider] begins to lay a cluster of eggs."), SPAN_NOTICE("You begin to lay a cluster of eggs."))
		spider.stop_automated_movement = TRUE
		if(do_after(spider, spider.egg_lay_time, target = get_turf(spider)))
			if(spider.is_busy)
				eggs = locate() in get_turf(spider)
				if(!eggs || !isturf(spider.loc))
					var/egg_choice = enriched ? /obj/effect/mob_spawn/ghost_role/spider/enriched : /obj/effect/mob_spawn/ghost_role/spider
					var/obj/effect/mob_spawn/ghost_role/spider/new_eggs = new egg_choice(get_turf(spider))
					new_eggs.directive = spider.directive
					new_eggs.faction = spider.faction
					if(enriched)
						spider.fed--
					owner.update_action_buttons()

		spider.is_busy = FALSE
		spider.stop_automated_movement = FALSE

/datum/action/innate/spider/lay_eggs/enriched
	name = "Lay Enriched Eggs"
	//desc = "Lay a cluster of eggs, which will soon grow into a greater spider.  Requires you drain a human per cluster of these eggs."
	button_icon_state = "lay_enriched_eggs"
	enriched = TRUE

/datum/action/innate/spider/set_directive
	name = "Set Directive"
	//desc = "Set a directive for your children to follow."
	button_icon_state = "directive"

/datum/action/innate/spider/set_directive/IsAvailable()
	if(..())
		if(!istype(owner, /mob/living/simple_animal/hostile/giant_spider))
			return FALSE
		return TRUE

/datum/action/innate/spider/set_directive/Activate()
	if(!istype(owner, /mob/living/simple_animal/hostile/giant_spider/midwife))
		return
	var/mob/living/simple_animal/hostile/giant_spider/midwife/spider = owner
	spider.directive = input(spider, "Enter the new directive", "Create directive", "[spider.directive]") as text
	if(isnull(spider.directive))
		return
	message_admins("[owner] set its directive to: '[spider.directive]'.")
	log_game("[key_name(owner)] set its directive to: '[spider.directive]'.")

/datum/action/innate/spider/comm
	name = "Command"
	//desc = "Send a command to all living spiders."
	button_icon_state = "command"

/datum/action/innate/spider/comm/IsAvailable()
	if(..())
		if(!istype(owner, /mob/living/simple_animal/hostile/giant_spider/midwife))
			return FALSE
		return TRUE

/datum/action/innate/spider/comm/Trigger(trigger_flags)
	var/input = input(owner, "Input a command for your legions to follow.", "Command") as text
	if(QDELETED(src) || !input || !IsAvailable())
		return FALSE
	spider_command(owner, input)
	return TRUE

/**
 * Sends a message to all spiders from the target.
 *
 * Allows the user to send a message to all spiders that exist.  Ghosts will also see the message.
 * Arguments:
 * * user - The spider sending the message
 * * message - The message to be sent
 */
/datum/action/innate/spider/comm/proc/spider_command(mob/living/user, message)
	if(!message)
		return
	var/my_message
	my_message = SPAN_SPIDER("<b>Command from [user]:</b> [message]")
	for(var/mob/living/simple_animal/hostile/giant_spider/spider in GLOB.spidermobs)
		to_chat(spider, my_message)
	for(var/ghost in GLOB.dead_mob_list_)
		var/link = create_ghost_link(ghost, user, "(F)")
		to_chat(ghost, "[link] [my_message]")
	user.log_message(message)

/datum/action/cooldown/charge/basic_charge/spider
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_ALIVE
	cooldown_time = 30 SECONDS
