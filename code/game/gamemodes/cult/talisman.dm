/obj/item/paper/talisman
	icon_state = "paper_talisman"
	dynamic_icon = TRUE
	var/imbue = null
	info = "<center><img src='talisman.png'></center><br/><br/>"

/obj/item/paper/talisman/attack_self(mob/living/user)
	if(iscultist(user))
		to_chat(user, "Attack your target to use this talisman.")
	else
		to_chat(user, "You see strange symbols on the paper. Are they supposed to mean something?")

/obj/item/paper/talisman/attack(mob/living/M, mob/living/user)
	return

/obj/item/paper/talisman/emp/attack_self(mob/living/user)
	if(iscultist(user))
		to_chat(user, "This is an emp talisman.")
	..()

/obj/item/paper/talisman/emp/afterattack(atom/target, mob/user, proximity)
	if(!iscultist(user))
		return
	if(!proximity)
		return
	user.say("Ta'gh fara[pick("'","`")]qha fel d'amar det!")
	user.visible_message("<span class='danger'>\The [user] invokes \the [src] at [target].</span>", "<span class='danger'>You invoke \the [src] at [target].</span>")
	target.emp_act(1)
	qdel(src)

/obj/item/paper/talisman/stun/afterattack(atom/target, mob/user, proximity)
	if(!iscultist(user))
		return
	if(!istype(target, /mob/living))
		return
	if(!proximity)
		return
	user.say("Ra'gh fara[pick("'","`")]ydar fel d'amar det in girdiun!")
	user.visible_message("<span class='danger'>\The [user] invokes \the [src] at [target].</span>", "<span class='danger'>You invoke \the [src] at [target].</span>")
	var/obj/item/nullrod/N = locate() in target
	if(N)
		return
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.eye_blurry += 50
		C.Weaken(3)
		C.Stun(5)
	else if(issilicon(target))
		var/mob/living/silicon/S = target
		S.Weaken(10)
	qdel(src)
