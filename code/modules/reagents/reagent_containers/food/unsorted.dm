
//////////////////////////////////////////////////
//////////////////////////////////////////// Formerly known as Snacks
//////////////////////////////////////////////////
//Items in this category are food items that people actually eat. The key points are that they are created
//	already filled with reagents and are destroyed when empty. Additionally, they make a "munching" noise when eaten.

//Notes by Darem: Food in the "snacks" subtype can hold a maximum of 50 units Generally speaking, you don't want to go over 40
//	total for the item because you want to leave space for extra condiments. If you want effect besides healing, add a reagent for
//	it. Try to stick to existing reagents when possible (so if you want a stronger healing effect, just use Tricordrazine). On use
//	effect (such as the old officer eating a donut code) requires a unique reagent (unless you can figure out a better way).

//The nutriment reagent and bitesize variable replace the old heal_amt and amount variables. Each unit of nutriment is equal to
//	2 of the old heal_amt variable. Bitesize is the rate at which the reagents are consumed. So if you have 6 nutriment and a
//	bitesize of 2, then it'll take 3 bites to eat. Unlike the old system, the contained reagents are evenly spread among all
//	the bites. No more contained reagents = no more bites.

//Here is an example of the new formatting for anyone who wants to add more food items.
///obj/item/reagent_containers/food/xenoburger			//Identification path for the object.
//	name = "Xenoburger"													//Name that displays in the UI.
//	desc = "Smells caustic. Tastes like heresy."						//Duh
//	icon_state = "xburger"												//Refers to an icon in food.dmi
//	New()																//Don't mess with this.
//		..()															//Same here.
//		reagents.add_reagent(/datum/reagent/xenomicrobes, 10)						//This is what is in the food item. you may copy/paste
//		reagents.add_reagent(/datum/reagent/nutriment, 2)							//	this line of code for all the contents.
//		bitesize = 3													//This is the amount each bite consumes.

/obj/item/reagent_containers/food/aesirsalad
	name = "Aesir salad"
	desc = "Probably too incredible for mortal men to fully enjoy."
	icon_state = "aesirsalad"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#468c00"
	center_of_mass = "x=17;y=11"
	nutriment_amt = 8
	nutriment_desc = list("apples" = 3,"salad" = 5)
	startswith = list(
		/datum/reagent/drink/doctor_delight = 8,
		/datum/reagent/tricordrazine = 8)
	bitesize = 3

/obj/item/reagent_containers/food/candy_corn
	name = "candy corn"
	desc = "It's a handful of candy corn. Cannot be stored in a detective's hat, alas."
	icon_state = "candy_corn"
	filling_color = "#fffcb0"
	center_of_mass = "x=14;y=10"
	nutriment_amt = 8
	nutriment_desc = list("candy corn" = 8)
	startswith = list(/datum/reagent/sugar = 2)
	bitesize = 2

/obj/item/reagent_containers/food/cookie
	name = "cookie"
	desc = "COOKIE!!!"
	icon_state = "COOKIE!!!"
	filling_color = "#dbc94f"
	center_of_mass = "x=17;y=18"
	nutriment_amt = 5
	nutriment_desc = list("sweetness" = 3, "cookie" = 2)
	bitesize = 1

/obj/item/reagent_containers/food/chocolatebar
	name = "Chocolate Bar"
	desc = "Such sweet, fattening food."
	icon_state = "chocolatebar"
	filling_color = "#7d5f46"
	center_of_mass = "x=15;y=15"
	nutriment_amt = 2
	nutriment_desc = list("chocolate" = 5)
	startswith = list(
		/datum/reagent/sugar = 2,
		/datum/reagent/nutriment/coco = 2)
	bitesize = 2

/obj/item/reagent_containers/food/chocolateegg
	name = "Chocolate Egg"
	desc = "Such sweet, fattening food."
	icon_state = "chocolateegg"
	filling_color = "#7d5f46"
	center_of_mass = "x=16;y=13"
	nutriment_amt = 3
	nutriment_desc = list("chocolate" = 5)
	startswith = list(
		/datum/reagent/sugar = 2,
		/datum/reagent/nutriment/coco = 2)
	bitesize = 2

/obj/item/reagent_containers/food/donut
	name = "donut"
	desc = "Goes great with Robust Coffee."
	icon_state = "donut1"
	filling_color = "#d9c386"
	var/overlay_state = "box-donut1"
	center_of_mass = "x=13;y=16"
	nutriment_desc = list("sweetness", "donut")
	nutriment_amt = 3

/obj/item/reagent_containers/food/donut/normal
	startswith = list(/datum/reagent/nutriment/sprinkles = 1)
	bitesize = 3

/obj/item/reagent_containers/food/donut/normal/Initialize()
	. = ..()
	if(prob(30))
		src.icon_state = "donut2"
		src.overlay_state = "box-donut2"
		src.SetName("frosted donut")
		reagents.add_reagent(/datum/reagent/nutriment/sprinkles, 2)
		center_of_mass = "x=19;y=16"

/obj/item/reagent_containers/food/donut/chaos
	name = "Chaos Donut"
	desc = "Like life, it never quite tastes the same."
	icon_state = "donut1"
	filling_color = "#ed11e6"
	nutriment_amt = 2

/obj/item/reagent_containers/food/donut/chaos/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/nutriment/sprinkles, 1)
	bitesize = 10
	var/chaosselect = pick(1,2,3,4,5,6,7,8,9,10)
	switch(chaosselect)
		if(1)
			reagents.add_reagent(/datum/reagent/nutriment, 3)
		if(2)
			reagents.add_reagent(/datum/reagent/capsaicin, 3)
		if(3)
			reagents.add_reagent(/datum/reagent/frostoil, 3)
		if(4)
			reagents.add_reagent(/datum/reagent/nutriment/sprinkles, 3)
		if(5)
			reagents.add_reagent(/datum/reagent/toxin/plasma, 3)
		if(6)
			reagents.add_reagent(/datum/reagent/nutriment/coco, 3)
		if(7)
			reagents.add_reagent(/datum/reagent/metroidjelly, 3)
		if(8)
			reagents.add_reagent(/datum/reagent/drink/juice/banana, 3)
		if(9)
			reagents.add_reagent(/datum/reagent/drink/juice/berry, 3)
		if(10)
			reagents.add_reagent(/datum/reagent/tricordrazine, 3)
	if(prob(30))
		src.icon_state = "donut2"
		src.overlay_state = "box-donut2"
		src.SetName("Frosted Chaos Donut")
		reagents.add_reagent(/datum/reagent/nutriment/sprinkles, 2)


/obj/item/reagent_containers/food/donut/jelly
	name = "Jelly Donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	filling_color = "#ed1169"
	center_of_mass = "x=16;y=11"
	startswith = list(
		/datum/reagent/nutriment/sprinkles = 1,
		/datum/reagent/drink/juice/berry = 5)
	bitesize = 5


/obj/item/reagent_containers/food/donut/jelly/Initialize()
	. = ..()
	if(prob(30))
		src.icon_state = "jdonut2"
		src.overlay_state = "box-donut2"
		src.SetName("Frosted Jelly Donut")
		reagents.add_reagent(/datum/reagent/nutriment/sprinkles, 2)

/obj/item/reagent_containers/food/donut/metroidjelly
	name = "Jelly Donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	filling_color = "#ed1169"
	center_of_mass = "x=16;y=11"
	startswith = list(
		/datum/reagent/nutriment/sprinkles = 1,
		/datum/reagent/metroidjelly = 5)
	bitesize = 5

/obj/item/reagent_containers/food/donut/metroidjelly/Initialize()
	. = ..()
	if(prob(30))
		src.icon_state = "jdonut2"
		src.overlay_state = "box-donut2"
		src.SetName("Frosted Jelly Donut")
		reagents.add_reagent(/datum/reagent/nutriment/sprinkles, 2)

/obj/item/reagent_containers/food/donut/cherryjelly
	name = "Jelly Donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	filling_color = "#ed1169"
	center_of_mass = "x=16;y=11"
	startswith = list(
		/datum/reagent/nutriment/sprinkles = 1,
		/datum/reagent/nutriment/cherryjelly = 5)
	bitesize = 5

/obj/item/reagent_containers/food/donut/cherryjelly/Initialize()
	. = ..()
	if(prob(30))
		src.icon_state = "jdonut2"
		src.overlay_state = "box-donut2"
		src.SetName("Frosted Jelly Donut")
		reagents.add_reagent(/datum/reagent/nutriment/sprinkles, 2)

/obj/item/reagent_containers/food/vegg
	name = "vegg"
	desc = "So... It's more like a seed, right?"
	icon_state = "egg-vegan"
	filling_color = "#70bf70"
	volume = 10
	center_of_mass = "x=16;y=13"
	nutriment_amt = 3

/obj/item/reagent_containers/food/egg
	name = "egg"
	desc = "An egg!"
	icon_state = "egg"
	filling_color = "#fdffd1"
	volume = 10
	center_of_mass = "x=16;y=13"
	startswith = list(/datum/reagent/nutriment/protein/egg = 3)

/obj/item/reagent_containers/food/egg/afterattack(obj/O, mob/user, proximity)
	if(istype(O,/obj/machinery/microwave))
		return ..()
	if(!(proximity && O.is_open_container()))
		return
	to_chat(user, "You crack \the [src] into \the [O].")
	reagents.trans_to(O, reagents.total_volume)
	qdel(src)

/obj/item/reagent_containers/food/egg/throw_impact(atom/hit_atom)
	..()
	if(QDELETED(src))
		return // Could be happened hitby()
	new /obj/effect/decal/cleanable/egg_smudge(src.loc)
	src.reagents.splash(hit_atom, src.reagents.total_volume)
	src.visible_message("<span class='warning'>\The [src] has been squashed!</span>","<span class='warning'>You hear a smack.</span>")
	qdel(src)

/obj/item/reagent_containers/food/egg/attackby(obj/item/W, mob/user)
	if(istype( W, /obj/item/pen/crayon ))
		var/obj/item/pen/crayon/C = W
		var/clr = C.colourName

		if(!(clr in list("blue","green","mime","orange","purple","rainbow","red","yellow")))
			to_chat(usr, "<span class='notice'>The egg refuses to take on this color!</span>")
			return

		to_chat(usr, "<span class='notice'>You color \the [src] [clr]</span>")
		icon_state = "egg-[clr]"
	else
		..()

/obj/item/reagent_containers/food/egg/randomcolor/Initialize()
	. = ..()
	var/clr = pick("blue","green","mime","orange","purple","rainbow","red","yellow")
	icon_state = "egg-[clr]"

/obj/item/reagent_containers/food/egg/blue
	icon_state = "egg-blue"

/obj/item/reagent_containers/food/egg/green
	icon_state = "egg-green"

/obj/item/reagent_containers/food/egg/mime
	icon_state = "egg-mime"

/obj/item/reagent_containers/food/egg/orange
	icon_state = "egg-orange"

