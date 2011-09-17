//some stuff is in the ISaidNo folder - Mini

/obj/item/weapon/reagent_containers/food
	var/heal_amt = 0
	var/nutmod = 1
	proc
		heal(var/mob/M)
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				H.nutrition += 400 * nutmod
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

// Defining the action on "attack" by a /food/snacks/ item type
// note the new 'edible' variable which can be set to 0 for reagents

/obj/item/weapon/reagent_containers/food/snacks
	name = "snack"
	desc = "yummy"
	icon = 'cooking.dmi'
	icon_state = null
	var/amount = 3   //amount of bites
	var/edible = 1   //can you eat this?
	heal_amt = 0     //healing and nutrition value

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
		if(istype(M, /mob/living/carbon/human) && src.edible)
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
					user.u_equip(src)
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
					user.u_equip(src)
					del(src)
				return 1


		return 0

	attackby(obj/item/I as obj, mob/user as mob)
		return
	afterattack(obj/target, mob/user , flag)
		return

// Determining place where to put the products after cutting them with a knife

/obj/item/weapon/reagent_containers/food/proc/foodloc(var/mob/M, var/obj/item/O)
	if(O.loc == M) return M.loc
	else return O.loc

///////////////////////////////////////////////////////
//                                                   //
//                   Raw reagents                    //
//                                                   //
///////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/flour
	name = "flour"
	desc = "Some flour"
	icon_state = "flour"
	edible = 0

/obj/item/weapon/reagent_containers/food/snacks/sugar
	name = "sugar"
	desc = "Some sugar"
	icon_state = "sugar"
	edible = 0

/obj/item/weapon/reagent_containers/food/snacks/dough
	name = "dough"
	desc = "A dough."
	icon_state = "dough"
	edible = 0

/obj/item/weapon/reagent_containers/food/snacks/flatdough
	name = "flat dough"
	desc = "A flattened dough."
	icon_state = "flat dough"
	edible = 0

/obj/item/weapon/reagent_containers/food/snacks/noodles
	name = "noodles"
	desc = "Uncooked spaghetti."
	icon_state = "noodles"
	edible = 0

/obj/item/weapon/reagent_containers/food/snacks/doughslice
	name = "dough slice"
	desc = "Make your magic."
	icon_state = "doughslice"
	edible = 0

/obj/item/weapon/reagent_containers/food/snacks/meat
	name = " meat"
	desc = "A raw meat slab."
	icon_state = "meat"
	edible = 0
	var/subjectname = ""
	var/subjectjob = null

/obj/item/weapon/reagent_containers/food/snacks/rawcutlet
	name = "raw cutlet"
	desc = "A thin piece of meat."
	icon_state = "rawcutlet"
	edible = 0

/obj/item/weapon/reagent_containers/food/snacks/rawmeatball
	name = "raw meatball"
	desc = "A raw meatball."
	icon_state = "rawmeatball"
	edible = 0

/obj/item/weapon/reagent_containers/food/snacks/egg
	name = "egg"
	desc = "Space chickens make them."
	icon_state = "egg"
	edible = 0

///////////////////////////////////////////////////////
//                                                   //
//                       Plants                      //
//                                                   //
///////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/rawsticks
	name = "raw potato sticks"
	desc = "Maybe you should cook it first?"
	icon_state = "rawsticks"
	amount = 1
	heal_amt = 1

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

///////////////////////////////////////////////////////
//                                                   //
//                       Sauces                      //
//                                                   //
///////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/ketchup
	name = "ketchup"
	desc = "Goes well with meat."
	icon_state = "ketchup"
	amount = 1
	heal_amt = 1

///////////////////////////////////////////////////////
//                                                   //
//                      Bakery                       //
//                                                   //
///////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candycane
	name = "candy cane"
	desc = "Sweet and sticky."
	icon_state = "candycane"
	amount = 1
	heal_amt = 3

/obj/item/weapon/reagent_containers/food/snacks/sweetapple
	name = "sweet apple"
	desc = "Warm, sweet and healthy!"
	icon_state = "sweetapple"
	amount = 2
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/pattyapple
	name = "apple patty"
	desc = "Like grandma's."
	icon_state = "pattyapple"
	amount = 3
	heal_amt = 3

