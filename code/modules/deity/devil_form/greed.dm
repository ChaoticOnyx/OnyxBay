GLOBAL_LIST_INIT(infernal_lathe_recipes, list(); for(var/recipe in subtypesof(/datum/infernal_lathe/recipe)) infernal_lathe_recipes.Add(new recipe));

/datum/modifier/sin/greed
	name = "Greed"
	var/weakref/item_to_find

/datum/modifier/sin/greed/New(new_holder, new_origin)
	. = ..()
	//set_next_think(world.time + 5 SECONDS)
	find_target()

/datum/modifier/sin/greed/Destroy()
	item_to_find = null
	return ..()

/datum/modifier/sin/greed/proc/find_target()
	var/list/seeing_objs = list()
	var/list/seeing_mobs = list()
	get_mobs_and_objs_in_view_fast(get_turf(holder), world.view, seeing_mobs, seeing_objs)
	for(var/atom/I in seeing_objs)
		if(!isitem(I))
			seeing_objs.Remove(I)
			continue

		if(!isturf(I.loc))
			seeing_objs.Remove(I)

	if(!seeing_objs.len)
		return

	var/obj/item/target = pick(seeing_objs)
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

/datum/modifier/sin/greed/proc/forget_target()
	unregister_signal(item_to_find, SIGNAL_QDELETING)
	unregister_signal(item_to_find, SIGNAL_ITEM_PICKED)
	item_to_find = null
	to_chat(holder, SPAN_DANGER("Forget about it!"))
	find_target()

/datum/modifier/sin/greed/proc/item_picked(obj/item/I, mob/user)
	if(user != holder)
		return

	unregister_signal(I, SIGNAL_QDELETING)
	unregister_signal(I, SIGNAL_ITEM_PICKED)
	item_to_find = null
	to_chat(holder, SPAN_DANGER("I FOUND IT!"))
	user.drop(I, null, TRUE)
	qdel(I)

/datum/deity_power/structure/infernal_lathe
	build_distance = 0
	health_max = 200
	power_path = /obj/structure/deity/infernal_lathe

/obj/structure/deity/infernal_lathe
	name = "Infernal Lathe"
	desc = "Infernal Lathe."
	icon_state = "inflathe_inactive"
	var/destination

/obj/structure/deity/infernal_lathe/attack_hand(mob/user)
	if(user.mind?.godcultist?.linked_deity == linked_deity || user.mind?.deity == linked_deity)
		tgui_interact(user)

/obj/structure/deity/infernal_lathe/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "InfernalLathe", "Infernal Lathe")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/structure/deity/infernal_lathe/tgui_data(mob/user)
	var/list/data = list(
		"points" = 0
	)
	for(var/datum/infernal_lathe/recipe/recipe in GLOB.infernal_lathe_recipes)
		var/list/infernal_recipe = list(
			"name" = recipe.name,
			"path" = recipe.path,
			"cost" = recipe.cost,
			"hidden" = recipe.hidden,
			"category" = recipe.category,
			"research" = recipe.research_needed
		)
		data["recipes"] += list(infernal_recipe)

	return data

/obj/structure/deity/infernal_lathe/tgui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	pass()

/datum/infernal_lathe/recipe
	var/name = "object"
	var/path
	var/cost
	var/hidden
	var/category
	var/research_needed

/datum/infernal_lathe/recipe/flashdark
	name = "flashlight"
	path = /obj/item/device/flashlight/flashdark
	category = "General"
	cost = 1

/datum/infernal_lathe/recipe/sword
	name = "sword"
	path = /obj/item/melee/cultblade
	category = "Weapons"
	cost = 1

/datum/infernal_lathe/recipe/medkit
	name = "medkit"
	path = /obj/item/storage/firstaid/combat
	category = "Medicine"
	cost = 1
