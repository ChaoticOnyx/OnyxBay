/obj/item/dice
	name = "d6"
	desc = "A dice with six sides."
	icon = 'icons/obj/dice.dmi'
	icon_state = "d66"
	w_class = ITEM_SIZE_TINY
	mod_weight = 0.1
	mod_reach = 0.1
	mod_handy = 0.1
	var/sides = 6
	attack_verb = list("diced")

/obj/item/dice/New()
	icon_state = "[name][rand(1,sides)]"

/obj/item/dice/dp/New()
	icon_state = "[name][10*rand(0,sides-1)]"//Because dp starts from 00 and ends on 90

/obj/item/dice/d4
	name = "d4"
	desc = "A dice with four sides."
	icon_state = "d44"
	sides = 4

/obj/item/dice/d8
	name = "d8"
	desc = "A dice with eight sides."
	icon_state = "d88"
	sides = 8

/obj/item/dice/d10
	name = "d10"
	desc = "A dice with ten sides."
	icon_state = "d1010"
	sides = 10

/obj/item/dice/d12
	name = "d12"
	desc = "A dice with twelve sides."
	icon_state = "d1212"
	sides = 12

/obj/item/dice/d20
	name = "d20"
	desc = "A dice with twenty sides."
	icon_state = "d2020"
	sides = 20

/obj/item/dice/dp
	name = "dp"
	desc = "A dice with ten sides. This one is for the tens digit."
	icon_state = "dp10"
	sides = 10

/obj/item/dice/proc/roll_die()
	var/result = rand(1, sides)
	return list(result, "")

/obj/item/dice/d20/roll_die()
	var/result = rand(1, sides)
	var/comment = ""
	if(result == 20)
		comment = "Nat 20!"
	else if(result == 1)
		comment = "Ouch, bad luck."
	return list(result, comment)

/obj/item/dice/dp/roll_die()
	var/result = 10 * rand(0, sides-1)//Because dp starts from 00 and ends on 90
	return list(result, "")

/obj/item/dice/attack_self(mob/user as mob)
	var/list/roll_result = roll_die()
	var/result = roll_result[1]
	var/comment = roll_result[2]
	icon_state = "[name][result]"
	user.visible_message("<span class='notice'>[user] has thrown [src]. It lands on [result]. [comment]</span>", \
						 "<span class='notice'>You throw [src]. It lands on a [result]. [comment]</span>", \
						 "<span class='notice'>You hear [src] landing on a [result]. [comment]</span>")

/obj/item/dice/throw_impact(atom/hit_atom, speed)
	..()
	var/list/roll_result = roll_die()
	var/result = roll_result[1]
	var/comment = roll_result[2]
	icon_state = "[name][result]"
	src.visible_message("<span class='notice'>\The [src] lands on [result]. [comment]</span>")
