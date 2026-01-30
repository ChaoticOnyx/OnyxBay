
/obj/item/reagent_containers/food/donkpocket
	name = "Donk-pocket"
	desc = "The food of choice for the seasoned traitor."
	icon_state = "donkpocket"
	filling_color = "#dedeab"
	center_of_mass = "x=16;y=10"

	nutriment_desc = list("heartiness" = 3)
	nutriment_amt = 9
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 3,
		/datum/reagent/nutriment/protein/cooked = 2.5
		)
	bitesize = 3 // 227.5 nutrition, 5 bites

	var/warm = FALSE
	var/list/heated_reagents = list(/datum/reagent/tricordrazine = 5)

/obj/item/reagent_containers/food/donkpocket/Initialize()
	. = ..()
	add_think_ctx("think_cool", CALLBACK(src, nameof(.proc/cooling)), 0)

/obj/item/reagent_containers/food/donkpocket/proc/heat()
	if(warm)
		return
	warm = TRUE
	for(var/reagent in heated_reagents)
		reagents.add_reagent(reagent, heated_reagents[reagent])
	bitesize = 6
	SetName("Warm " + name)
	cooltime()

/obj/item/reagent_containers/food/donkpocket/proc/cooltime()
	if(warm)
		set_next_think_ctx("think_cool", world.time + 7 MINUTES)
	return

/obj/item/reagent_containers/food/donkpocket/proc/cooling(warm)
	if(!warm)
		return

	warm = FALSE
	for(var/reagent in heated_reagents)
		reagents.del_reagent(reagent)
	SetName(initial(name))

/obj/item/reagent_containers/food/donkpocket/sinpocket
	name = "\improper Sin-pocket"
	desc = "The food of choice for the veteran. Do <B>NOT</B> overconsume."
	filling_color = "#6d6d00"
	heated_reagents = list(/datum/reagent/tricordrazine = 5, /datum/reagent/drink/doctor_delight = 5, /datum/reagent/hyperzine = 0.75, /datum/reagent/synaptizine = 0.25)
	var/has_been_heated = 0

/obj/item/reagent_containers/food/donkpocket/sinpocket/Initialize()
	. = ..()
	add_think_ctx("think_heat", CALLBACK(src, nameof(.proc/heat)), 0)

/obj/item/reagent_containers/food/donkpocket/sinpocket/attack_self(mob/user)
	if(has_been_heated)
		to_chat(user, "<span class='notice'>The heating chemicals have already been spent.</span>")
		return
	has_been_heated = 1
	user.visible_message("<span class='notice'>[user] crushes \the [src] package.</span>", "You crush \the [src] package and feel a comfortable heat build up.")
	set_next_think_ctx("think_heat", world.time + 20 SECONDS)

/obj/item/reagent_containers/food/donkpocket/sinpocket/heat(user)
	if(user)
		to_chat(user, "You think \the [src] is ready to eat about now.")
	. = ..()