/obj/item/weapon/reagent_containers/food/snacks/bun
	name = "bun"
	desc = "A base for any self-respecting burger."
	icon_state = "bun"
	amount = 2
	heal_amt = 1

/obj/item/weapon/reagent_containers/food/snacks/flatbread
	name = "flatbread"
	desc = "Bland but filling."
	icon_state = "flatbread"
	amount = 2
	heal_amt = 1

/obj/item/weapon/reagent_containers/food/snacks/pie
	name = "custard pie"
	desc = "It smells delicious. You just want to plant your face in it."
	icon_state = "pie"
	amount = 4

/obj/item/weapon/reagent_containers/food/snacks/waffles
	name = "waffles"
	desc = "Sweet waffles."
	icon_state = "waffles"
	amount = 3
	heal_amt = 2

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
		if(istype(M, /mob/living/carbon/human) && M.job in list("Security Officer", "Head of Security", "Forensic Technician"))
			src.heal_amt *= 2
			..()
			src.heal_amt /= 2

///////////////////////////////////////////////////////
//                                                   //
//                    Cooked food                    //
//                                                   //
///////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/frenchfries
	name = "french fries"
	desc = "Good as always."
	icon_state = "frenchfries"
	amount = 2
	heal_amt = 3

/obj/item/weapon/reagent_containers/food/snacks/bakedpotato
	name = "baked potato"
	desc = "It smells good."
	icon_state = "bakedpotato"
	amount = 3
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/sbakedpotato
	name = "sauced potatoes"
	desc = "It smells and tastes great!"
	icon_state = "sbakedpotato"
	amount = 4
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/spaghetti
	name = "spaghetti"
	desc = "Long and tasteless - 'Noodles'."
	icon_state = "spaghetti"
	amount = 4
	heal_amt = 1

/obj/item/weapon/reagent_containers/food/snacks/sspaghetti
	name = "sauced spaghetti"
	desc = "Long and tasty - 'Tomato Noodles'."
	icon_state = "sspaghetti"
	amount = 5
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/meatspaghetti
	name = "spaghetti with meatballs"
	desc = "A standard dinner - 'Spaghetti Monster'."
	icon_state = "meatspaghetti"
	amount = 5
	heal_amt = 3

/obj/item/weapon/reagent_containers/food/snacks/smeatspaghetti
	name = "sauced spaghetti with meatballs"
	desc = "A tasty dinner - 'Spaghetti Terror'."
	icon_state = "smeatspaghetti"
	amount = 6
	heal_amt = 4

/obj/item/weapon/reagent_containers/food/snacks/boiledegg
	name = "boiled egg"
	desc = "Boiled in its own shell - 'Humpty Dumpty'."
	icon_state = "boiled egg"
	amount = 2
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/omelette
	name = "omelette"
	desc = "A filling breakfast dish for every scientist - 'Eggheads'."
	icon_state = "omelette"
	amount = 3
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/somelette
	name = "sauced omelette"
	desc = "A saucy dish - 'Bloody Alien'."
	icon_state = "somelette"
	amount = 4
	heal_amt = 3

/obj/item/weapon/reagent_containers/food/snacks/steak
	name = "steak"
	desc = "A juicy meat steak."
	icon_state = "steak"
	amount = 3
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/ssteak
	name = "sauced steak"
	desc = "A sauced meat steak."
	icon_state = "ssteak"
	amount = 4
	heal_amt = 3

/obj/item/weapon/reagent_containers/food/snacks/cutlet
	name = "cutlet"
	desc = "A tasty meat slice - 'Bacon'."
	icon_state = "cutlet"
	amount = 1
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/sausage
	name = "sausage"
	desc = "A sausage."
	icon_state = "sausage"
	amount = 2
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/meatball
	name = "meatball"
	desc = "A meatball."
	icon_state = "meatball"
	amount = 1
	heal_amt = 2

///////////////////////////////////////////////////////
//                                                   //
//                    Burgers                        //
//                                                   //
///////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/hotdog
	name = "hotdog"
	desc = "Unrelated to dogs."
	icon_state = "hotdog"
	amount = 3
	heal_amt = 3

