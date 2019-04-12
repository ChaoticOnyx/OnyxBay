/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/items.dmi'
	amount = 10
	max_amount = 10
	w_class = ITEM_SIZE_SMALL
	throw_speed = 4
	throw_range = 20
	var/heal_brute = 0
	var/heal_burn = 0
	var/animal_heal = 3

	var/icon_state_default = ""
	var/stack_full = 0 // 1 - stack looks different if it's never been used
	var/stack_empty = 0 // 0 - stack disappears, 1 - stack can be empty, 2 - stack is already empty

/obj/item/stack/medical/New()
	..()
	icon_state_default = icon_state
	if(stack_full)
		icon_state = "[icon_state_default]_full"

/obj/item/stack/medical/use(var/used)
	if(stack_empty == 2)
		return 0

	if(!can_use(used))
		return 0

	amount -= used
	if(amount <= 0)
		if(!stack_empty)
			if(usr)
				usr.remove_from_mob(src)
			qdel(src) //should be safe to qdel immediately since if someone is still using this stack it will persist for a little while longer
			return 1
		else
			stack_empty = 2
			icon_state = "[icon_state_default]_empty"
			name = "empty [name]"
			return 1
	if(icon_state != icon_state_default)
		icon_state = icon_state_default
	return 1

/obj/item/stack/medical/attack(mob/living/carbon/M as mob, mob/user as mob)
	if (stack_empty == 2)
		to_chat(user, "<span class='warning'>\The [src] is empty!</span>")
		return 1

	if (!istype(M))
		to_chat(user, "<span class='warning'>\The [src] cannot be applied to [M]!</span>")
		return 1

	if ( ! (istype(user, /mob/living/carbon/human) || \
			istype(user, /mob/living/silicon)) )
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 1

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(!affecting)
			to_chat(user, "<span class='warning'>\The [M] is missing that body part!</span>")
			return 1

		if(affecting.organ_tag == BP_HEAD)
			if(H.head && istype(H.head,/obj/item/clothing/head/helmet/space))
				to_chat(user, "<span class='warning'>You can't apply [src] through [H.head]!</span>")
				return 1
		else
			if(H.wear_suit && istype(H.wear_suit,/obj/item/clothing/suit/space))
				to_chat(user, "<span class='warning'>You can't apply [src] through [H.wear_suit]!</span>")
				return 1

		if(affecting.robotic >= ORGAN_ROBOT)
			to_chat(user, "<span class='warning'>This isn't useful at all on a robotic limb..</span>")
			return 1

		H.UpdateDamageIcon()

	else

		M.heal_organ_damage((src.heal_brute/2), (src.heal_burn/2))
		user.visible_message( \
			"<span class='notice'>[M] has been applied with [src] by [user].</span>", \
			"<span class='notice'>You apply \the [src] to [M].</span>" \
		)
		use(1)

	M.updatehealth()
/obj/item/stack/medical/bruise_pack
	name = "roll of bandage"
	singular_name = "bandage length"
	desc = "Name brand NanoTrasen dissolvable bandage product."
	icon_state = "bandage"
	item_state = "bandage"
	origin_tech = list(TECH_BIO = 1)
	slot_flags = SLOT_GLOVES
	heal_brute = 1
	animal_heal = 5
	stack_full = 1

/obj/item/stack/medical/bruise_pack/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return 1

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting) //nullchecked by ..()

		if(affecting.is_bandaged())
			to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.name] have already been bandaged.</span>")
			return 1
		else
			user.visible_message("<span class='notice'>\The [user] starts treating [M]'s [affecting.name].</span>", \
					             "<span class='notice'>You start treating [M]'s [affecting.name].</span>" )
			var/used = 0
			for (var/datum/wound/W in affecting.wounds)
				if(W.bandaged)
					continue
				if(used == amount)
					break
				if(!do_mob(user, M, W.damage/5))
					to_chat(user, "<span class='notice'>You must stand still to bandage wounds.</span>")
					break

				if (W.current_stage <= W.max_bleeding_stage)
					user.visible_message("<span class='notice'>\The [user] bandages \a [W.desc] on [M]'s [affecting.name].</span>", \
					                              "<span class='notice'>You bandage \a [W.desc] on [M]'s [affecting.name].</span>" )
					//H.add_side_effect("Itch")
				else if (W.damage_type == BRUISE)
					user.visible_message("<span class='notice'>\The [user] places a bruise patch over \a [W.desc] on [M]'s [affecting.name].</span>", \
					                              "<span class='notice'>You place a bruise patch over \a [W.desc] on [M]'s [affecting.name].</span>" )
				else
					user.visible_message("<span class='notice'>\The [user] places a bandaid over \a [W.desc] on [M]'s [affecting.name].</span>", \
					                              "<span class='notice'>You place a bandaid over \a [W.desc] on [M]'s [affecting.name].</span>" )
				W.bandage()
				W.heal_damage(heal_brute)
				used++
			affecting.update_damages()
			if(used == amount)
				if(affecting.is_bandaged())
					to_chat(user, "<span class='warning'>\The [src] is used up.</span>")
				else
					to_chat(user, "<span class='warning'>\The [src] is used up, but there are more wounds to treat on \the [affecting.name].</span>")
			use(used)