/obj/item/reagent_containers/food/egg/purple
	icon_state = "egg-purple"

/obj/item/reagent_containers/food/egg/rainbow
	icon_state = "egg-rainbow"

/obj/item/reagent_containers/food/egg/red
	icon_state = "egg-red"

/obj/item/reagent_containers/food/egg/yellow
	icon_state = "egg-yellow"

/obj/item/reagent_containers/food/egg/robot
	name = "robot egg"
	icon_state = "egg-robot"
	startswith = list(
		/datum/reagent/nutriment/protein/egg = 3,
		/datum/reagent/nanites = 1)

/obj/item/reagent_containers/food/egg/golden
	name = "golden egg"
	icon_state = "egg-golden"
	startswith = list(
		/datum/reagent/nutriment/protein/egg = 3,
		/datum/reagent/gold = 3)

/obj/item/reagent_containers/food/egg/plasma
	name = "plasma egg"
	icon_state = "egg-plasma"
	startswith = list(
		/datum/reagent/nutriment/protein/egg = 3,
		/datum/reagent/toxin/plasma = 3)

/obj/item/reagent_containers/food/friedegg
	name = "Fried egg"
	desc = "A fried egg, with a touch of salt and pepper."
	icon_state = "friedegg"
	filling_color = "#ffdf78"
	center_of_mass = "x=16;y=14"
	startswith = list(
		/datum/reagent/nutriment/protein = 3,
		/datum/reagent/sodiumchloride = 1,
		/datum/reagent/blackpepper = 1)
	bitesize = 1

/obj/item/reagent_containers/food/baconeggs
	name = "eggs and bacon"
	desc = "A classic breakfast combo of fried, sunny-side eggs, with bacon strips on the side." // Wakey wakey.
	icon_state = "baconegg"
	bitesize = 4
	startswith = list(
		/datum/reagent/nutriment/protein = 6,
		/datum/reagent/nutriment/cornoil = 3)
	nutriment_desc = list("bacon" = 5, "fried eggs" = 5)

/obj/item/reagent_containers/food/benedict
	name = "eggs benedict"
	desc = "A perfectly poached runny egg sitting atop a bedding of Nadezhdian bacon and muffin, with hollandaise sauce generously spread on top. The best breakfast you'll ever have."
	icon_state = "benedict"
	bitesize = 5
	startswith = list(
		/datum/reagent/nutriment/protein = 15,
		/datum/reagent/sodiumchloride = 1,
		/datum/reagent/blackpepper = 1)
	nutriment_desc = list("ham" = 5, "poached egg" = 5, "hollandaise sauce" = 3)

/obj/item/reagent_containers/food/boiledegg
	name = "Boiled egg"
	desc = "A hard boiled egg."
	icon_state = "egg"
	filling_color = "#ffffff"
	startswith = list(/datum/reagent/nutriment/protein = 3)
	bitesize = 1

/obj/item/reagent_containers/food/tofu
	name = "Tofu"
	icon_state = "tofu"
	desc = "We all love tofu."
	filling_color = "#fffee0"
	center_of_mass = "x=17;y=10"
	nutriment_amt = 3
	nutriment_desc = list("tofu" = 3, "goeyness" = 3)
	bitesize = 3

/obj/item/reagent_containers/food/tofurkey
	name = "Tofurkey"
	desc = "A fake turkey made from tofu."
	icon_state = "tofurkey"
	filling_color = "#fffee0"
	center_of_mass = "x=16;y=8"
	nutriment_amt = 12
	nutriment_desc = list("turkey" = 3, "tofu" = 5, "goeyness" = 4)
	bitesize = 3

/obj/item/reagent_containers/food/stuffing
	name = "Stuffing"
	desc = "Moist, peppery breadcrumbs for filling the body cavities of dead birds. Dig in!"
	icon_state = "stuffing"
	filling_color = "#c9ac83"
	center_of_mass = "x=16;y=10"
	nutriment_amt = 3
	nutriment_desc = list("dryness" = 2, "bread" = 2)
	bitesize = 1

/obj/item/reagent_containers/food/carpmeat
	name = "carp fillet"
	desc = "A fillet of spess carp meat."
	icon_state = "fishfillet"
	filling_color = "#ffdefe"
	center_of_mass = "x=17;y=13"
	startswith = list(
		/datum/reagent/nutriment/protein = 3,
		/datum/reagent/toxin/carpotoxin = 6)
	bitesize = 6

/obj/item/reagent_containers/food/sashimi
	name = "sashimi"
	desc = "Raw cuts of carp fillet with a side of soy sauce, apparently an eastern earth delicacy."
	icon_state = "sashimi"
	trash = /obj/item/trash/dish/plate
	bitesize = 2
	nutriment_amt = 4
	startswith = list(
		/datum/reagent/nutriment/protein = 6,
		/datum/reagent/toxin/carpotoxin = 4)
	nutriment_desc = list("raw fish" = 2, "soy sauce" = 2)

/obj/item/reagent_containers/food/fishfingers
	name = "Fish Fingers"
	desc = "A finger of fish."
	icon_state = "fishfingers"
	filling_color = "#ffdefe"
	center_of_mass = "x=16;y=13"
	startswith = list(/datum/reagent/nutriment/protein = 4)
	bitesize = 3

/obj/item/reagent_containers/food/hugemushroomslice
	name = "huge mushroom slice"
	desc = "A slice from a huge mushroom."
	icon_state = "hugemushroomslice"
	filling_color = "#e0d7c5"
	center_of_mass = "x=17;y=16"
	nutriment_amt = 3
	nutriment_desc = list("raw" = 2, "mushroom" = 2)
	startswith = list(/datum/reagent/psilocybin = 3)
	bitesize = 6

/obj/item/reagent_containers/food/tomatomeat
	name = "tomato slice"
	desc = "A slice from a huge tomato."
	icon_state = "tomatomeat"
	filling_color = "#db0000"
	center_of_mass = "x=17;y=16"
	nutriment_amt = 3
	nutriment_desc = list("raw" = 2, "tomato" = 3)
	startswith = list(/datum/reagent/drink/juice/tomato = 3)
	bitesize = 6

/obj/item/reagent_containers/food/bearmeat
	name = "bear meat"
	desc = "A very manly slab of meat."
	icon_state = "bearmeat"
	filling_color = "#db0000"
	center_of_mass = "x=16;y=10"
	startswith = list(
		/datum/reagent/nutriment/protein = 12,
		/datum/reagent/hyperzine = 5)
	bitesize = 3

/obj/item/reagent_containers/food/faggot
	name = "faggot"
	desc = "A great meal all round."
	icon_state = "faggot"
	filling_color = "#db0000"
	center_of_mass = "x=16;y=16"
	startswith = list(/datum/reagent/nutriment/protein = 3)
	bitesize = 2

/obj/item/reagent_containers/food/rawfaggot
	name = "raw meatball"
	desc = "A raw meatball."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "rawfaggot"
	bitesize = 3
	center_of_mass = list("x"=16, "y"=15)
	startswith = list(/datum/reagent/nutriment/protein=5)

/obj/item/reagent_containers/food/rawfaggot/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/material/kitchen/rollingpin))
		new /obj/item/reagent_containers/food/patty_raw(src)
		to_chat(user, "You flatten the raw meatball.")
		qdel(src)


/obj/item/reagent_containers/food/patty_raw
	name = "raw patty"
	desc = "A raw patty ready to be grilled into a juicy and delicious burger."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "patty_raw"
	bitesize = 3
	center_of_mass = list("x"=17, "y"=20)
	startswith = list(/datum/reagent/nutriment/protein=2)

/obj/item/reagent_containers/food/patty
	name = "patty"
	desc = "A juicy cooked patty, ready to be slapped between two buns."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "patty"
	bitesize = 3
	center_of_mass = list("x"=17, "y"=20)
	startswith = list(/datum/reagent/nutriment/protein=5)

/obj/item/reagent_containers/food/sausage
	name = "Sausage"
	desc = "A piece of mixed, long meat."
	icon_state = "sausage"
	filling_color = "#db0000"
	center_of_mass = "x=16;y=16"
	startswith = list(/datum/reagent/nutriment/protein = 6)
	bitesize = 2

/obj/item/reagent_containers/food/donkpocket
	name = "Donk-pocket"
	desc = "The food of choice for the seasoned traitor."
	icon_state = "donkpocket"
	filling_color = "#dedeab"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("heartiness" = 1, "dough" = 2)
	nutriment_amt = 2
	startswith = list(/datum/reagent/nutriment/protein = 2)
	var/warm = FALSE
	var/list/heated_reagents = list(/datum/reagent/tricordrazine = 5)

/obj/item/reagent_containers/food/donkpocket/Initialize()
	. = ..()
	add_think_ctx("think_cool", CALLBACK(src, nameof(.proc/cooling)), 0)

/obj/item/reagent_containers/food/donkpocket/proc/heat()
	if(warm)
		return
	warm = TRUE
	for(var/reagent in heated_reagents)
		reagents.add_reagent(reagent, heated_reagents[reagent])
	bitesize = 6
	SetName("Warm " + name)
	cooltime()

/obj/item/reagent_containers/food/donkpocket/proc/cooltime()
	if(warm)
		set_next_think_ctx("think_cool", world.time + 7 MINUTES)
	return

/obj/item/reagent_containers/food/donkpocket/proc/cooling(warm)
	if(!warm)
		return

	warm = FALSE
	for(var/reagent in heated_reagents)
		reagents.del_reagent(reagent)
	SetName(initial(name))

/obj/item/reagent_containers/food/donkpocket/sinpocket
	name = "\improper Sin-pocket"
	desc = "The food of choice for the veteran. Do <B>NOT</B> overconsume."
	filling_color = "#6d6d00"
	heated_reagents = list(/datum/reagent/tricordrazine = 5, /datum/reagent/drink/doctor_delight = 5, /datum/reagent/hyperzine = 0.75, /datum/reagent/synaptizine = 0.25)
	var/has_been_heated = 0

/obj/item/reagent_containers/food/donkpocket/sinpocket/Initialize()
	. = ..()
	add_think_ctx("think_heat", CALLBACK(src, nameof(.proc/heat)), 0)

/obj/item/reagent_containers/food/donkpocket/sinpocket/attack_self(mob/user)
	if(has_been_heated)
		to_chat(user, "<span class='notice'>The heating chemicals have already been spent.</span>")
		return
	has_been_heated = 1
	user.visible_message("<span class='notice'>[user] crushes \the [src] package.</span>", "You crush \the [src] package and feel a comfortable heat build up.")
	set_next_think_ctx("think_heat", world.time + 20 SECONDS)

/obj/item/reagent_containers/food/donkpocket/sinpocket/heat(user)
	if(user)
		to_chat(user, "You think \the [src] is ready to eat about now.")
	. = ..()

