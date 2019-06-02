

/obj/item/organ/internal/cancer
	name = "strange biostructure"
	desc = "Strange abhorrent biostructure of unknown origins. Is that an alien organ, a xenoparasite or some sort of space cancer? Is that normal to bear things like that inside you?"
	icon_state = "Strange_biostructure"
	w_class = ITEM_SIZE_SMALL
	organ_tag = BP_CANCER
	parent_organ = BP_CHEST
	min_bruised_damage = 25
	min_broken_damage = 45
	max_damage = 70
	relative_size = 60
	var/chance = 0
	var/infectious = 0

/obj/item/organ/internal/cancer/New(var/mob/living/carbon/holder)
	..()
	parent_organ = pick(BP_CHEST, BP_HEAD, BP_GROIN)


/obj/item/organ/internal/cancer/Process()

	..()
	if((!infectious) && prob(chance))
		new /obj/item/organ/internal/cancer(owner)

	if(infectious)
		infect()
	else
		chance += 0.5
		if(chance > 50)
			infectious = 1
	owner.adjustToxLoss(0.01)

/obj/item/organ/internal/cancer/die()
	src.dead_icon = "Strange_biostructure_dead"
	..()


/obj/item/organ/internal/cancer/proc/infect()
	var/l = list()
	for(var/mob/living/carbon/M in range(1,owner))
		var/obj/item/organ/internal/cancer/CAN = locate() in M.contents
		if(!CAN)
			l += M
	var/k = pick(l)
	if(infection_chance(k) == 0)
		return
	if(k == owner)
		return
	if(prob(50))
		new /obj/item/organ/internal/cancer(k)