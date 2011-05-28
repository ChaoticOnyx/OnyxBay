/obj/item/weapon/reagent_containers/food
	var/heal_amt = 0
	proc
		heal(var/mob/M)
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				for(var/A in H.organs)
					var/datum/organ/external/affecting = null
					if(!H.organs[A])	continue
					affecting = H.organs[A]
					if(!istype(affecting, /datum/organ/external))	continue
					if(affecting.heal_damage(src.heal_amt, src.heal_amt))
						H.UpdateDamageIcon()
					else
						H.UpdateDamage()
			else
				M.bruteloss = max(0, M.bruteloss - src.heal_amt)
				M.fireloss = max(0, M.fireloss - src.heal_amt)
			M.updatehealth()

/obj/item/weapon/reagent_containers/food/snacks
	name = "snack"
	desc = "yummy"
	icon = 'food.dmi'
	icon_state = null
	var/amount = 3
	heal_amt = 1

	New()
		var/datum/reagents/R = new/datum/reagents(10)
		reagents = R
		R.my_atom = src

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		return
	attack_self(mob/user as mob)
		return
	attack(mob/M as mob, mob/user as mob, def_zone)
		if(!in_range(src, user))
			return
		if(!src.amount)
			user << "\red None of [src] left, oh no!"
			del(src)
			return 0
		if(istype(M, /mob/living/carbon/human))
			if(M == user)
				M << "\blue You take a bite of [src]."
				if(reagents.total_volume)
					reagents.reaction(M, INGEST)
					spawn(5)
						reagents.trans_to(M, reagents.total_volume)
				src.amount--
				M.nutrition += src.heal_amt * 10
				M.poo += 0.1
				src.heal(M)
				playsound(M.loc,'eatfood.ogg', rand(10,50), 1)
				if(!src.amount)
					user << "\red You finish eating [src]."
					del(src)
				return 1
			else
				for(var/mob/O in viewers(world.view, user))
					O.show_message("\red [user] attempts to feed [M] [src].", 1)
				if(!do_mob(user, M)) return
				for(var/mob/O in viewers(world.view, user))
					O.show_message("\red [user] feeds [M] [src].", 1)

				if(reagents.total_volume)
					reagents.reaction(M, INGEST)
					spawn(5)
						reagents.trans_to(M, reagents.total_volume)
				src.amount--
				M.nutrition += src.heal_amt * 10
				M.poo += 0.1
				src.heal(M)
				playsound(M.loc, 'eatfood.ogg', rand(10,50), 1)
				if(!src.amount)
					user << "\red [M] finishes eating [src]."
					del(src)
				return 1


		return 0

	attackby(obj/item/I as obj, mob/user as mob)
		return
	afterattack(obj/target, mob/user , flag)
		return


/obj/item/weapon/reagent_containers/food/snacks/candy
	name = "candy"
	desc = "Man, that looks good. I bet it's got nougat."
	icon_state = "candy"
	heal_amt = 1

/obj/item/weapon/reagent_containers/food/snacks/candy/MouseDrop(mob/user as mob)
	return src.attack(user, user)

/obj/item/weapon/reagent_containers/food/snacks/chips
	name = "chips"
	desc = "Commander Riker's What-The-Crisps"
	icon_state = "chips"
	heal_amt = 1

/obj/item/weapon/reagent_containers/food/snacks/chips/MouseDrop(mob/user as mob)
	return src.attack(user, user)

/obj/item/weapon/reagent_containers/food/snacks/donut
	name = "donut"
	desc = "Goes great with Robust Coffee."
	icon_state = "donut1"
	heal_amt = 1
	New()
		..()
		if(rand(1,3) == 1)
			src.icon_state = "donut2"
			src.name = "frosted donut"
			src.heal_amt = 2
	heal(var/mob/M)
		if(istype(M, /mob/living/carbon/human) && M.job in list("Security Officer", "Head of Security", "Detective"))
			src.heal_amt *= 2
			..()
			src.heal_amt /= 2