/obj/item/reagent_containers/food/brainburger
	name = "brainburger"
	desc = "A strange looking burger. It looks almost sentient."
	icon_state = "brainburger"
	filling_color = "#f2b6ea"
	center_of_mass = "x=15;y=11"
	startswith = list(
		/datum/reagent/nutriment/protein = 6,
		/datum/reagent/alkysine = 6)
	bitesize = 2

/obj/item/reagent_containers/food/ghostburger
	name = "Ghost Burger"
	desc = "Spooky! It doesn't look very filling."
	icon_state = "ghostburger"
	filling_color = "#fff2ff"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("buns" = 3, "spookiness" = 3)
	nutriment_amt = 2
	bitesize = 2

/obj/item/reagent_containers/food/human
	var/hname = ""
	var/job = null
	filling_color = "#d63c3c"

/obj/item/reagent_containers/food/human/burger
	name = "-burger"
	desc = "A bloody burger."
	icon_state = "hburger"
	center_of_mass = "x=16;y=11"
	startswith = list(/datum/reagent/nutriment/protein = 6)
	bitesize = 2

/obj/item/reagent_containers/food/cheeseburger
	name = "cheeseburger"
	desc = "The cheese adds a good flavor."
	icon_state = "cheeseburger"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("cheese" = 2, "bun" = 2)
	nutriment_amt = 2
	startswith = list(/datum/reagent/nutriment/protein = 2)

/obj/item/reagent_containers/food/plainburger
	name = "burger"
	desc = "The cornerstone of every nutritious breakfast."
	icon_state = "hburger"
	filling_color = "#d63c3c"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("bun" = 2)
	nutriment_amt = 3
	startswith = list(/datum/reagent/nutriment/protein = 3)
	bitesize = 2

/obj/item/reagent_containers/food/fishburger
	name = "Fillet -o- Carp Sandwich"
	desc = "Almost like a carp is yelling somewhere... Give me back that fillet -o- carp, give me that carp."
	icon_state = "fishburger"
	filling_color = "#ffdefe"
	center_of_mass = "x=16;y=10"
	startswith = list(/datum/reagent/nutriment/protein = 6)
	bitesize = 3

/obj/item/reagent_containers/food/tofuburger
	name = "Tofu Burger"
	desc = "What.. is that meat?"
	icon_state = "tofuburger"
	filling_color = "#fffee0"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("bun" = 2, "pseudo-soy meat" = 3)
	nutriment_amt = 6
	bitesize = 2

/obj/item/reagent_containers/food/roburger
	name = "roburger"
	desc = "The lettuce is the only organic component. Beep."
	icon_state = "roburger"
	filling_color = "#cccccc"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("bun" = 2, "metal" = 3)
	nutriment_amt = 2
	bitesize = 2

/obj/item/reagent_containers/food/roburger/Initialize()
	. = ..()
	if(prob(5))
		reagents.add_reagent(/datum/reagent/nanites, 2)

/obj/item/reagent_containers/food/roburgerbig
	name = "roburger"
	desc = "This massive patty looks like poison. Beep."
	icon_state = "roburger"
	filling_color = "#cccccc"
	volume = 100
	center_of_mass = "x=16;y=11"
	startswith = list(/datum/reagent/nanites = 100)
	bitesize = 0.1

/obj/item/reagent_containers/food/xenoburger
	name = "xenoburger"
	desc = "Smells caustic. Tastes like heresy."
	icon_state = "xburger"
	filling_color = "#43de18"
	center_of_mass = "x=16;y=11"
	startswith = list(/datum/reagent/nutriment/protein = 8, /datum/reagent/xenomicrobes = 5)
	bitesize = 2

/obj/item/reagent_containers/food/clownburger
	name = "Clown Burger"
	desc = "This tastes funny..."
	icon_state = "clownburger"
	filling_color = "#ff00ff"
	center_of_mass = "x=17;y=12"
	nutriment_desc = list("bun" = 2, "clown shoe" = 3)
	nutriment_amt = 6
	bitesize = 2

/obj/item/reagent_containers/food/mimeburger
	name = "Mime Burger"
	desc = "Its taste defies language."
	icon_state = "mimeburger"
	filling_color = "#ffffff"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("bun" = 2, "mime paint" = 3)
	nutriment_amt = 6
	bitesize = 2

/obj/item/reagent_containers/food/omelette
	name = "Omelette Du Fromage"
	desc = "That's all you can say!"
	icon_state = "omelette"
	trash = /obj/item/trash/dish/plate
	filling_color = "#fff9a8"
	center_of_mass = "x=16;y=13"
	startswith = list(/datum/reagent/nutriment/protein = 8)
	bitesize = 1

/obj/item/reagent_containers/food/muffin
	name = "Muffin"
	desc = "A delicious and spongy little cake."
	icon_state = "muffin"
	filling_color = "#e0cf9b"
	center_of_mass = "x=17;y=4"
	nutriment_desc = list("sweetness" = 3, "muffin" = 3)
	nutriment_amt = 6
	bitesize = 2

/obj/item/reagent_containers/food/pie
	name = "Banana Cream Pie"
	desc = "Just like back home, on clown planet! HONK!"
	icon_state = "pie"
	trash = /obj/item/trash/dish/plate
	filling_color = "#fbffb8"
	center_of_mass = "x=16;y=13"
	nutriment_desc = list("pie" = 3, "cream" = 2)
	nutriment_amt = 4
	startswith = list(/datum/reagent/drink/juice/banana = 5)
	bitesize = 3

/obj/item/reagent_containers/food/pie/throw_impact(atom/hit_atom)
	..()
	new /obj/effect/decal/cleanable/pie_smudge(loc)
	visible_message(SPAN("danger", "\The [src] splats."), SPAN("danger", "You hear a splat."))
	qdel(src)

/obj/item/reagent_containers/food/berryclafoutis
	name = "Berry Clafoutis"
	desc = "No black birds, this is a good sign."
	icon_state = "berryclafoutis"
	trash = /obj/item/trash/dish/plate
	center_of_mass = "x=16;y=13"
	nutriment_desc = list("sweetness" = 2, "pie" = 3)
	nutriment_amt = 4
	startswith = list(/datum/reagent/drink/juice/berry = 5)
	bitesize = 3

/obj/item/reagent_containers/food/waffles
	name = "waffles"
	desc = "Mmm, waffles."
	icon_state = "waffles"
	trash = /obj/item/trash/dish/baking_sheet
	filling_color = "#e6deb5"
	center_of_mass = "x=15;y=11"
	nutriment_desc = list("waffle" = 8)
	nutriment_amt = 8
	bitesize = 2

/obj/item/reagent_containers/food/pancakes
	name = "pancakes"
	desc = "Pancakes with blueberries, delicious."
	icon_state = "pancakes"
	trash = /obj/item/trash/dish/plate
	center_of_mass = "x=15;y=11"
	nutriment_desc = list("pancake" = 8)
	nutriment_amt = 8
	bitesize = 2

/obj/item/reagent_containers/food/eggplantparm
	name = "Eggplant Parmigiana"
	desc = "The only good recipe for eggplant."
	icon_state = "eggplantparm"
	trash = /obj/item/trash/dish/plate
	filling_color = "#4d2f5e"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("cheese" = 3, "eggplant" = 3)
	nutriment_amt = 6
	bitesize = 2

/obj/item/reagent_containers/food/soylentgreen
	name = "Soylent Green"
	desc = "Not made of people. Honest." //Totally people.
	icon_state = "soylent_green"
	trash = /obj/item/trash/dish/baking_sheet
	filling_color = "#b8e6b5"
	center_of_mass = "x=15;y=11"
	startswith = list(/datum/reagent/nutriment/protein = 10)
	bitesize = 2

/obj/item/reagent_containers/food/soylenviridians
	name = "Soylen Virdians"
	desc = "Not made of people. Honest." //Actually honest for once.
	icon_state = "soylent_yellow"
	trash = /obj/item/trash/dish/baking_sheet
	filling_color = "#e6fa61"
	center_of_mass = "x=15;y=11"
	nutriment_desc = list("some sort of protein" = 10) //seasoned VERY well.
	nutriment_amt = 10
	bitesize = 2

/obj/item/reagent_containers/food/meatpie
	name = "Meat-pie"
	icon_state = "meatpie"
	desc = "An old barber recipe, very delicious!"
	trash = /obj/item/trash/dish/plate
	filling_color = "#948051"
	center_of_mass = "x=16;y=13"
	startswith = list(/datum/reagent/nutriment/protein = 10)
	bitesize = 2

/obj/item/reagent_containers/food/tofupie
	name = "Tofu-pie"
	icon_state = "meatpie"
	desc = "A delicious tofu pie."
	trash = /obj/item/trash/dish/plate
	filling_color = "#fffee0"
	center_of_mass = "x=16;y=13"
	nutriment_desc = list("tofu" = 2, "pie" = 8)
	nutriment_amt = 10
	bitesize = 2

/obj/item/reagent_containers/food/amanita_pie
	name = "amanita pie"
	desc = "Sweet and tasty poison pie."
	icon_state = "amanita_pie"
	filling_color = "#ffcccc"
	center_of_mass = "x=17;y=9"
	nutriment_desc = list("sweetness" = 3, "mushroom" = 3, "pie" = 2)
	nutriment_amt = 5
	startswith = list(
		/datum/reagent/toxin/amatoxin = 3,
		/datum/reagent/psilocybin = 1)
	bitesize = 3

/obj/item/reagent_containers/food/plump_pie
	name = "plump pie"
	desc = "I bet you love stuff made out of plump helmets!"
	icon_state = "plump_pie"
	filling_color = "#b8279b"
	center_of_mass = "x=17;y=9"
	nutriment_desc = list("heartiness" = 2, "mushroom" = 3, "pie" = 3)
	nutriment_amt = 8

/obj/item/reagent_containers/food/plump_pie/Initialize()
	. = ..()
	if(prob(10))
		name = "exceptional plump pie"
		desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump pie!"
		reagents.add_reagent(/datum/reagent/tricordrazine, 5)
		bitesize = 2

/obj/item/reagent_containers/food/xemeatpie
	name = "Xeno-pie"
	icon_state = "xenomeatpie"
	desc = "A delicious meatpie. Probably heretical."
	trash = /obj/item/trash/dish/plate
	filling_color = "#43de18"
	center_of_mass = "x=16;y=13"
	startswith = list(/datum/reagent/nutriment/protein = 10)
	bitesize = 2

/obj/item/reagent_containers/food/wingfangchu
	name = "Wing Fang Chu"
	desc = "A savory dish of alien wing wang in soy."
	icon_state = "wingfangchu"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#43de18"
	center_of_mass = "x=17;y=9"
	startswith = list(/datum/reagent/nutriment/protein = 6)
	bitesize = 2

/obj/item/reagent_containers/food/meatkabob
	name = "Meat-kabob"
	icon_state = "kabob"
	desc = "Delicious meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#a85340"
	center_of_mass = "x=17;y=15"
	startswith = list(/datum/reagent/nutriment/protein = 8)
	bitesize = 2