/obj/item/weapon/reagent_containers/food/snacks/shotdog
	name = "sauced hotdog"
	desc = "Unrelated to dogs - 'Royal Hotdog'."
	icon_state = "shotdog"
	amount = 4
	heal_amt = 4

/obj/item/weapon/reagent_containers/food/snacks/burger
	name = "burger"
	desc = "A fast way to become fat."
	icon_state = "burger"
	amount = 4
	heal_amt = 3

/obj/item/weapon/reagent_containers/food/snacks/sburger
	name = "sauced burger"
	desc = "A fast way to become fat - 'Space Burger'."
	icon_state = "sburger"
	amount = 5
	heal_amt = 4

/obj/item/weapon/reagent_containers/food/snacks/hamburger
	name = "hamburger"
	desc = "A fast way to become fat."
	icon_state = "hamburger"
	amount = 4
	heal_amt = 3

/obj/item/weapon/reagent_containers/food/snacks/shamburger
	name = "sauced hamburger"
	desc = "A fast way to become fat - 'Star Hamburger'."
	icon_state = "shamburger"
	amount = 5
	heal_amt = 4

/obj/item/weapon/reagent_containers/food/snacks/cheeseburger
	name = "cheeseburger"
	desc = "The cheese adds a good flavor."
	icon_state = "cheeseburger"
	amount = 5
	heal_amt = 4

/obj/item/weapon/reagent_containers/food/snacks/scheeseburger
	name = "saused cheeseburger"
	desc = "The cheese adds a good flavor - 'Space Cheeseburger'."
	icon_state = "scheeseburger"
	amount = 6
	heal_amt = 4

/obj/item/weapon/reagent_containers/food/snacks/taco
	name = "taco"
	desc = "Take a bite!"
	icon_state = "taco"
	amount = 3
	heal_amt = 4

///////////////////////////////////////////////////////
//                                                   //
//                     Pies                          //
//                                                   //
///////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/pieapple
	name = "apple pie"
	desc = "Om nom nom."
	icon_state = "pieapple"
	amount = 4
	heal_amt = 3

/obj/item/weapon/reagent_containers/food/snacks/piepotato
	name = "potato pie"
	desc = "Om nom nom."
	icon_state = "pieapple"
	amount = 4
	heal_amt = 3

/obj/item/weapon/reagent_containers/food/snacks/pieshroom
	name = "mushroom pie"
	desc = "Eat fresh."
	icon_state = "pieshroom"
	amount = 4
	heal_amt = 4

/obj/item/weapon/reagent_containers/food/snacks/piemeat
	name = "meat pie"
	desc = "Fat and filling."
	icon_state = "piemeat"
	amount = 4
	heal_amt = 4

///////////////////////////////////////////////////////
//                                                   //
//                     Pizza                         //
//                                                   //
///////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/pizza
	name = "Pizza Margherita"
	desc = "A pizza with cheese and sauce."
	icon_state = "pizza1"
	amount = 4
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice
	name = "Pizza Margherita slice"
	desc = "A slice of pizza with cheese and sauce."
	icon_state = "pizzaslice1"
	amount = 1
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/pizzapotato
	name = "Pizza Potati"
	desc = "A pizza with cheese, potatoes and sauce."
	icon_state = "pizza1"
	amount = 4
	heal_amt = 3

/obj/item/weapon/reagent_containers/food/snacks/pizzapotatoslice
	name = "Pizza Potati slice"
	desc = "A slice of pizza with cheese, potato and sauce."
	icon_state = "pizzaslice1"
	amount = 1
	heal_amt = 3

/obj/item/weapon/reagent_containers/food/snacks/pizzashroom
	name = "Pizza Funghi"
	desc = "A pizza with cheese, sauce and mushrooms."
	icon_state = "pizza2"
	amount = 4
	heal_amt = 3

/obj/item/weapon/reagent_containers/food/snacks/pizzashroomslice
	name = "Pizza Funghi slice"
	desc = "A slice of pizza with cheese, sauce and mushrooms."
	icon_state = "pizzaslice2"
	amount = 1
	heal_amt = 3

/obj/item/weapon/reagent_containers/food/snacks/pizzameat
	name = "Pizza al Prosciutto"
	desc = "A pizza with cheese, sauce and sliced meat."
	icon_state = "pizza3"
	amount = 4
	heal_amt = 3