/obj/item/weapon/reagent_containers/food/snacks/egg
	name = "egg"
	desc = "An egg!"
	icon_state = "egg"
	amount = 1
	heal_amt = 1

/obj/item/weapon/reagent_containers/food/snacks/flour
	name = "flour"
	desc = "Some flour"
	icon_state = "flour"
	amount = 1

/obj/item/weapon/reagent_containers/food/snacks/humanmeat
	name = "-meat"
	desc = "A slab of meat"
	icon_state = "meat"
	var/subjectname = ""
	var/subjectjob = null
	amount = 1

/obj/item/weapon/reagent_containers/food/snacks/assburger
	name = "assburger"
	desc = "This burger gives off an air of awkwardness."
	icon_state = "assburger"
	amount = 5
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/brainburger
	name = "brainburger"
	desc = "A strange looking burger. It looks almost sentient."
	icon_state = "brainburger"
	amount = 5
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/meatball
	name = "meatball"
	desc = "A great meal all round."
	icon_state = "meatball"
	amount = 1
	heal_amt = 2
	heal(var/mob/M)
		..()

/obj/item/weapon/reagent_containers/food/snacks/donkpocket
	name = "donk-pocket"
	desc = "The food of choice for the seasoned traitor."
	icon_state = "donkpocket"
	heal_amt = 1
	amount = 1
	var/warm = 0
	heal(var/mob/M)
		if(src.warm && M.reagents)
			M.reagents.add_reagent("tricordrazine",15)
		else
			M << "\red It's just not good enough cold.."
		..()

	proc/cooltime()
		if (src.warm)
			spawn( 4200 )
				src.warm = 0
				src.name = "donk-pocket"
		return

/obj/item/weapon/reagent_containers/food/snacks/humanburger
	name = "-burger"
	var/hname = ""
	var/job = null
	desc = "A bloody burger."
	icon_state = "hburger"
	amount = 5
	heal_amt = 2
	heal(var/mob/M)

/obj/item/weapon/reagent_containers/food/snacks/monkeyburger
	name = "monkeyburger"
	desc = "The cornerstone of every nutritious breakfast."
	icon_state = "mburger"
	amount = 5
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/roburger
	name = "roburger"
	desc = "The lettuce is the only organic component. Beep."
	icon_state = "roburger"
	New()
		var/datum/reagents/R = new/datum/reagents(5)
		reagents = R
		R.my_atom = src
		R.add_reagent("nanites", 5)

/obj/item/weapon/reagent_containers/food/snacks/monkeymeat
	name = "meat"
	desc = "A slab of meat"
	icon_state = "meat"
	amount = 1

/obj/item/weapon/reagent_containers/food/snacks/pie
	name = "custard pie"
	desc = "It smells delicious. You just want to plant your face in it."
	icon_state = "pie"
	amount = 3

/obj/item/weapon/reagent_containers/food/snacks/waffles
	name = "waffles"
	desc = "Mmm, waffles"
	icon_state = "waffles"
	amount = 5
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/waffles/MouseDrop(mob/user as mob)
	return src.attack(user, user)

/obj/item/weapon/reagent_containers/food/snacks/plump
	name = "Plump Helmets"
	desc = "Mushrooms selectively bred to be alcoholic."
	icon_state = "plump"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("dwine", 10)

/obj/item/weapon/reagent_containers/food/snacks/dwbiscuits
	name = "Dwarven Wine Biscuits"
	desc = "WARNING: HIGH ALCOHOL CONTENT."
	icon_state = "dwbiscuits"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		R.add_reagent("dwine", 100)

/obj/item/weapon/reagent_containers/food/snacks/plump/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/kitchen/utensil/knife))
		var/obj/item/clothing/head/helmet/plump/P = new/obj/item/clothing/head/helmet/plump
		P.loc = src.loc
		del src
	return ..()