/obj/item/reagent_containers/food/tofukabob
	name = "Tofu-kabob"
	icon_state = "kabob"
	desc = "Vegan meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#fffee0"
	center_of_mass = "x=17;y=15"
	nutriment_desc = list("tofu" = 3, "metal" = 1)
	nutriment_amt = 8
	bitesize = 2

/obj/item/reagent_containers/food/cubancarp
	name = "Cuban Carp"
	desc = "A sandwich that burns your tongue and then leaves it numb!"
	icon_state = "cubancarp"
	trash = /obj/item/trash/dish/plate
	filling_color = "#e9adff"
	center_of_mass = "x=12;y=5"
	nutriment_desc = list("toasted bread" = 3)
	nutriment_amt = 3
	startswith = list(
		/datum/reagent/nutriment/protein = 3,
		/datum/reagent/capsaicin = 3)
	bitesize = 3

/obj/item/reagent_containers/food/popcorn
	name = "Popcorn"
	desc = "Now let's find some cinema."
	icon_state = "popcorn"
	trash = /obj/item/trash/popcorn
	var/unpopped = 0
	filling_color = "#fffad4"
	center_of_mass = "x=16;y=8"
	nutriment_desc = list("popcorn" = 3)
	nutriment_amt = 2
	bitesize = 0.1

/obj/item/reagent_containers/food/popcorn/Initialize()
	. = ..()
	unpopped = rand(1, 10)

/obj/item/reagent_containers/food/popcorn/On_Consume()
	if(prob(unpopped))	//lol ...what's the point?
		to_chat(usr, SPAN("warning", "You bite down on an un-popped kernel!"))
		unpopped = max(0, unpopped - 1)
	..()

/obj/item/reagent_containers/food/spacetwinkie
	name = "Space Twinkie"
	icon_state = "space_twinkie"
	desc = "Guaranteed to survive longer then you will."
	filling_color = "#ffe591"
	center_of_mass = "x=15;y=11"
	startswith = list(/datum/reagent/sugar = 4)
	bitesize = 2

/obj/item/reagent_containers/food/loadedbakedpotato
	name = "Loaded Baked Potato"
	desc = "Totally baked."
	icon_state = "loadedbakedpotato"
	filling_color = "#9c7a68"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("baked potato" = 3)
	nutriment_amt = 3
	startswith = list(/datum/reagent/nutriment/protein = 3)
	bitesize = 2

/obj/item/reagent_containers/food/fries
	name = "Space Fries"
	desc = "AKA: French Fries, Freedom Fries, etc."
	icon_state = "fries"
	trash = /obj/item/trash/dish/plate
	filling_color = "#eddd00"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("fresh fries" = 4)
	nutriment_amt = 4
	bitesize = 2

/obj/item/reagent_containers/food/onionrings
	name = "Onion Rings"
	desc = "Like circular fries but better."
	icon_state = "onionrings"
	trash = /obj/item/trash/dish/plate
	filling_color = "#eddd00"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("fried onions" = 5)
	nutriment_amt = 5
	bitesize = 2

/obj/item/reagent_containers/food/soydope
	name = "Soy Dope"
	desc = "Dope from a soy."
	icon_state = "soydope"
	trash = /obj/item/trash/dish/plate
	filling_color = "#c4bf76"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("slime" = 2, "soy" = 2)
	nutriment_amt = 2
	bitesize = 2

/obj/item/reagent_containers/food/spaghetti
	name = "Spaghetti"
	desc = "A bundle of raw spaghetti."
	icon_state = "spagetti"
	filling_color = "#eddd00"
	center_of_mass = "x=16;y=16"
	nutriment_desc = list("noodles" = 2)
	nutriment_amt = 1
	bitesize = 1

/obj/item/reagent_containers/food/cheesyfries
	name = "Cheesy Fries"
	desc = "Fries. Covered in cheese. Duh."
	icon_state = "cheesyfries"
	trash = /obj/item/trash/dish/plate
	filling_color = "#eddd00"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("fresh fries" = 3, "cheese" = 3)
	nutriment_amt = 4
	startswith = list(/datum/reagent/nutriment/protein = 2)
	bitesize = 2

/obj/item/reagent_containers/food/fortunecookie
	name = "Fortune cookie"
	desc = "A true prophecy in each cookie!"
	icon_state = "fortune_cookie"
	filling_color = "#e8e79e"
	center_of_mass = "x=15;y=14"
	nutriment_desc = list("fortune cookie" = 2)
	nutriment_amt = 3
	bitesize = 2

/obj/item/reagent_containers/food/badrecipe
	name = "Burned mess"
	desc = "Someone should be demoted from chef for this."
	icon_state = "badrecipe"
	filling_color = "#211f02"
	center_of_mass = "x=16;y=12"
	startswith = list(
		/datum/reagent/toxin = 1,
		/datum/reagent/carbon = 3)
	bitesize = 2

/obj/item/reagent_containers/food/meatsteak
	name = "Meat steak"
	desc = "A piece of hot spicy meat."
	icon_state = "meatstake"
	trash = /obj/item/trash/dish/plate
	filling_color = "#7a3d11"
	center_of_mass = "x=16;y=13"
	startswith = list(
		/datum/reagent/nutriment/protein = 4,
		/datum/reagent/sodiumchloride = 1,
		/datum/reagent/blackpepper = 1)
	bitesize = 3

/obj/item/reagent_containers/food/loadedsteak
	name = "Loaded steak"
	desc = "A steak slathered in sauce with sauteed onions and mushrooms."
	icon_state = "meatstake"
	trash = /obj/item/trash/dish/plate
	filling_color = "#7a3d11"
	center_of_mass = "x=16;y=13"
	nutriment_desc = list("onion" = 2, "mushroom" = 2)
	nutriment_amt = 4
	startswith = list(
		/datum/reagent/nutriment/protein = 2,
		/datum/reagent/nutriment/garlicsauce = 2)
	bitesize = 3

/obj/item/reagent_containers/food/porkchop
	name = "Pork chop"
	desc = "This steak tastes like haram."
	icon_state = "porkchop"
	trash = /obj/item/trash/dish/plate
	filling_color = "#7a3d11"
	center_of_mass = "x=16;y=13"
	startswith = list(
		/datum/reagent/nutriment/protein = 4,
		/datum/reagent/sodiumchloride = 1,
		/datum/reagent/blackpepper = 1)
	bitesize = 3

/obj/item/reagent_containers/food/spacylibertyduff
	name = "Spacy Liberty Duff"
	desc = "Jello gelatin, from Alfred Hubbard's cookbook."
	icon_state = "spacylibertyduff"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#42b873"
	center_of_mass = "x=16;y=8"
	nutriment_desc = list("mushroom" = 6)
	nutriment_amt = 6
	startswith = list(/datum/reagent/psilocybin = 6)
	bitesize = 3

/obj/item/reagent_containers/food/amanitajelly
	name = "Amanita Jelly"
	desc = "Looks curiously toxic."
	icon_state = "amanitajelly"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#ed0758"
	center_of_mass = "x=16;y=5"
	nutriment_desc = list("jelly" = 3, "mushroom" = 3)
	nutriment_amt = 6
	startswith = list(
		/datum/reagent/toxin/amatoxin = 6,
		/datum/reagent/psilocybin = 3)
	bitesize = 3

/obj/item/reagent_containers/food/poppypretzel
	name = "Poppy pretzel"
	desc = "It's all twisted up!"
	icon_state = "poppypretzel"
	bitesize = 2
	filling_color = "#916e36"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("poppy seeds" = 2, "pretzel" = 3)
	nutriment_amt = 5
	bitesize = 2

/obj/item/reagent_containers/food/faggotsoup
	name = "Meatball soup"
	desc = "You've got balls kid, BALLS!"
	icon_state = "faggotsoup"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#785210"
	center_of_mass = "x=16;y=8"
	startswith = list(
		/datum/reagent/nutriment/protein = 8,
		/datum/reagent/water = 5)
	bitesize = 3

/obj/item/reagent_containers/food/fathersoup
	name = "Father's soup"
	desc = "A hellish meal. It's better to refuse politely."
	icon_state = "fathersoup"
	trash = /obj/item/trash/pan
	filling_color = "#f85210"
	center_of_mass = "x=16;y=16"
	startswith = list(
		/datum/reagent/nutriment/protein = 8,
		/datum/reagent/water = 10,
		/datum/reagent/thermite = 2,
		/datum/reagent/capsaicin = 5)
	bitesize = 5

/obj/item/reagent_containers/food/metroidsoup
	name = "metroid soup"
	desc = "If no water is available, you may substitute tears."
	icon_state = "rorosoup"
	filling_color = "#c4dba0"
	startswith = list(
		/datum/reagent/metroidjelly = 5,
		/datum/reagent/water = 10)
	bitesize = 5

/obj/item/reagent_containers/food/bloodsoup
	name = "Tomato soup"
	desc = "Smells like copper."
	icon_state = "tomatosoup"
	filling_color = "#ff0000"
	center_of_mass = "x=16;y=7"
	startswith = list(
		/datum/reagent/nutriment/protein = 2,
		/datum/reagent/blood = 10,
		/datum/reagent/water = 5)
	bitesize = 5

/obj/item/reagent_containers/food/clownstears
	name = "Clown's Tears"
	desc = "Not very funny."
	icon_state = "clownstears"
	filling_color = "#c4fbff"
	center_of_mass = "x=16;y=7"
	nutriment_desc = list("salt" = 1, "the worst joke" = 3)
	nutriment_amt = 4
	startswith = list(
		/datum/reagent/drink/juice/banana = 5,
		/datum/reagent/water = 10)
	bitesize = 5

/obj/item/reagent_containers/food/vegetablesoup
	name = "Vegetable soup"
	desc = "A highly nutritious blend of vegetative goodness. Guaranteed to leave you with a, er, \"souped-up\" sense of wellbeing."
	icon_state = "vegetablesoup"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#afc4b5"
	center_of_mass = "x=16;y=8"
	nutriment_desc = list("carrot" = 2, "corn" = 2, "eggplant" = 2, "potato" = 2)
	nutriment_amt = 8
	startswith = list(/datum/reagent/water = 5)
	bitesize = 3

/obj/item/reagent_containers/food/nettlesoup
	name = "Nettle soup"
	desc = "A mean, green, calorically lean dish derived from a poisonous plant. It has a rather acidic bite to its taste."
	icon_state = "nettlesoup"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#afc4b5"
	center_of_mass = "x=16;y=7"
	nutriment_desc = list("salad" = 4, "egg" = 2, "potato" = 2)
	nutriment_amt = 8
	startswith = list(
		/datum/reagent/water = 5,
		/datum/reagent/tricordrazine = 5)
	bitesize = 3

/obj/item/reagent_containers/food/mysterysoup
	name = "Mystery soup"
	desc = "The mystery is, why aren't you eating it?"
	icon_state = "mysterysoup"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#f082ff"
	center_of_mass = "x=16;y=6"
	nutriment_desc = list("backwash" = 1)
	nutriment_amt = 1
	bitesize = 5

