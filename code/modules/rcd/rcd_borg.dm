/obj/item/construction/rcd/borg
	desc = "A device used to rapidly build walls and floors."
	var/energyfactor = 72

/obj/item/construction/rcd/borg/get_matter(mob/user)
	if(!issilicon(user))
		return 0

	var/mob/living/silicon/robot/borgy = user
	if(!borgy.cell)
		return 0

	max_matter = borgy.cell.maxcharge
	return borgy.cell.charge

/obj/item/construction/rcd/borg/useResource(amount, mob/user)
	if(!issilicon(user))
		return 0

	var/mob/living/silicon/robot/borgy = user
	if(!borgy.cell)
		return 0

	. = borgy.cell.use(amount * energyfactor) //borgs get 1.3x the use of their RCDs
	if(!. && user)
		show_splash_text(user, "insufficient charge!")
	return .

/obj/item/construction/rcd/borg/checkResource(amount, mob/user)
	if(!issilicon(user))
		return 0

	var/mob/living/silicon/robot/borgy = user
	if(!borgy.cell)
		return 0

	. = borgy.cell.charge >= (amount * energyfactor)
	if(!. && user)
		show_splash_text(user, "insufficient charge!")
	return .