/obj/item/weapon/reagent_containers/food/snacks/pizzameatslice
	name = "Pizza al Prosciutto slice"
	desc = "A slice of pizza with cheese, sauce and sliced meat."
	icon_state = "pizzaslice3"
	amount = 1
	heal_amt = 3

/obj/item/weapon/reagent_containers/food/snacks/pizzameatshroom
	name = "Pizza al Prosciutto e Funghi"
	desc = "A pizza with cheese, sauce, sliced meat and mushrooms."
	icon_state = "pizza4"
	amount = 4
	heal_amt = 4

/obj/item/weapon/reagent_containers/food/snacks/pizzameatshroomslice
	name = "Pizza al Prosciutto e Funghi slice"
	desc = "A slice of pizza with cheese, sauce, mushrooms and sliced meat."
	icon_state = "pizzaslice4"
	amount = 1
	heal_amt = 4

/obj/item/weapon/reagent_containers/food/snacks/pizzasalami
	name = "Pizza Pepperoni"
	desc = "A pizza with cheese, sauce and salami."
	icon_state = "pizza3"
	amount = 4
	heal_amt = 3

/obj/item/weapon/reagent_containers/food/snacks/pizzasalamislice
	name = "Pizza Pepperoni slice"
	desc = "A slice of pizza with cheese, sauce and salami."
	icon_state = "pizzaslice3"
	amount = 1
	heal_amt = 3

/obj/item/weapon/reagent_containers/food/snacks/pizzasalamishroom
	name = "Pizza Alla Diavola"
	desc = "A spicy pizza with mushrooms, cheese, sauce and salami."
	icon_state = "pizza4"
	amount = 4
	heal_amt = 4

/obj/item/weapon/reagent_containers/food/snacks/pizzasalamishroomslice
	name = "Pizza Alla Diavola slice"
	desc = "A slice of a spicy pizza with mushrooms, cheese, sauce and salami."
	icon_state = "pizzaslice4"
	amount = 1
	heal_amt = 4

// Cutting pizza