/obj/item/reagent_containers/food/mysterysoup/Initialize()
	. = ..()
	var/mysteryselect = rand(1, 10)
	switch(mysteryselect)
		if(1)
			reagents.add_reagent(/datum/reagent/nutriment, 6)
			reagents.add_reagent(/datum/reagent/capsaicin, 3)
			reagents.add_reagent(/datum/reagent/drink/juice/tomato, 2)
		if(2)
			reagents.add_reagent(/datum/reagent/nutriment, 6)
			reagents.add_reagent(/datum/reagent/frostoil, 3)
			reagents.add_reagent(/datum/reagent/drink/juice/tomato, 2)
		if(3)
			reagents.add_reagent(/datum/reagent/nutriment, 5)
			reagents.add_reagent(/datum/reagent/water, 5)
			reagents.add_reagent(/datum/reagent/tricordrazine, 5)
		if(4)
			reagents.add_reagent(/datum/reagent/nutriment, 5)
			reagents.add_reagent(/datum/reagent/water, 10)
		if(5)
			reagents.add_reagent(/datum/reagent/nutriment, 2)
			reagents.add_reagent(/datum/reagent/drink/juice/banana, 10)
		if(6)
			reagents.add_reagent(/datum/reagent/nutriment, 6)
			reagents.add_reagent(/datum/reagent/blood, 10)
		if(7)
			reagents.add_reagent(/datum/reagent/metroidjelly, 10)
			reagents.add_reagent(/datum/reagent/water, 10)
		if(8)
			reagents.add_reagent(/datum/reagent/carbon, 10)
			reagents.add_reagent(/datum/reagent/toxin, 10)
		if(9)
			reagents.add_reagent(/datum/reagent/nutriment, 5)
			reagents.add_reagent(/datum/reagent/drink/juice/tomato, 10)
		if(10)
			reagents.add_reagent(/datum/reagent/nutriment, 6)
			reagents.add_reagent(/datum/reagent/drink/juice/tomato, 5)
			reagents.add_reagent(/datum/reagent/imidazoline, 5)

/obj/item/reagent_containers/food/wishsoup
	name = "Wish Soup"
	desc = "I wish this was soup."
	icon_state = "wishsoup"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#d1f4ff"
	center_of_mass = "x=16;y=11"
	startswith = list(/datum/reagent/water = 10)
	bitesize = 5

/obj/item/reagent_containers/food/wishsoup/Initialize()
	. = ..()
	if(prob(25))
		desc = "A wish come true!"
		reagents.add_reagent(/datum/reagent/nutriment, 8, list("something good" = 8))

/obj/item/reagent_containers/food/hotchili
	name = "Hot Chili"
	desc = "A five alarm Texan Chili!"
	icon_state = "hotchili"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#ff3c00"
	center_of_mass = "x=15;y=9"
	nutriment_desc = list("chilli peppers" = 3)
	nutriment_amt = 3
	startswith = list(
		/datum/reagent/nutriment/protein = 3,
		/datum/reagent/capsaicin = 3,
		/datum/reagent/drink/juice/tomato = 2)
	bitesize = 5

/obj/item/reagent_containers/food/coldchili
	name = "Cold Chili"
	desc = "This slush is barely a liquid!"
	icon_state = "coldchili"
	filling_color = "#2b00ff"
	center_of_mass = "x=15;y=9"
	nutriment_desc = list("ice peppers" = 3)
	nutriment_amt = 3
	trash = /obj/item/trash/dish/bowl
	startswith = list(
		/datum/reagent/nutriment/protein = 3,
		/datum/reagent/frostoil = 3,
		/datum/reagent/drink/juice/tomato = 2)
	bitesize = 5

/obj/item/reagent_containers/food/monkeycube
	name = "monkey cube"
	desc = "Just add water!"
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	icon_state = "monkeycube"
	bitesize = 12
	filling_color = "#adac7f"
	center_of_mass = "x=16;y=14"
	startswith = list(/datum/reagent/nutriment/protein = 10)

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

/obj/item/reagent_containers/food/monkeycube/On_Consume(mob/M)
	Expand(get_turf(M))
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.visible_message(SPAN("warning", "A screeching creature bursts out of [H]'s chest!"))
		var/obj/item/organ/external/organ = H.get_organ(BP_CHEST)
		organ.take_external_damage(50, 0, 0, "Animal escaping the ribcage")
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

/obj/item/reagent_containers/food/spellburger
	name = "Spell Burger"
	desc = "This is absolutely Ei Nath."
	icon_state = "spellburger"
	filling_color = "#d505ff"
	nutriment_desc = list("magic" = 3, "buns" = 3)
	nutriment_amt = 6
	bitesize = 2

/obj/item/reagent_containers/food/bigbiteburger
	name = "Big Bite Burger"
	desc = "Forget the Big Mac. THIS is the future!"
	icon_state = "bigbiteburger"
	filling_color = "#e3d681"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("buns" = 4)
	nutriment_amt = 4
	startswith = list(/datum/reagent/nutriment/protein = 10)
	bitesize = 3

/obj/item/reagent_containers/food/enchiladas
	name = "Enchiladas"
	desc = "Viva La Mexico!"
	icon_state = "enchiladas"
	trash = /obj/item/trash/dish/tray
	filling_color = "#a36a1f"
	center_of_mass = "x=16;y=13"
	nutriment_desc = list("tortilla" = 3, "corn" = 3)
	nutriment_amt = 2
	startswith = list(
		/datum/reagent/nutriment/protein = 6,
		/datum/reagent/capsaicin = 6)
	bitesize = 4

/obj/item/reagent_containers/food/monkeysdelight
	name = "monkey's Delight"
	desc = "Eeee Eee!"
	icon_state = "monkeysdelight"
	trash = /obj/item/trash/dish/tray
	filling_color = "#5c3c11"
	center_of_mass = "x=16;y=13"
	startswith = list(
		/datum/reagent/nutriment/protein = 10,
		/datum/reagent/drink/juice/banana = 5,
		/datum/reagent/blackpepper = 1,
		/datum/reagent/sodiumchloride = 1)
	bitesize = 6

/obj/item/reagent_containers/food/baguette
	name = "Baguette"
	desc = "Bon appetit!"
	icon_state = "baguette"
	filling_color = "#e3d796"
	center_of_mass = "x=18;y=12"
	nutriment_desc = list("french bread" = 6)
	nutriment_amt = 6
	startswith = list(
		/datum/reagent/blackpepper = 1,
		/datum/reagent/sodiumchloride = 1)
	bitesize = 3

/obj/item/reagent_containers/food/fishandchips
	name = "Fish and Chips"
	desc = "I do say so myself chap."
	icon_state = "fishandchips"
	filling_color = "#e3d796"
	center_of_mass = "x=16;y=16"
	nutriment_desc = list("salt" = 1, "chips" = 3)
	nutriment_amt = 3
	startswith = list(/datum/reagent/nutriment/protein = 3)
	bitesize = 3

/obj/item/reagent_containers/food/sandwich
	name = "Sandwich"
	desc = "A grand creation of meat, cheese, bread, and several leaves of lettuce! Arthur Dent would be proud."
	icon_state = "sandwich"
	trash = /obj/item/trash/dish/plate
	filling_color = "#d9be29"
	center_of_mass = "x=16;y=4"
	nutriment_desc = list("bread" = 3, "cheese" = 3)
	nutriment_amt = 3
	startswith = list(/datum/reagent/nutriment/protein = 3)
	bitesize = 2

/obj/item/reagent_containers/food/toastedsandwich
	name = "Toasted Sandwich"
	desc = "Now if you only had a pepper bar."
	icon_state = "toastedsandwich"
	trash = /obj/item/trash/dish/plate
	filling_color = "#d9be29"
	center_of_mass = "x=16;y=4"
	nutriment_desc = list("toasted bread" = 3, "cheese" = 3)
	nutriment_amt = 3
	startswith = list(
		/datum/reagent/nutriment/protein = 3,
		/datum/reagent/carbon = 2)
	bitesize = 2

/obj/item/reagent_containers/food/grilledcheese
	name = "Grilled Cheese Sandwich"
	desc = "Goes great with Tomato soup!"
	icon_state = "toastedsandwich"
	trash = /obj/item/trash/dish/plate
	filling_color = "#d9be29"
	nutriment_desc = list("toasted bread" = 3, "cheese" = 3)
	nutriment_amt = 3
	startswith = list(/datum/reagent/nutriment/protein = 4)
	bitesize = 2

/obj/item/reagent_containers/food/pelmeni
	name = "Pelmeni"
	desc = "Meat wrapped in thin uneven dough."
	icon_state = "pelmeni"
	filling_color = "#d9be29"
	center_of_mass = "x=16;y=4"
	nutriment_amt = 2
	startswith = list(/datum/reagent/nutriment/protein = 2)
	bitesize = 2

/obj/item/reagent_containers/food/boiledpelmeni
	name = "Boiled pelmeni"
	desc = "We don't know what was Siberia, but these tasty pelmeni definitely arrived from there."
	icon_state = "boiledpelmeni"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#d9be29"
	center_of_mass = "x=16;y=4"
	nutriment_amt = 5
	startswith = list(/datum/reagent/nutriment/protein = 5)
	bitesize = 3

/obj/item/reagent_containers/food/tomatosoup
	name = "Tomato Soup"
	desc = "Drinking this feels like being a vampire! A tomato vampire..."
	icon_state = "tomatosoup"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#d92929"
	center_of_mass = "x=16;y=7"
	nutriment_desc = list("soup" = 5)
	nutriment_amt = 5
	startswith = list(/datum/reagent/drink/juice/tomato = 10)
	bitesize = 3

/obj/item/reagent_containers/food/rofflewaffles
	name = "Roffle Waffles"
	desc = "Waffles from Roffle. Co."
	icon_state = "rofflewaffles"
	trash = /obj/item/trash/dish/baking_sheet
	filling_color = "#ff00f7"
	center_of_mass = "x=15;y=11"
	nutriment_desc = list("waffle" = 7, "sweetness" = 1)
	nutriment_amt = 8
	startswith = list(/datum/reagent/psilocybin = 9)
	bitesize = 4

/obj/item/reagent_containers/food/stew
	name = "Stew"
	desc = "A nice and warm stew. Healthy and strong."
	icon_state = "stew"
	filling_color = "#9e673a"
	center_of_mass = "x=16;y=5"
	nutriment_desc = list("tomato" = 2, "potato" = 2, "carrot" = 2, "eggplant" = 2, "mushroom" = 2)
	nutriment_amt = 6
	startswith = list(
		/datum/reagent/nutriment/protein = 4,
		/datum/reagent/drink/juice/tomato = 5,
		/datum/reagent/imidazoline = 5,
		/datum/reagent/water = 5)
	bitesize = 10

