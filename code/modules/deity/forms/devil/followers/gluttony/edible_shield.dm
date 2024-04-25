/datum/action/cooldown/spell/edible_shield
	name = "edible_shield"
	desc = "edible_shield!!!"
	button_icon_state = "devil_edible_shield"

	cooldown_time = 30 SECONDS

	cast_range = 1 /// Basically must be adjacent
	var/list/foods_to_orbit = list()
	var/list/foods = list()

/datum/action/cooldown/spell/edible_shield/New()
	. = ..()
	add_think_ctx("food_orbit", CALLBACK(src, nameof(.proc/add_food)), 0)

/datum/action/cooldown/spell/edible_shield/Destroy()
	foods.Cut()
	foods_to_orbit.Cut()
	return ..()

/datum/action/cooldown/spell/edible_shield/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/edible_shield/cast(mob/living/carbon/human/cast_on)
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return

	register_signal(H, SIGNAL_HUMAN_CHECK_SHIELDS, nameof(.proc/check_shield))
	for(var/obj/item/reagent_containers/food/food in view(world.view))
		food.forceMove(H)
		foods_to_orbit |= food
		register_signal(food, SIGNAL_QDELETING, nameof(.proc/remove_food))

	set_next_think_ctx("food_orbit", world.time + rand(5, 10))

/datum/action/cooldown/spell/edible_shield/proc/add_food()
	var/obj/item/reagent_containers/food/food = pick_n_take(foods_to_orbit)
	if(QDELETED(food))
		return

	food.orbit(owner, 25, TRUE)
	foods |= food

	if(LAZYLEN(foods_to_orbit))
		set_next_think_ctx("food_orbit", world.time + rand(5, 10))

/datum/action/cooldown/spell/edible_shield/proc/check_shield()
	var/obj/item/reagent_containers/food/blocker = safepick(foods)
	if(!istype(blocker))
		return FALSE

	qdel(blocker)
	new /obj/effect/decal/cleanable/ash(owner.loc)
	return PROJECTILE_FORCE_BLOCK

/datum/action/cooldown/spell/edible_shield/proc/remove_food(atom/movable/qdeleted_food)
	qdeleted_food.stop_orbit(owner.orbiters)
	foods -= qdeleted_food
