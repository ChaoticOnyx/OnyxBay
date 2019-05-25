//Heya
/mob/living/simple_animal/smallgay
	name = "that dog"
	desc = "What the hell is this."
	icon = 'icons/mob/smallgames.dmi'
	icon_state = "thatdog"
	icon_living = "thatdog"
	icon_dead = "thatdog"
	mob_size = MOB_SMALL
	speak_emote = list("barks")
	emote_hear = list("barks")
	emote_see = list("barks")
	speak_chance = 1
	turns_per_move = 0
	anchored = 1
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat
	response_help  = "pets"
	response_disarm = "pokes"
	response_harm   = "hits"
	stop_automated_movement = 1
	friendly = "barks at"
	mob_size = 5
	var/obj/item/inventory_head
	var/obj/item/inventory_mask
	possession_candidate = 1
	can_escape = 1
	pixel_x = -128
	pixel_y = -64