/obj/item/reagent_containers/food/jelliedtoast
	name = "Jellied Toast"
	desc = "A slice of bread covered with delicious jam."
	icon_state = "jellytoast"
	trash = /obj/item/trash/dish/plate
	filling_color = "#b572ab"
	center_of_mass = "x=16;y=8"
	nutriment_desc = list("toasted bread" = 2)
	nutriment_amt = 1
	bitesize = 3

/obj/item/reagent_containers/food/jelliedtoast/cherry
	startswith = list(/datum/reagent/nutriment/cherryjelly = 5)

/obj/item/reagent_containers/food/jelliedtoast/metroid
	startswith = list(/datum/reagent/metroidjelly = 5)

/obj/item/reagent_containers/food/jellyburger
	name = "Jelly Burger"
	desc = "Culinary delight..?"
	icon_state = "jellyburger"
	filling_color = "#b572ab"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("buns" = 5)
	nutriment_amt = 5
	bitesize = 2

/obj/item/reagent_containers/food/jellyburger/metroid
	startswith = list(/datum/reagent/metroidjelly = 5)

/obj/item/reagent_containers/food/jellyburger/cherry
	startswith = list(/datum/reagent/nutriment/cherryjelly = 5)

/obj/item/reagent_containers/food/milosoup
	name = "Milosoup"
	desc = "The universes best soup! Yum!!!"
	icon_state = "milosoup"
	trash = /obj/item/trash/dish/bowl
	center_of_mass = "x=16;y=7"
	nutriment_desc = list("soy" = 8)
	nutriment_amt = 8
	startswith = list(/datum/reagent/water = 5)
	bitesize = 4

/obj/item/reagent_containers/food/stewedsoymeat
	name = "Stewed Soy Meat"
	desc = "Even non-vegetarians will LOVE this!"
	icon_state = "stewedsoymeat"
	trash = /obj/item/trash/dish/plate
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("soy" = 4, "tomato" = 4)
	nutriment_amt = 8
	bitesize = 2

/obj/item/reagent_containers/food/boiledspaghetti
	name = "Boiled Spaghetti"
	desc = "A plain dish of noodles, this sucks."
	icon_state = "spagettiboiled"
	trash = /obj/item/trash/dish/plate
	filling_color = "#fcee81"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("noodles" = 2)
	nutriment_amt = 2
	bitesize = 2

/obj/item/reagent_containers/food/boiledrice
	name = "Boiled Rice"
	desc = "A boring dish of boring rice."
	icon_state = "boiledrice"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#fffbdb"
	center_of_mass = "x=17;y=11"
	nutriment_desc = list("rice" = 2)
	nutriment_amt = 2
	bitesize = 2

/obj/item/reagent_containers/food/ricepudding
	name = "Rice Pudding"
	desc = "Where's the jam?"
	icon_state = "rpudding"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#fffbdb"
	center_of_mass = "x=17;y=11"
	nutriment_desc = list("rice" = 2)
	nutriment_amt = 4
	bitesize = 2

/obj/item/reagent_containers/food/pastatomato
	name = "Spaghetti"
	desc = "Spaghetti and crushed tomatoes. Just like your abusive father used to make!"
	icon_state = "pastatomato"
	trash = /obj/item/trash/dish/plate
	filling_color = "#de4545"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("tomato" = 3, "noodles" = 3)
	nutriment_amt = 6
	startswith = list(/datum/reagent/drink/juice/tomato = 10)
	bitesize = 4

/obj/item/reagent_containers/food/faggotspaghetti
	name = "Spaghetti & Faggots"
	desc = "Now thats a nic'e faggot!"
	icon_state = "faggotspagetti"
	trash = /obj/item/trash/dish/plate
	filling_color = "#de4545"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("noodles" = 4)
	nutriment_amt = 4
	startswith = list(/datum/reagent/nutriment/protein = 4)
	bitesize = 2

/obj/item/reagent_containers/food/spesslaw
	name = "Spesslaw"
	desc = "A lawyers favourite."
	icon_state = "spesslaw"
	filling_color = "#de4545"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("noodles" = 4)
	nutriment_amt = 4
	startswith = list(/datum/reagent/nutriment/protein = 4)
	bitesize = 2

/obj/item/reagent_containers/food/carrotfries
	name = "Carrot Fries"
	desc = "Tasty fries from fresh Carrots."
	icon_state = "carrotfries"
	trash = /obj/item/trash/dish/plate
	filling_color = "#faa005"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("carrot" = 3, "salt" = 1)
	nutriment_amt = 3
	startswith = list(/datum/reagent/imidazoline = 3)
	bitesize = 2

/obj/item/reagent_containers/food/superbiteburger
	name = "Super Bite Burger"
	desc = "This is a mountain of a burger. FOOD!"
	icon_state = "superbiteburger"
	filling_color = "#cca26a"
	center_of_mass = "x=16;y=3"
	nutriment_desc = list("buns" = 25)
	nutriment_amt = 25
	startswith = list(/datum/reagent/nutriment/protein = 25)
	bitesize = 10

/obj/item/reagent_containers/food/candiedapple
	name = "Candied Apple"
	desc = "An apple coated in sugary sweetness."
	icon_state = "candiedapple"
	filling_color = "#f21873"
	center_of_mass = "x=15;y=13"
	nutriment_desc = list("apple" = 3, "caramel" = 3, "sweetness" = 2)
	nutriment_amt = 3
	bitesize = 3

/obj/item/reagent_containers/food/applepie
	name = "Apple Pie"
	desc = "A pie containing sweet sweet love... or apple."
	icon_state = "applepie"
	filling_color = "#e0edc5"
	center_of_mass = "x=16;y=13"
	nutriment_desc = list("sweetness" = 2, "apple" = 2, "pie" = 2)
	nutriment_amt = 4
	bitesize = 3

/obj/item/reagent_containers/food/cherrypie
	name = "Cherry Pie"
	desc = "Taste so good, make a grown man cry."
	icon_state = "cherrypie"
	filling_color = "#ff525a"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("sweetness" = 2, "cherry" = 2, "pie" = 2)
	nutriment_amt = 4
	bitesize = 3

/obj/item/reagent_containers/food/twobread
	name = "Two Bread"
	desc = "It is very bitter and winy."
	icon_state = "twobread"
	filling_color = "#dbcc9a"
	center_of_mass = "x=15;y=12"
	nutriment_desc = list("sourness" = 2, "bread" = 2)
	nutriment_amt = 2
	bitesize = 3

/obj/item/reagent_containers/food/threebread
	name = "Three Bread"
	desc = "Is such a thing even possible?"
	icon_state = "threebread"
	filling_color = "#dbcc9a"
	center_of_mass = "x=15;y=12"
	nutriment_desc = list("sourness" = 2, "bread" = 3)
	nutriment_amt = 3
	bitesize = 4

/obj/item/reagent_containers/food/jellysandwich
	name = "Jelly Sandwich"
	desc = "You wish you had some peanut butter to go with this..."
	icon_state = "jellysandwich"
	trash = /obj/item/trash/dish/plate
	filling_color = "#9e3a78"
	center_of_mass = "x=16;y=8"
	nutriment_desc = list("bread" = 2)
	nutriment_amt = 2
	bitesize = 3

/obj/item/reagent_containers/food/jellysandwich/metroid
	startswith = list(/datum/reagent/metroidjelly = 5)

/obj/item/reagent_containers/food/jellysandwich/cherry
	startswith = list(/datum/reagent/nutriment/cherryjelly = 5)

/obj/item/reagent_containers/food/boiledmetroidcore
	name = "Boiled metroid Core"
	desc = "A boiled red thing."
	icon_state = "boiledrorocore"
	startswith = list(/datum/reagent/metroidjelly = 5)
	bitesize = 3

/obj/item/reagent_containers/food/mint
	name = "mint"
	desc = "it is only wafer thin."
	icon_state = "mint"
	filling_color = "#f2f2f2"
	center_of_mass = "x=16;y=14"
	startswith = list(/datum/reagent/nutriment/mint = 1)
	bitesize = 1

/obj/item/reagent_containers/food/mushroomsoup
	name = "chantrelle soup"
	desc = "A delicious and hearty mushroom soup."
	icon_state = "mushroomsoup"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#e386bf"
	center_of_mass = "x=17;y=10"
	nutriment_desc = list("mushroom" = 8, "milk" = 2)
	nutriment_amt = 8
	bitesize = 3

/obj/item/reagent_containers/food/plumphelmetbiscuit
	name = "plump helmet biscuit"
	desc = "This is a finely-prepared plump helmet biscuit. The ingredients are exceptionally minced plump helmet, and well-minced dwarven wheat flour."
	icon_state = "phelmbiscuit"
	filling_color = "#cfb4c4"
	center_of_mass = "x=16;y=13"
	nutriment_desc = list("mushroom" = 4)
	nutriment_amt = 5
	bitesize = 2

/obj/item/reagent_containers/food/plumphelmetbiscuit/Initialize()
	. = ..()
	if(prob(10))
		name = "exceptional plump helmet biscuit"
		desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump helmet biscuit!"
		reagents.add_reagent(/datum/reagent/nutriment, 3)
		reagents.add_reagent(/datum/reagent/tricordrazine, 5)

/obj/item/reagent_containers/food/chawanmushi
	name = "chawanmushi"
	desc = "A legendary egg custard that makes friends out of enemies. Probably too hot for a cat to eat."
	icon_state = "chawanmushi"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#f0f2e4"
	center_of_mass = "x=17;y=10"
	startswith = list(/datum/reagent/nutriment/protein = 5)
	bitesize = 1

/obj/item/reagent_containers/food/beetsoup
	name = "beet soup"
	desc = "Wait, how do you spell it again..?"
	icon_state = "beetsoup"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#fac9ff"
	center_of_mass = "x=15;y=8"
	nutriment_desc = list("tomato" = 4, "beet" = 4)
	nutriment_amt = 8
	bitesize = 2

/obj/item/reagent_containers/food/beetsoup/Initialize()
	. = ..()
	name = pick(list("borsch","bortsch","borstch","borsh","borshch","borscht"))

/obj/item/reagent_containers/food/tossedsalad
	name = "tossed salad"
	desc = "A proper salad, basic and simple, with little bits of carrot, tomato and apple intermingled. Vegan!"
	icon_state = "herbsalad"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#76b87f"
	center_of_mass = "x=17;y=11"
	nutriment_desc = list("salad" = 2, "tomato" = 2, "carrot" = 2, "apple" = 2)
	nutriment_amt = 8
	bitesize = 3

/obj/item/reagent_containers/food/validsalad
	name = "valid salad"
	desc = "It's just a salad of questionable 'herbs' with faggots and fried potato slices. Nothing suspicious about it."
	icon_state = "validsalad"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#76b87f"
	center_of_mass = "x=17;y=11"
	nutriment_desc = list("100% real salad")
	nutriment_amt = 6
	startswith = list(/datum/reagent/nutriment/protein = 2)
	bitesize = 3