/obj/item/weapon/reagent_containers/food/snacks/pizza/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/kitchen/utensil/knife))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/pizzaslice(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/pizzaslice(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/pizzaslice(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/pizzaslice(spawnloc)
		user << "You cut the pizza."
		amount--
		del(src)

/obj/item/weapon/reagent_containers/food/snacks/pizzapotato/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/kitchen/utensil/knife))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/pizzapotatoslice(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/pizzapotatoslice(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/pizzapotatoslice(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/pizzapotatoslice(spawnloc)
		user << "You cut the pizza."
		amount--
		del(src)

/obj/item/weapon/reagent_containers/food/snacks/pizzashroom/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/kitchen/utensil/knife))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/pizzashroomslice(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/pizzashroomslice(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/pizzashroomslice(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/pizzashroomslice(spawnloc)
		user << "You cut the pizza."
		amount--
		del(src)

/obj/item/weapon/reagent_containers/food/snacks/pizzameat/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/kitchen/utensil/knife))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/pizzameatslice(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/pizzameatslice(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/pizzameatslice(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/pizzameatslice(spawnloc)
		user << "You cut the pizza."
		amount--
		del(src)

/obj/item/weapon/reagent_containers/food/snacks/pizzameatshroom/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/kitchen/utensil/knife))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/pizzameatshroomslice(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/pizzameatshroomslice(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/pizzameatshroomslice(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/pizzameatshroomslice(spawnloc)
		user << "You cut the pizza."
		amount--
		del(src)

/obj/item/weapon/reagent_containers/food/snacks/pizzasalami/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/kitchen/utensil/knife))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/pizzasalamislice(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/pizzasalamislice(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/pizzasalamislice(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/pizzasalamislice(spawnloc)
		user << "You cut the pizza."
		amount--
		del(src)

/obj/item/weapon/reagent_containers/food/snacks/pizzasalamishroom/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/kitchen/utensil/knife))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/pizzasalamishroomslice(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/pizzasalamishroomslice(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/pizzasalamishroomslice(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/pizzasalamishroomslice(spawnloc)
		user << "You cut the pizza."
		amount--
		del(src)

///////////////////////////////////////////////////////
//           Cutting other food items .              //
///////////////////////////////////////////////////////

// Flat dough into dough slices (x3)
/obj/item/weapon/reagent_containers/food/snacks/flatdough/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/kitchen/utensil/knife))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/doughslice(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/doughslice(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/doughslice(spawnloc)
		user << "You cut the flat dough into slices."
		del(src)

// Potato in potato sticks
/obj/item/weapon/reagent_containers/food/snacks/potato/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/kitchen/utensil/knife))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/rawsticks(spawnloc)
		user << "You cut the potato."
		del(src)


// Meat into raw cutlets (x3)
/obj/item/weapon/reagent_containers/food/snacks/meat/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/kitchen/utensil/knife))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/rawcutlet(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/rawcutlet(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/rawcutlet(spawnloc)
		user << "You cut the meat into slices."
		del(src)

// Steak into cutlets (x3)
/obj/item/weapon/reagent_containers/food/snacks/steak/attackby(obj/item/weapon/kitchen/utensil/knife/W as obj, mob/user as mob)
	if(istype(W))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/cutlet(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/cutlet(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/cutlet(spawnloc)
		user << "You cut the steak into slices."
		del(src)
		return
	..()

// Sauced steak into cutlets (x3)
/obj/item/weapon/reagent_containers/food/snacks/ssteak/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/kitchen/utensil/knife))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/cutlet(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/cutlet(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/cutlet(spawnloc)
		user << "You cut the steak into slices."
		del(src)

///////////////////////////////////////////////////////
//                                                   //
//                  Combining foods                  //
//                                                   //
///////////////////////////////////////////////////////

// Bread slice + butter = bread and butter
/obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/bread/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/butter))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/butterbread(spawnloc)
		user << "You place butter on the bread."
		del(W)
		del(src)

/obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/butterbread/attackby(obj/item/weapon/W as obj, mob/user as mob)
	var/turf/spawnloc = foodloc(user, src)

	// Bread and butter + cheese slice = cheese sandwich
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/cheese))
		new /obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/chsandwich(spawnloc)
		user << "You make a cheese sandwich."
		del(W)
		del(src)

	// Bread and butter + cutlet = meat sandwich
	else if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/cutlet))
		new /obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/msandwich(spawnloc)
		user << "You make a meat sandwich."
		del(W)
		del(src)

	else if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/salami))
		new /obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/salsandwich(spawnloc)
		user << "You make a salami sandwich."
		del(W)
		del(src)


// Cheese sandwich + meat sandwich = sammich
/obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/chsandwich/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/msandwich))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/sammich(spawnloc)
		user << "You make a sammich,"
		del(W)
		del(src)

// Meat sandwich + cheese sandwich = sammich
/obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/msandwich/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/chsandwich))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/sammich(spawnloc)
		user << "You make a sammich,"
		del(W)
		del(src)

// Flour + egg = dough
/obj/item/weapon/reagent_containers/food/snacks/flour/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/egg))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/dough(spawnloc)
		user << "You make a dough."
		del(W)
		del(src)

// Dough + rolling pin = flat dough
/obj/item/weapon/reagent_containers/food/snacks/dough/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/kitchen/rollingpin))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/flatdough(spawnloc)
		user << "You flatten the dough."
		del(src)


/obj/item/weapon/reagent_containers/food/snacks/bun/attackby(obj/item/weapon/W as obj, mob/user as mob)
	// Bun + meatball = burger
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/meatball))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/burger(spawnloc)
		user << "You make a burger."
		del(W)
		del(src)

	// Bun + cutlet = hamburger
	else if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/cutlet))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/hamburger(spawnloc)
		user << "You make a hamburger."
		del(W)
		del(src)

	// Bun + sausage = hotdog
	else if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/sausage))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/hotdog(spawnloc)
		user << "You make a hotdog."
		del(W)
		del(src)

// Burger + cheese slice = cheeseburger
/obj/item/weapon/reagent_containers/food/snacks/burger/attackby(obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/cheese/W as obj, mob/user as mob)
	if(istype(W))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/cheeseburger(spawnloc)
		user << "You make a cheeseburger."
		del(W)
		del(src)
		return
	..()