/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat those nasty burns. Also works as an antiseptic. Smells like aloe and welding fuel. "
	gender = PLURAL
	singular_name = "ointment dose"
	icon_state = "salve"
	heal_burn = 1
	origin_tech = list(TECH_BIO = 1)
	animal_heal = 4
	stack_empty = 1
	splittable = 0

/obj/item/stack/medical/ointment/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return 1

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting) //nullchecked by ..()

		if(affecting.is_salved())
			to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.name] have already been salved.</span>")
			return 1
		else
			user.visible_message("<span class='notice'>\The [user] starts salving wounds on [M]'s [affecting.name].</span>", \
					             "<span class='notice'>You start salving the wounds on [M]'s [affecting.name].</span>" )
			if(!do_mob(user, M, 10))
				to_chat(user, "<span class='notice'>You must stand still to salve wounds.</span>")
				return 1
			user.visible_message("<span class='notice'>[user] salved wounds on [M]'s [affecting.name].</span>", \
			                         "<span class='notice'>You salved wounds on [M]'s [affecting.name].</span>" )
			use(1)
			affecting.salve()
			affecting.disinfect()

/obj/item/stack/medical/advanced/bruise_pack
	name = "somatic gel"
	singular_name = "somatic gel dose"
	desc = "A container of somatic gel, manufactured by Vey-Med. A bendable nozzle makes it easy to apply. Effectively seals up even severe wounds."
	icon_state = "brutegel"
	heal_brute = 3
	origin_tech = list(TECH_BIO = 2)
	animal_heal = 12
	stack_empty = 1
	splittable = 0

/obj/item/stack/medical/advanced/bruise_pack/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return 1

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting) //nullchecked by ..()
		if(affecting.is_bandaged() && affecting.is_disinfected())
			to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.name] have already been treated.</span>")
			return 1
		else
			user.visible_message("<span class='notice'>\The [user] starts treating [M]'s [affecting.name].</span>", \
					             "<span class='notice'>You start treating [M]'s [affecting.name].</span>" )
			var/used = 0
			for (var/datum/wound/W in affecting.wounds)
				if (W.bandaged && W.disinfected)
					continue
				if(used == amount)
					break
				if(!do_mob(user, M, W.damage/5))
					to_chat(user, "<span class='notice'>You must stand still to apply \the [src].</span>")
					break
				if (W.current_stage <= W.max_bleeding_stage)
					user.visible_message("<span class='notice'>\The [user] cleans \a [W.desc] on [M]'s [affecting.name] and seals the edges with somatic gel.</span>", \
					                     "<span class='notice'>You clean and seal \a [W.desc] on [M]'s [affecting.name].</span>" )
				else
					user.visible_message("<span class='notice'>\The [user] smears some somatic gel over \a [W.desc] on [M]'s [affecting.name].</span>", \
					                              "<span class='notice'>You smear some somatic gel over \a [W.desc] on [M]'s [affecting.name].</span>" )
				W.bandage()
				W.disinfect()
				W.heal_damage(heal_brute)
				used++
			affecting.update_damages()
			if(used == amount)
				if(affecting.is_bandaged())
					to_chat(user, "<span class='warning'>\The [src] is used up.</span>")
				else
					to_chat(user, "<span class='warning'>\The [src] is used up, but there are more wounds to treat on \the [affecting.name].</span>")
			use(used)

/obj/item/stack/medical/advanced/ointment
	name = "burn gel"
	singular_name = "burn gel dose"
	desc = "A container of protein-renaturating gel, manufactured by Vey-Med. A bendable nozzle makes it easy to apply. It's said to renaturate proteins, effectively treating severe burns. Doesn't cause skin cancer. Probably."
	icon_state = "burngel"
	heal_burn = 5
	origin_tech = list(TECH_BIO = 3)
	animal_heal = 7
	stack_empty = 1
	splittable = 0

/obj/item/stack/medical/advanced/ointment/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return 1

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting) //nullchecked by ..()

		if(affecting.is_salved())
			to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.name] have already been salved.</span>")
			return 1
		else
			user.visible_message("<span class='notice'>\The [user] starts salving wounds on [M]'s [affecting.name].</span>", \
					             "<span class='notice'>You start salving the wounds on [M]'s [affecting.name].</span>" )
			if(!do_mob(user, M, 10))
				to_chat(user, "<span class='notice'>You must stand still to salve wounds.</span>")
				return 1
			user.visible_message( 	"<span class='notice'>[user] covers wounds on [M]'s [affecting.name] with protein-renaturating gel.</span>", \
									"<span class='notice'>You cover wounds on [M]'s [affecting.name] with protein-renaturating gel.</span>" )
			affecting.heal_damage(0,heal_burn)
			use(1)
			affecting.salve()
			affecting.disinfect()