/obj/item/reagent_containers/food/appletart
	name = "golden apple streusel tart"
	desc = "A tasty dessert that won't make it through a metal detector."
	icon_state = "gappletart"
	trash = /obj/item/trash/dish/plate
	filling_color = "#ffff00"
	center_of_mass = "x=16;y=18"
	nutriment_desc = list("apple" = 8)
	nutriment_amt = 8
	startswith = list(/datum/reagent/gold = 5)
	bitesize = 3

/obj/item/reagent_containers/food/cracker
	name = "Cracker"
	desc = "It's a salted cracker."
	icon_state = "cracker"
	filling_color = "#f5deb8"
	center_of_mass = "x=17;y=6"
	nutriment_desc = list("salt" = 1, "cracker" = 2)
	nutriment_amt = 1

/obj/item/reagent_containers/food/dionaroast
	name = "roast diona"
	desc = "It's like an enormous, leathery carrot. With an eye."
	icon_state = "dionaroast"
	trash = /obj/item/trash/dish/plate
	filling_color = "#75754b"
	center_of_mass = "x=16;y=7"
	nutriment_desc = list("a chorus of flavor" = 6)
	nutriment_amt = 6
	startswith = list(/datum/reagent/radium = 2)
	bitesize = 2

///////////////////////////////////////////
// new old food stuff from bs12
///////////////////////////////////////////
/obj/item/reagent_containers/food/dough
	name = "dough"
	desc = "A piece of dough."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "dough"
	center_of_mass = "x=16;y=13"
	nutriment_desc = list("dough" = 3)
	nutriment_amt = 3
	startswith = list(/datum/reagent/nutriment/protein = 1)
	bitesize = 2

// Dough + rolling pin = flat dough
/obj/item/reagent_containers/food/dough/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/material/kitchen/rollingpin))
		new /obj/item/reagent_containers/food/sliceable/flatdough(src)
		to_chat(user, "You flatten the dough.")
		qdel(src)
	else if(istype(W, /obj/item/reagent_containers/food/faggot))
		new /obj/item/reagent_containers/food/pelmeni(src)
		to_chat(user, "You make some pelmeni.")
		qdel(src)
		qdel(W)

/obj/item/reagent_containers/food/bun
	name = "bun"
	desc = "A base for any self-respecting burger."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "bun"
	center_of_mass = "x=16;y=12"
	nutriment_desc = list("bun" = 4)
	nutriment_amt = 4
	bitesize = 2

/obj/item/reagent_containers/food/bun/attackby(obj/item/W, mob/user)
	// Bun + faggot = burger
	if(istype(W, /obj/item/reagent_containers/food/faggot))
		new /obj/item/reagent_containers/food/plainburger(src)
		to_chat(user, "You make a burger.")
		qdel(W)
		qdel(src)

	// Bun + cutlet = hamburger
	else if(istype(W, /obj/item/reagent_containers/food/cutlet))
		new /obj/item/reagent_containers/food/plainburger(src)
		to_chat(user, "You make a burger.")
		qdel(W)
		qdel(src)

	// Bun + sausage = hotdog
	else if(istype(W, /obj/item/reagent_containers/food/sausage))
		new /obj/item/reagent_containers/food/hotdog(src)
		to_chat(user, "You make a hotdog.")
		qdel(W)
		qdel(src)

// Burger + cheese wedge = cheeseburger
/obj/item/reagent_containers/food/plainburger/attackby(obj/item/reagent_containers/food/cheesewedge/W, mob/user)
	if(istype(W)) // && !istype(src,/obj/item/reagent_containers/food/cheesewedge))
		new /obj/item/reagent_containers/food/cheeseburger(src)
		to_chat(user, "You make a cheeseburger.")
		qdel(W)
		qdel(src)
		return
	else
		..()

// Human Burger + cheese wedge = cheeseburger
/obj/item/reagent_containers/food/human/burger/attackby(obj/item/reagent_containers/food/cheesewedge/W, mob/user)
	if(istype(W))
		new /obj/item/reagent_containers/food/cheeseburger(src)
		to_chat(user, "You make a cheeseburger.")
		qdel(W)
		qdel(src)
		return
	else
		..()

/obj/item/reagent_containers/food/bunbun
	name = "\improper Bun Bun"
	desc = "A small bread monkey fashioned from two burger buns."
	icon_state = "bunbun"
	center_of_mass = "x=16;y=8"
	nutriment_desc = list("bun" = 8)
	nutriment_amt = 8
	bitesize = 2

/obj/item/reagent_containers/food/taco
	name = "taco"
	desc = "Take a bite!"
	icon_state = "taco"
	center_of_mass = "x=21;y=12"
	nutriment_desc = list("cheese" = 2,"taco shell" = 2)
	nutriment_amt = 4
	startswith = list(/datum/reagent/nutriment/protein = 3)
	bitesize = 3

/obj/item/reagent_containers/food/rawcutlet
	name = "raw cutlet"
	desc = "A thin piece of raw meat."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "rawcutlet"
	bitesize = 2
	center_of_mass = list("x"=17, "y"=20)
	startswith = list(/datum/reagent/nutriment/protein = 3)

/obj/item/reagent_containers/food/rawcutlet/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/material/kitchen/rollingpin))
		new /obj/item/reagent_containers/food/rawfaggot(src)
		new /obj/item/reagent_containers/food/rawfaggot(src)
		to_chat(user, "You ground the sliced meat, and shape it into a ball.")
		qdel(src)

/obj/item/reagent_containers/food/cutlet
	name = "cutlet"
	desc = "A tasty slice of meat."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "cutlet"
	bitesize = 2
	center_of_mass = list("x"=17, "y"=20)
	startswith = list(/datum/reagent/nutriment/protein = 3)

/obj/item/reagent_containers/food/rawbacon
	name = "raw bacon"
	desc = "A thin slice of pork."
	icon = 'icons/obj/food.dmi'
	icon_state = "bacon"
	center_of_mass = "x=17;y=20"
	startswith = list(/datum/reagent/nutriment/protein = 2)
	bitesize = 2

/obj/item/reagent_containers/food/bacon
	name = "fried bacon"
	desc = "When it comes to bacon, always be prepared."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "bacon"
	bitesize = 2
	startswith = list(/datum/reagent/nutriment/cornoil=5,/datum/reagent/nutriment/protein=10)
	nutriment_desc = list("artery clogging freedom" = 10, "bacon fat" = 3)


/obj/item/reagent_containers/food/rawfaggot
	name = "raw faggot"
	desc = "A raw faggot."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "rawfaggot"
	center_of_mass = "x=16;y=15"
	startswith = list(/datum/reagent/nutriment/protein = 2)
	bitesize = 2

/obj/item/reagent_containers/food/hotdog
	name = "hotdog"
	desc = "Unrelated to dogs, maybe."
	icon_state = "hotdog"
	center_of_mass = "x=16;y=17"
	startswith = list(/datum/reagent/nutriment/protein = 6)
	bitesize = 2

/obj/item/reagent_containers/food/classichotdog
	name = "classic hotdog"
	desc = "Going literal."
	icon_state = "hotcorgi"
	center_of_mass = "x=16;y=17"
	startswith = list(/datum/reagent/nutriment/protein = 16)
	bitesize = 6

/obj/item/reagent_containers/food/flatbread
	name = "flatbread"
	desc = "Bland but filling."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "flatbread"
	center_of_mass = "x=16;y=16"
	nutriment_desc = list("bread" = 3)
	nutriment_amt = 3
	bitesize = 2

// potato + knife = raw sticks
/obj/item/reagent_containers/food/grown/potato/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/material/kitchen/utensil/knife))
		new /obj/item/reagent_containers/food/rawsticks(src)
		to_chat(user, "You cut the potato.")
		qdel(src)
	else
		..()

/obj/item/reagent_containers/food/rawsticks
	name = "raw potato sticks"
	desc = "Raw fries, not very tasty."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "rawsticks"
	center_of_mass = "x=16;y=12"
	nutriment_desc = list("raw potato" = 3)
	nutriment_amt = 3
	bitesize = 2

/obj/item/reagent_containers/food/liquidfood
	name = "\improper LiquidFood MRE"
	desc = "A prepackaged grey slurry for all of the essential nutrients a soldier requires to survive. No expiration date is visible..."
	icon_state = "liquidfood"
	trash = /obj/item/trash/liquidfood
	filling_color = "#a8a8a8"
	center_of_mass = "x=16;y=15"
	nutriment_desc = list("chalk" = 6)
	nutriment_amt = 20
	startswith = list(/datum/reagent/iron = 3)
	bitesize = 4

/obj/item/reagent_containers/food/smokedsausage
	name = "Smoked sausage"
	desc = "Piece of smoked sausage. Oh, really?"
	icon_state = "smokedsausage"
	center_of_mass = "x=16;y=9"
	startswith = list(/datum/reagent/nutriment/protein = 12)
	bitesize = 3

/obj/item/reagent_containers/food/julienne
	name = "Julienne"
	desc = "This is not the Julien, which you can think of, but also nice."
	icon_state = "julienne"
	center_of_mass = "x=15;y=15"
	nutriment_amt = 10
	startswith = list(
		/datum/reagent/nutriment/protein = 5,
		/datum/reagent/drink/juice/onion = 2)
	bitesize = 3

/obj/item/reagent_containers/food/ricewithmeat
	name = "Rice with meat"
	desc = "This is rice and... 'pork'."
	icon_state = "ricewithmeat"
	trash = /obj/item/trash/dish/bowl
	center_of_mass = "x=15;y=15"
	nutriment_amt = 10
	startswith = list(/datum/reagent/nutriment/protein = 5)
	bitesize = 3

/obj/item/reagent_containers/food/eggbowl
	name = "Eggbowl"
	desc = "Bowl of eggs. Of course."
	icon_state = "eggbowl"
	trash = /obj/item/trash/dish/bowl
	center_of_mass = "x=15;y=15"
	nutriment_amt = 10
	bitesize = 3

/obj/item/reagent_containers/food/meatbun
	name = "Meatbun"
	desc = "Has the potential to not be a dog."
	icon_state = "meatbun"
	center_of_mass = "x=15;y=15"
	nutriment_amt = 6
	startswith = list(/datum/reagent/nutriment/protein = 2)
	bitesize = 4

/obj/item/reagent_containers/food/eggsbenedict
	name = "Eggs Benedict"
	desc = "It's has only one egg, how rough."
	icon_state = "eggsbenedict"
	trash = /obj/item/trash/dish/plate
	center_of_mass = "x=15;y=15"
	nutriment_amt = 6
	startswith = list(/datum/reagent/nutriment/protein = 4)
	bitesize = 4

/obj/item/reagent_containers/food/fruitcup
	name = "Dina's fruit cup"
	desc = "Single salad with edible plate"
	icon_state = "fruitcup"
	center_of_mass = "x=15;y=15"
	nutriment_amt = 3
	startswith = list(
		/datum/reagent/drink/juice/watermelon = 5,
		/datum/reagent/drink/juice/orange = 5)
	bitesize = 4

