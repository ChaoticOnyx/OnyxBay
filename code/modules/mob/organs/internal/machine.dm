/obj/item/organ/internal/cell
	name = "microbattery"
	desc = "A small, powerful cell for use in fully prosthetic bodies."
	icon = 'icons/mob/human_races/organs/cyber.dmi'
	icon_state = "cell"
	dead_icon = "cell-br"
	organ_tag = BP_CELL
	parent_organ = BP_CHEST
	vital = 1
	override_species_icon = TRUE
	var/open
	var/obj/item/cell/cell = /obj/item/cell/high
	//at 0.8 completely depleted after 60ish minutes of constant walking or 130 minutes of standing still
	var/servo_cost = 0.8


/obj/item/organ/internal/cell/New()
	robotize()
	if(ispath(cell))
		cell = new cell(src)
	..()

/obj/item/organ/internal/cell/proc/percent()
	if(!cell)
		return 0
	return PERCENT(get_charge(), cell.maxcharge)

/obj/item/organ/internal/cell/proc/get_charge()
	if(!cell)
		return 0
	if(status & ORGAN_DEAD)
		return 0
	return round(cell.charge*(1 - damage/max_damage))

/obj/item/organ/internal/cell/proc/check_charge(amount)
	return get_charge() >= amount

/obj/item/organ/internal/cell/proc/use(amount)
	if(check_charge(amount))
		cell.use(amount)
		return 1

/obj/item/organ/internal/cell/think()
	..()
	if(!owner)
		return
	if(owner.is_ic_dead())	//not a drain anymore
		return
	if(!is_usable())
		owner.Paralyse(3)
		return
	var/standing = !owner.lying && !owner.buckled //on the edge
	var/drop
	if(!check_charge(servo_cost)) //standing is pain
		drop = 1
	else if(standing)
		use(servo_cost)
		if(world.time - owner.l_move_time < 15) //so is
			if(!use(servo_cost))
				drop = 1
	if(drop)
		if(standing)
			to_chat(owner, "<span class='warning'>You don't have enough energy to stand!</span>")
		owner.Weaken(2)

/obj/item/organ/internal/cell/emp_act(severity)
	..()
	if(cell)
		cell.emp_act(severity)

/obj/item/organ/internal/cell/attackby(obj/item/W, mob/user)
	if(isScrewdriver(W))
		if(open)
			open = 0
			to_chat(user, "<span class='notice'>You screw the battery panel in place.</span>")
		else
			open = 1
			to_chat(user, "<span class='notice'>You unscrew the battery panel.</span>")

	if(isCrowbar(W))
		if(open)
			if(cell)
				user.pick_or_drop(cell)
				to_chat(user, "<span class='notice'>You remove \the [cell] from \the [src].</span>")
				cell = null

	if (istype(W, /obj/item/cell))
		if(open)
			if(cell)
				to_chat(user, "<span class ='warning'>There is a power cell already installed.</span>")
			else if(user.drop(W, src))
				cell = W
				to_chat(user, "<span class = 'notice'>You insert \the [cell].</span>")

/obj/item/organ/internal/cell/replaced()
	..()
	// This is very ghetto way of rebooting an FBP. TODO better way.
	// It's time to do it. This code doesn't allow to resurrect a organic human this way.
	if(owner && owner.is_ic_dead() && BP_IS_ROBOTIC(owner.organs_by_name[parent_organ]))
		owner.set_stat(CONSCIOUS)
		owner.visible_message(SPAN_DANGER("\The [owner] twitches visibly!"))

/obj/item/organ/internal/cell/listen()
	if(get_charge())
		return "faint hum of the power bank"