// Hamburger + cheese slice = cheeseburger
/obj/item/weapon/reagent_containers/food/snacks/hamburger/attackby(obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/cheese/W as obj, mob/user as mob)
	if(istype(W))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/cheeseburger(spawnloc)
		user << "You make a cheeseburger."
		del(W)
		del(src)
		return
	..()

// Sauced burger + cheese slice = sauced cheeseburger
/obj/item/weapon/reagent_containers/food/snacks/sburger/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/cheese))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/scheeseburger(spawnloc)
		user << "You make a sauced cheeseburger."
		del(W)
		del(src)

// Sauced hamburger + cheese slice = sauced cheeseburger
/obj/item/weapon/reagent_containers/food/snacks/shamburger/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/cheese))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/scheeseburger(spawnloc)
		user << "You make a sauced cheeseburger."
		del(W)
		del(src)

// Spaghetti + meatball = spaghetti with meatballs
/obj/item/weapon/reagent_containers/food/snacks/spaghetti/attackby(obj/item/weapon/reagent_containers/food/snacks/meatball/W as obj, mob/user as mob)
	if(istype(W))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/meatspaghetti(spawnloc)
		user << "You add meatballs to spaghetti."
		del(W)
		del(src)
		return
	..()

// Sauced spaghetti + meatball = sauced spaghetti with meatballs
/obj/item/weapon/reagent_containers/food/snacks/sspaghetti/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/meatball))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/smeatspaghetti(spawnloc)
		user << "You add meatballs to sauced spaghetti."
		del(W)
		del(src)

///////////////////////////////////////////////////////
//                                                   //
//                     Adding sauce.                 //
//                                                   //
///////////////////////////////////////////////////////


// Steak + ketchup
/obj/item/weapon/reagent_containers/food/snacks/steak/attackby(obj/item/weapon/reagent_containers/food/snacks/ketchup/W as obj, mob/user as mob)
	if(istype(W))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/ssteak(spawnloc)
		user << "You put ketchup on the steak."
		del(src)
		return
	..()

// Baked potato + ketchup
/obj/item/weapon/reagent_containers/food/snacks/bakedpotato/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/ketchup))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/sbakedpotato(spawnloc)
		user << "You add ketchup to the baked potato."
		del(src)

// Spaghetti + ketchup
/obj/item/weapon/reagent_containers/food/snacks/spaghetti/attackby(obj/item/weapon/reagent_containers/food/snacks/ketchup/W as obj, mob/user as mob)
	if(istype(W))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/sspaghetti(spawnloc)
		user << "You put ketchup in spaghetti."
		del(src)
		return
	..()

// Meatballs & spaghetti + ketchup
/obj/item/weapon/reagent_containers/food/snacks/meatspaghetti/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/ketchup))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/smeatspaghetti(spawnloc)
		user << "You put ketchup in meat spaghetti."
		del(src)

// Burger + ketchup
/obj/item/weapon/reagent_containers/food/snacks/burger/attackby(obj/item/weapon/reagent_containers/food/snacks/ketchup/W as obj, mob/user as mob)
	if(istype(W))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/sburger(spawnloc)
		user << "You add ketchup to the burger."
		del(src)
		return
	..()

// Hamburger + ketchup
/obj/item/weapon/reagent_containers/food/snacks/hamburger/attackby(obj/item/weapon/reagent_containers/food/snacks/ketchup/W as obj, mob/user as mob)
	if(istype(W))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/shamburger(spawnloc)
		user << "You add ketchup to the hamburger."
		del(src)
		return
	..()

// Cheeseburger + ketchup
/obj/item/weapon/reagent_containers/food/snacks/cheeseburger/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/ketchup))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/scheeseburger(spawnloc)
		user << "You add ketchup to the cheeseburger."
		del(src)

// Hotdog + ketchup
/obj/item/weapon/reagent_containers/food/snacks/hotdog/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/ketchup))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/shotdog(spawnloc)
		user << "You add ketchup to the hotdog."
		del(src)

// Burger + omelette
/obj/item/weapon/reagent_containers/food/snacks/omelette/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/ketchup))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/somelette(spawnloc)
		user << "You add ketchup to the omelette."
		del(src)