/obj/item/stack/medical/splint
	name = "medical splints"
	singular_name = "medical splint"
	desc = "Modular splints capable of supporting and immobilizing bones in both limbs and appendages."
	icon_state = "splint"
	amount = 5
	max_amount = 5
	animal_heal = 0
	var/list/splintable_organs = list(BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG, BP_L_HAND, BP_R_HAND, BP_L_FOOT, BP_R_FOOT)	//List of organs you can splint, natch.

/obj/item/stack/medical/splint/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return 1

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting) //nullchecked by ..()
		var/limb = affecting.name
		if(!(affecting.organ_tag in splintable_organs))
			to_chat(user, "<span class='danger'>You can't use \the [src] to apply a splint there!</span>")
			return
		if(affecting.splinted)
			to_chat(user, "<span class='danger'>[M]'s [limb] is already splinted!</span>")
			return
		if (M != user)
			user.visible_message("<span class='danger'>[user] starts to apply \the [src] to [M]'s [limb].</span>", "<span class='danger'>You start to apply \the [src] to [M]'s [limb].</span>", "<span class='danger'>You hear something being wrapped.</span>")
		else
			if(( !user.hand && (affecting.organ_tag in list(BP_R_ARM, BP_R_HAND)) || \
				user.hand && (affecting.organ_tag in list(BP_L_ARM, BP_L_HAND)) ))
				to_chat(user, "<span class='danger'>You can't apply a splint to the arm you're using!</span>")
				return
			user.visible_message("<span class='danger'>[user] starts to apply \the [src] to their [limb].</span>", "<span class='danger'>You start to apply \the [src] to your [limb].</span>", "<span class='danger'>You hear something being wrapped.</span>")
		if(do_after(user, 50, M))
			if(M == user && prob(75))
				user.visible_message("<span class='danger'>\The [user] fumbles [src].</span>", "<span class='danger'>You fumble [src].</span>", "<span class='danger'>You hear something being wrapped.</span>")
				return
			var/obj/item/stack/medical/splint/S = new /obj/item/stack/medical/splint(user,1)
			if(S)
				if(affecting.apply_splint(S))
					S.forceMove(affecting)
					if (M != user)
						user.visible_message("<span class='danger'>\The [user] finishes applying [src] to [M]'s [limb].</span>", "<span class='danger'>You finish applying \the [src] to [M]'s [limb].</span>", "<span class='danger'>You hear something being wrapped.</span>")
					else
						user.visible_message("<span class='danger'>\The [user] successfully applies [src] to their [limb].</span>", "<span class='danger'>You successfully apply \the [src] to your [limb].</span>", "<span class='danger'>You hear something being wrapped.</span>")
					src.use(1)
					return
				S.dropInto(src.loc) //didn't get applied, so just drop it
			user.visible_message("<span class='danger'>\The [user] fails to apply [src].</span>", "<span class='danger'>You fail to apply [src].</span>", "<span class='danger'>You hear something being wrapped.</span>")
		return


/obj/item/stack/medical/splint/ghetto
	name = "makeshift splints"
	singular_name = "makeshift splint"
	desc = "For holding your limbs in place with duct tape and scrap metal."
	icon_state = "tape-splint"
	amount = 1
	splintable_organs = list(BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG)

/obj/item/stack/medical/patches
	name = "pack of patches"
	singular_name = "patch"
	desc = "Name brand NanoTrasen patches. These can save you from various ouchies and boo boos."
	icon_state = "bandaid"
	item_state = "cigpacket"
	origin_tech = list(TECH_BIO = 1)
	amount = 6
	max_amount = 6
	heal_brute = 0
	animal_heal = 3
	stack_full = 1
	stack_empty = 1

/obj/item/stack/medical/patches/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return 1

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting) //nullchecked by ..()

		if(affecting.is_bandaged())
			to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.name] have already been treated.</span>")
			return 1
		else
			user.visible_message("<span class='notice'>\The [user] starts treating [M]'s [affecting.name].</span>", \
					             "<span class='notice'>You start treating [M]'s [affecting.name].</span>" )
			var/used = 0
			for (var/datum/wound/W in affecting.wounds)
				if(W.bandaged)
					continue
				if(used == amount)
					break
				if(!do_mob(user, M, W.damage/5))
					to_chat(user, "<span class='notice'>You must stand still to place a bandaid.</span>")
					break

				user.visible_message("<span class='notice'>\The [user] places a bandaid over \a [W.desc] on [M]'s [affecting.name].</span>", \
									"<span class='notice'>You place a bandaid over \a [W.desc] on [M]'s [affecting.name].</span>" )
				W.bandage()
				used++
			affecting.update_damages()
			if(used == amount)
				if(affecting.is_bandaged())
					to_chat(user, "<span class='warning'>\The [src] is used up.</span>")
				else
					to_chat(user, "<span class='warning'>\The [src] is used up, but there are more wounds to treat on \the [affecting.name].</span>")
			use(used)
