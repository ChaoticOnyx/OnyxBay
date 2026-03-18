
/obj/item/reagent_containers/food/monkeycube
	name = "monkey cube"
	desc = "Just add water!"
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	icon_state = "monkeycube"
	filling_color = "#adac7f"
	center_of_mass = "x=16;y=14"
	startswith = list(/datum/reagent/nutriment/protein/compressed = 50)
	bitesize = 60 // 312.5 nutrition, 1 bite, 1 hole in the chest

	var/wrapped = 0
	var/growing = 0
	var/monkey_type = /mob/living/carbon/human/monkey

/obj/item/reagent_containers/food/monkeycube/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)

/obj/item/reagent_containers/food/monkeycube/proc/Expand(atom/location)
	if(!growing)
		growing = 1
		src.visible_message("<span class='notice'>\The [src] expands!</span>")
		var/mob/monkey = new monkey_type
		if(location)
			monkey.dropInto(location)
		else
			monkey.dropInto(get_turf(src))
		qdel_self()

/obj/item/reagent_containers/food/monkeycube/proc/Unwrap(mob/user)
	icon_state = "monkeycube"
	desc = "Just add water!"
	to_chat(user, "You unwrap the cube.")
	playsound(src, 'sound/effects/using/wrapper/unwrap1.ogg', rand(50, 75), TRUE)
	wrapped = 0
	atom_flags |= ATOM_FLAG_OPEN_CONTAINER

/obj/item/reagent_containers/food/monkeycube/get_scooped(obj/item/material/kitchen/utensil/U, mob/user)
	if(!istype(U))
		return FALSE
	to_chat(user, SPAN("notice", "\The [src] is so dense, you can't manage to get it onto \the [U]!"))
	return FALSE

/obj/item/reagent_containers/food/monkeycube/On_Consume(mob/M, eaten_with_fork)
	Expand(get_turf(M))
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.visible_message(SPAN("warning", "A screeching creature bursts out of [H]'s chest!"))
		var/obj/item/organ/external/organ = H.get_organ(BP_CHEST)
		organ.take_pierce_damage(150, "Animal escaping the ribcage")
	else
		M.visible_message(\
			SPAN("warning", "A screeching creature bursts out of [M]!"),\
			SPAN("warning", "You feel like your body is being torn apart from the inside!"))
		M.gib()

/obj/item/reagent_containers/food/monkeycube/on_reagent_change()
	if(reagents.has_reagent(/datum/reagent/water))
		Expand()

/obj/item/reagent_containers/food/monkeycube/wrapped
	desc = "Still wrapped in some paper."
	icon_state = "monkeycubewrap"
	item_flags = 0
	obj_flags = 0
	wrapped = 1

/obj/item/reagent_containers/food/monkeycube/farwacube
	name = "farwa cube"
	monkey_type = /mob/living/carbon/human/farwa

/obj/item/reagent_containers/food/monkeycube/wrapped/farwacube
	name = "farwa cube"
	monkey_type = /mob/living/carbon/human/farwa

/obj/item/reagent_containers/food/monkeycube/stokcube
	name = "stok cube"
	monkey_type = /mob/living/carbon/human/stok

/obj/item/reagent_containers/food/monkeycube/wrapped/stokcube
	name = "stok cube"
	monkey_type = /mob/living/carbon/human/stok

/obj/item/reagent_containers/food/monkeycube/neaeracube
	name = "neaera cube"
	monkey_type = /mob/living/carbon/human/neaera

/obj/item/reagent_containers/food/monkeycube/wrapped/neaeracube
	name = "neaera cube"
	monkey_type = /mob/living/carbon/human/neaera

/obj/item/reagent_containers/food/monkeycube/punpuncube
	name = "compressed Pun Pun"
	desc = "What's up, little buddy? You look dehydrated."
	monkey_type = /mob/living/carbon/human/monkey/punpun

/obj/item/reagent_containers/food/monkeycube/wrapped/punpuncube
	name = "Pun Pun"
	desc = "What's up, little buddy? You look dehydrated."
	monkey_type = /mob/living/carbon/human/monkey/punpun