///////////////////////////////////////////////////////
//                                                   //
//           Bread and sandwich system.              //
//           Stuff goes on top of bread slices!      //
//                                                   //
///////////////////////////////////////////////////////

// *** At first, containers which require a knife to get something from then ***

// the loaf
/obj/item/weapon/reagent_containers/food/snacks/breadsys/
	icon_state = null
	amount = 1


// the loaf
/obj/item/weapon/reagent_containers/food/snacks/breadsys/loaf
	name = "loaf of bread"
	desc = "A fine loaf of bread"
	icon_state = "loaf4"
	heal_amt = 2
	amount = 6

// the butterpack
/obj/item/weapon/reagent_containers/food/snacks/breadsys/butterpack
	name = "Butter pack"
	desc = "A big pack of goodness."
	icon_state = "butterpack"
	edible = 0
	amount = 5

// the stick of salami
/obj/item/weapon/reagent_containers/food/snacks/breadsys/salamistick
	name = "salami stick"
	desc = "Don't choke on this, find a knife."
	icon = 'cooking.dmi'
	icon_state = "salamistick3"
	edible = 0
	amount = 5

// the head of cheese
/obj/item/weapon/reagent_containers/food/snacks/breadsys/bigcheese
	name = "cut of cheese"
	desc = "Cut it with a knife."
	icon = 'cooking.dmi'
	icon_state = "bigcheese"
	heal_amt = 3
	amount = 1

// *** Now icons for the stuff which goes on top of the bread slice ***

/obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop
	icon = 'cooking.dmi'
	var/stateontop = "salami3" //state when ontop a sandvich

// a slice of bread loaf
/obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/bread
	name = "bread slice"
	desc = "A well-made bread slice."
	icon_state = "bread3"
	stateontop = "bread1"
	heal_amt = 1

// a slice of salami
/obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/salami
	name = "salami"
	desc = "A preserved meat."
	icon_state = "salami"
	stateontop = "salami3"
	heal_amt = 1

// a slice of cheese
/obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/cheese
	name = "cheese slice"
	desc = "Small enough to fit on a bread slice."
	icon_state = "cheese"
	stateontop = "cheese3"
	heal_amt = 1

// a slice of butter
/obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/butter
	name = "butter"
	desc = "You need a butter to make sandwiches, right?"
	icon_state = "butter"
	stateontop = "butter3"
	heal_amt = 0

// bread and butter
/obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/butterbread
	name = "bread and butter"
	desc = "A base for a sandwich."
	icon_state = "breadbutter"
	heal_amt = 1


// a cheese sandwich
/obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/chsandwich
	name = "cheese sandwich"
	desc = "Cheese and butter. Nice."
	icon_state = "chsandwich"
	amount = 2
	heal_amt = 2

// a meat sandwich
/obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/msandwich
	name = "meat sandwich"
	desc = "Fat but filling."
	icon_state = "msandwich"
	amount = 2
	heal_amt = 2

// a salami sandwich
/obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/salsandwich
	name = "salami sandwich"
	desc = "This is a salami sandwich.. Really, that's all... No strange spices mixed in."
	icon_state = "salsandwich"
	amount = 2
	heal_amt = 2

// a sammich
/obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/sammich
	name = "sammiich"
	desc = "A great sandwich!"
	icon_state = "sammich"
	amount = 4
	heal_amt = 4

// *** Cutting sandwich-system containers into pieces ***

//	 Loaf code
/obj/item/weapon/reagent_containers/food/snacks/breadsys/loaf/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/kitchen/utensil/knife))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/bread(spawnloc)
		user << "You slice a piece of bread"
		amount--
		if(amount <= 5)
			icon_state = "loaf3"
		if(amount <= 4)
			icon_state = "loaf2"
		if(amount <= 2)
			icon_state = "loaf1"
		if(amount <= 1)
			new /obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/bread(spawnloc)
			del(src)