/obj/item/reagent_containers/food/fruitsalad
	name = "Fruit salad"
	desc = "So sweety!"
	icon_state = "fruitsalad"
	trash = /obj/item/trash/dish/bowl
	center_of_mass = "x=15;y=15"
	nutriment_amt = 6
	startswith = list(
		/datum/reagent/drink/juice/watermelon = 3,
		/datum/reagent/drink/juice/orange = 3)
	bitesize = 3

/obj/item/reagent_containers/food/junglesalad
	name = "Jungle salad"
	desc = "From the depths of the jungle."
	icon_state = "junglesalad"
	trash = /obj/item/trash/dish/bowl
	center_of_mass = "x=15;y=15"
	nutriment_amt = 6
	startswith = list(/datum/reagent/drink/juice/watermelon = 3)
	bitesize = 3

/obj/item/reagent_containers/food/delightsalad
	name = "Delight salad"
	desc = "Truly citrus delight."
	icon_state = "delightsalad"
	trash = /obj/item/trash/dish/bowl
	center_of_mass = "x=15;y=15"
	nutriment_amt = 3
	startswith = list(
		/datum/reagent/drink/juice/lime = 4,
		/datum/reagent/drink/juice/lemon = 4,
		/datum/reagent/drink/juice/orange = 4)
	bitesize = 4

/obj/item/reagent_containers/food/chowmein
	name = "Chowmein"
	desc = "Nihao!"
	icon_state = "chowmein"
	trash = /obj/item/trash/dish/plate
	center_of_mass = "x=15;y=15"
	nutriment_amt = 6
	startswith = list(/datum/reagent/nutriment/protein = 6)
	bitesize = 3

/obj/item/reagent_containers/food/beefnoodles
	name = "Beef noodles"
	desc = "So simple, but so yummy!"
	icon_state = "beefnoodles"
	trash = /obj/item/trash/dish/bowl
	center_of_mass = "x=15;y=15"
	nutriment_amt = 4
	startswith = list(/datum/reagent/nutriment/protein = 7)
	bitesize = 2

/obj/item/reagent_containers/food/tortilla
	name = "Tortilla"
	desc = "Hasta la vista, baby"
	icon_state = "tortilla"
	center_of_mass = "x=15;y=15"
	nutriment_amt = 4
	bitesize = 2

/obj/item/reagent_containers/food/nachos
	name = "Nachos"
	desc = "Hola!"
	icon_state = "nachos"
	trash = /obj/item/trash/dish/plate
	center_of_mass = "x=15;y=15"
	nutriment_amt = 5
	startswith = list(
		/datum/reagent/sodiumchloride = 1)
	bitesize = 3

/obj/item/reagent_containers/food/cheesenachos
	name = "Cheese nachos"
	desc = "Cheese hola!"
	icon_state = "cheesenachos"
	trash = /obj/item/trash/dish/plate
	center_of_mass = "x=15;y=15"
	nutriment_amt = 7
	startswith = list(/datum/reagent/sodiumchloride = 1)
	bitesize = 4

/obj/item/reagent_containers/food/cubannachos
	name = "Cuban nachos"
	desc = "Very hot hola!"
	icon_state = "cubannachos"
	trash = /obj/item/trash/dish/plate
	center_of_mass = "x=15;y=15"
	nutriment_amt = 7
	startswith = list(
		/datum/reagent/sodiumchloride = 1,
		/datum/reagent/capsaicin = 3)
	bitesize = 4

/obj/item/reagent_containers/food/eggwrap
	name = "Egg Wrap"
	desc = "Eggs, cabbage, and soy. Interesting."
	icon_state = "eggwrap"
	center_of_mass = "x=15;y=15"
	nutriment_amt = 5
	startswith = list(/datum/reagent/nutriment/soysauce = 10)
	bitesize = 4

/obj/item/reagent_containers/food/cheeseburrito
	name = "Cheese burrito"
	desc = "Is it really necessary to say something here?"
	icon_state = "cheeseburrito"
	center_of_mass = "x=15;y=15"
	nutriment_amt = 10
	startswith = list(/datum/reagent/nutriment/soysauce = 2)
	bitesize = 4

/obj/item/reagent_containers/food/sundae
	name = "Sundae"
	desc = "Creamy satisfaction"
	icon_state = "sundae"
	center_of_mass = "x=15;y=15"
	nutriment_amt = 4
	startswith = list(
		/datum/reagent/drink/juice/banana = 4,
		/datum/reagent/drink/milk/cream = 3)
	bitesize = 5

/obj/item/reagent_containers/food/burrito
	name = "Burrito"
	desc = "Some really tasty."
	icon_state = "burrito"
	center_of_mass = "x=15;y=15"
	nutriment_amt = 8
	startswith = list(
		/datum/reagent/nutriment/soysauce = 2)
	bitesize = 4

/obj/item/reagent_containers/food/carnaburrito
	name = "Carna de Asada burrito"
	desc = "Like a classical burrito, but with some meat."
	icon_state = "carnaburrito"
	center_of_mass = "x=15;y=15"
	nutriment_amt = 8
	startswith = list(
		/datum/reagent/nutriment/protein = 3,
		/datum/reagent/nutriment/soysauce = 1)
	bitesize = 4

/obj/item/reagent_containers/food/plasmaburrito
	name = "Fuego Plasma Burrito"
	desc = "Very hot, amigos."
	icon_state = "plasmaburrito"
	center_of_mass = "x=15;y=15"
	nutriment_amt = 8
	startswith = list(/datum/reagent/capsaicin = 4)
	bitesize = 4

/obj/item/reagent_containers/food/risotto
	name = "Risotto"
	desc = "An offer you daga kotowaru."
	icon_state = "risotto"
	center_of_mass = "x=15;y=15"
	nutriment_amt = 5
	startswith = list(
		/datum/reagent/ethanol/wine = 5)
	bitesize = 3

/obj/item/reagent_containers/food/bruschetta
	name = "Bruschetta"
	desc = "..."
	icon_state = "bruschetta"
	trash = /obj/item/trash/dish/plate
	center_of_mass = "x=15;y=15"
	nutriment_amt = 6
	startswith = list(
		/datum/reagent/sodiumchloride = 2,
		/datum/reagent/drink/juice/tomato = 2,
		/datum/reagent/drink/juice/garlic = 1)
	bitesize = 4

/obj/item/reagent_containers/food/quiche
	name = "Quiche"
	desc = "Makes you feel more intelligent. Give to lower lifeforms!"
	icon_state = "quiche"
	trash = /obj/item/trash/dish/plate
	center_of_mass = "x=15;y=15"
	nutriment_amt = 9
	startswith = list(
		/datum/reagent/drink/juice/tomato = 2,
		/datum/reagent/drink/juice/garlic = 1)
	bitesize = 4

/obj/item/reagent_containers/food/lasagna
	name = "Lasagna"
	desc = "You can hide a bomb in the lasagna"
	icon_state = "lasagna"
	center_of_mass = "x=15;y=15"
	nutriment_amt = 10
	startswith = list(
		/datum/reagent/nutriment/protein = 4,
		/datum/reagent/drink/juice/tomato = 5)
	bitesize = 4

/obj/item/reagent_containers/food/cream_puff
	name = "Cream Puff"
	desc = "Goes well before a workout. Goes even better after a workout. And most importantly, it's highkey perfect DURING a workout."
	icon_state = "cream_puff"
	filling_color = "#FFE6A3"
	center_of_mass = "x=17;y=14"
	startswith = list(/datum/reagent/nutriment/magical_custard = 6)
	bitesize = 2

/obj/item/reagent_containers/food/tortilla
	name = "tortilla"
	desc = "The foldable possiblites are endless, as long as it's less than seven folds."
	icon_state = "tortilla"
	bitesize = 2
	center_of_mass = list("x"=21, "y"=12)
	nutriment_desc = list("taco shell" = 2)
	nutriment_amt = 2
	matter = list(MATERIAL_BIOMATTER = 5)

/obj/item/reagent_containers/food/medialuna
	name = "croissant"
	desc = "A flakey, buttery pastry shaped like a crescent moon. Soft and fluffy on the inside, crunchy on the outside, makes a perfect pair with a good cup of espresso."
	icon_state = "medialuna"
	bitesize = 3
	nutriment_amt = 6
	nutriment_desc = list("crunchy pastry" = 5, "buttery goodness" = 5)

/obj/item/reagent_containers/food/blt
	name = "BLT"
	desc = "A classic sandwich composed of nothing more than bacon, lettuce and tomato."
	icon_state = "blt"
	bitesize = 2
	nutriment_desc = list("toasted bread" = 3, "bacon" = 3, "tomato" = 2)
	nutriment_amt = 3

/obj/item/reagent_containers/food/boiledslimecore
	name = "boiled slime core"
	desc = "A boiled red thing."
	icon_state = "boiledrorocore" // Fix'd
	bitesize = 3
	startswith = list(/datum/reagent/metroidjelly = 5)
	matter = list(MATERIAL_BIOMATTER = 33)

/obj/item/reagent_containers/food/bearchili
	name = "bear meat chili"
	desc = "A chili so manly you'll end up growing hair on your chest and wrestling Renders with your bare hands."
	icon_state = "bearchili"
	nutriment_desc = list("manliest meat" = 10, "hot chili peppers" = 3)
	nutriment_amt = 3
	trash = /obj/item/trash/dish/bowl
	bitesize = 5
	startswith = list(/datum/reagent/nutriment/protein = 12, /datum/reagent/capsaicin = 3, /datum/reagent/hyperzine = 5)

/obj/item/reagent_containers/food/beefcurry
	name = "beef curry"
	desc = "A piping hot plate of spicy beef curry atop fluffy, steamed white rice."
	icon_state = "beefcurry"
	trash = /obj/item/trash/dish/bowl
	bitesize = 4
	startswith = list(/datum/reagent/nutriment/protein = 8, /datum/reagent/capsaicin = 5)
	nutriment_desc = list("beef" = 5, "curry" = 5, "spicyness" = 2)

/obj/item/reagent_containers/food/chickencurry
	name = "poultry curry"
	desc = "A piping hot plate of spicy poultry curry atop fluffy, steamed white rice."
	icon_state = "chickencurry"
	trash = /obj/item/trash/dish/bowl
	bitesize = 4
	startswith = list(/datum/reagent/nutriment/protein = 8, /datum/reagent/capsaicin = 5)
	nutriment_desc = list("chicken" = 5, "curry" = 5, "spicyness" = 2)

/obj/item/reagent_containers/food/mashpotatoes
	name = "mashed potatoes"
	desc = "Soft and fluffy mashed potatoes, the perfect side dish for a variety of meats."
	icon_state = "mashpotatoes"
	trash = /obj/item/trash/dish/plate
	bitesize = 4
	nutriment_amt = 8
	nutriment_desc = list("mashed potatoes" = 5, "butter" = 2)
	matter = list(MATERIAL_BIOMATTER = 8)