//	 Cheese code
/obj/item/weapon/reagent_containers/food/snacks/breadsys/bigcheese/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/kitchen/utensil/knife))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/cheese(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/cheese(spawnloc)
		new /obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/cheese(spawnloc)
		user << "You slice the cheese"
		amount--
		del(src)

//	 Salami code
/obj/item/weapon/reagent_containers/food/snacks/breadsys/salamistick/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/kitchen/utensil/knife))
		var/turf/spawnloc = foodloc(user, src)
		new /obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/salami(spawnloc)
		user << "You slice a piece of salami"
		amount--
		if(amount <= 4)
			icon_state = "salamistick2"
		if(amount <= 3)
			icon_state = "salamistick1"
		if(amount <= 2)
			icon_state = "salamistick0"
		if(amount <= 1)
			new /obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/salami(spawnloc)
			del(src)


//	 Butterpack code
/obj/item/weapon/reagent_containers/food/snacks/breadsys/butterpack/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/kitchen/utensil/knife))
		var/turf/spawnloc = foodloc(user, src)
		if(amount >= 1)
			new /obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/butter(spawnloc)
			user << "You cut some butter"
			amount--
		if(amount < 1)
			del(src)

// *** Sandwich assembling code. Watch the overloading on bread/attackby ***
/*
/obj/item/weapon/reagent_containers/food/snacks/breadsys/bread/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop))
		var/state = W:stateontop
		if(!state)
			return
		if(src.name != "sandwich")
			src.name = "sandwich"
		overlays += image(W.icon,icon_state = state)
		user.drop_item(W)
		W.loc = src
		user << "You put a [W] ontop of the [src]"
		src.heal_amt++
	else if(W.type == /obj/item/weapon/reagent_containers/food/snacks/breadsys/bread/)
		user.drop_item(W)
		W.loc = src
		if(src.name != "sandwich")
			src.name = "sandwich"
		overlays += image(W.icon,icon_state = W.icon_state)
		user << "You put [W] ontop of the [src]"
		src.heal_amt++
	updateicon()


/obj/item/weapon/reagent_containers/food/snacks/breadsys/bread/proc/updateicon()
	src.overlays = null
	var/num = amount
	for(var/obj/item/weapon/reagent_containers/food/snacks/breadsys/ontop/X in src)
		var/iconx = "[X.stateontop][num]"
		overlays += image(X.icon,iconx)
*/
///////////////////////////////////////////////////////
//        End of sandwich-related stuff              //
///////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candy
	name = "candy"
	desc = "Man, that looks good. I bet it's got nougat."
	icon_state = "candy"
	heal_amt = 1
	nutmod = 0.1

/obj/item/weapon/reagent_containers/food/snacks/candy/MouseDrop(mob/user as mob)
	return src.attack(user, user)

/obj/item/weapon/reagent_containers/food/snacks/chips
	name = "chips"
	desc = "Commander Riker's What-The-Crisps"
	icon_state = "chips"
	heal_amt = 2
	nutmod = 0.1

/obj/item/weapon/reagent_containers/food/snacks/chips/MouseDrop(mob/user as mob)
	return src.attack(user, user)

/obj/item/weapon/reagent_containers/food/snacks/assburger
	name = "assburger"
	desc = "This burger gives off an air of awkwardness."
	icon_state = "burger"
	amount = 5
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/brainburger
	name = "brainburger"
	desc = "A strange looking burger. It looks almost sentient."
	icon_state = "burger"
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
	icon_state = "burger"
	amount = 5
	heal_amt = 2
	heal(var/mob/M)

/obj/item/weapon/reagent_containers/food/snacks/monkeyburger
	name = "monkeyburger"
	desc = "The cornerstone of every nutritious breakfast."
	icon_state = "burger"
	amount = 5
	heal_amt = 2

/obj/item/weapon/reagent_containers/food/snacks/roburger
	name = "roburger"
	desc = "The lettuce is the only organic component. Beep."
	icon_state = "burger"
	New()
		var/datum/reagents/R = new/datum/reagents(5)
		reagents = R
		R.my_atom = src
		R.add_reagent("nanites", 5)

/obj/item/weapon/reagent_containers/food/snacks/monkeymeat
	name = "monkey meat"
	desc = "A slab of meat"
	icon_state = "meat"
	amount = 1

/obj/item/weapon/reagent_containers/food/snacks/waffles/MouseDrop(mob/user as mob)
	return src.attack(user, user)

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
		var/turf/spawnloc = foodloc(user, src)
		P.loc = spawnloc
		del src
	return ..()