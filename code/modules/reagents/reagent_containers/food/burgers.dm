
/obj/item/reagent_containers/food/plainburger
	name = "burger"
	desc = "The cornerstone of every nutritious breakfast."
	icon_state = "hburger"
	filling_color = "#d63c3c"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("fast food" = 3)
	nutriment_amt = 120
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 30,
		/datum/reagent/nutriment/protein/cooked = 50
		)
	bitesize = 25 // 320 nutrition, 8 bites

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

/obj/item/reagent_containers/food/brainburger
	name = "brainburger"
	desc = "A strange looking burger. It looks almost sentient."
	icon_state = "brainburger"
	filling_color = "#f2b6ea"
	center_of_mass = "x=15;y=11"
	nutriment_desc = list("illithid fast food" = 3)
	nutriment_amt = 120
	startswith = list(
		/datum/reagent/alkysine = 6,
		/datum/reagent/nutriment/protein/gluten/cooked = 30
		)
	bitesize = 25 // 195 nutrition and whatever comes with the brain.

/obj/item/reagent_containers/food/ghostburger
	name = "Ghost Burger"
	desc = "Spooky! It doesn't look very filling."
	icon_state = "ghostburger"
	filling_color = "#fff2ff"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("spooky fast food" = 3)
	nutriment_amt = 120
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 30,
		/datum/reagent/drink/nothing = 50
		)
	bitesize = 25 // 195 nutrition, 8 bites

/obj/item/reagent_containers/food/human
	var/hname = ""
	var/job = null
	filling_color = "#d63c3c"

/obj/item/reagent_containers/food/human/burger
	name = "-burger"
	desc = "A bloody burger."
	icon_state = "hburger"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("humanity" = 2, "fast food" = 3)
	nutriment_amt = 120
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 30
		)
	bitesize = 25 // 195 nutrition and whatever comes with the hooman.

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

/obj/item/reagent_containers/food/cheeseburger
	name = "cheeseburger"
	desc = "The cheese adds a good flavor."
	icon_state = "cheeseburger"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("cheese" = 2, "fast food" = 2)
	nutriment_amt = 160
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 30,
		/datum/reagent/nutriment/protein/cooked = 60
		)
	bitesize = 25 // 385 nutrition, 10 bites

/obj/item/reagent_containers/food/fishburger
	name = "Fillet -o- Carp Sandwich"
	desc = "Almost like a carp is yelling somewhere... Give me back that fillet -o- carp, give me that carp."
	icon_state = "fishburger"
	filling_color = "#ffdefe"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("fishy fast food" = 3)
	nutriment_amt = 120
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 30,
		/datum/reagent/nutriment/protein/cooked = 50
		)
	bitesize = 25 // 320 nutrition, 8 bites

/obj/item/reagent_containers/food/tofuburger
	name = "Tofu Burger"
	desc = "What.. is that meat?"
	icon_state = "tofuburger"
	filling_color = "#fffee0"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("tofu" = 2, "fake fast food" = 2)
	nutriment_amt = 195
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 30
		)
	bitesize = 25 // 270 nutrition, 9 bites

/obj/item/reagent_containers/food/roburger
	name = "cyburger"
	desc = "The lettuce is the only organic component. Beep."
	icon_state = "roburger"
	filling_color = "#cccccc"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("nanomachines' son" = 1, "cybernetic fast food" = 2)
	nutriment_amt = 120
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 30,
		/datum/reagent/iron = 30
		)
	bitesize = 20 // 320 nutrition, 9 bites

/obj/item/reagent_containers/food/roburger/Initialize()
	. = ..()
	if(prob(5))
		reagents.add_reagent(/datum/reagent/nanites, 10)

/obj/item/reagent_containers/food/roburgerbig
	name = "roburger"
	desc = "This massive patty looks like poison. Beep."
	icon_state = "roburger"
	filling_color = "#cccccc"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("nanomachines' son" = 5)
	nutriment_amt = 40
	startswith = list(
		/datum/reagent/nanites = 100,
		/datum/reagent/iron = 60
		)
	bitesize = 10 // 40 nutrition, 20 bites

/obj/item/reagent_containers/food/xenoburger
	name = "xenoburger"
	desc = "Smells caustic. Tastes like heresy."
	icon_state = "xburger"
	filling_color = "#43de18"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("heresy" = 2, "fast food" = 2)
	nutriment_amt = 120
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 30,
		/datum/reagent/nutriment/protein/cooked = 40,
		/datum/reagent/xenomicrobes = 10
		)
	bitesize = 25 // 295 nutrition, 8 bites

/obj/item/reagent_containers/food/clownburger
	name = "Clown Burger"
	desc = "This tastes funny..."
	icon_state = "clownburger"
	filling_color = "#ff00ff"
	center_of_mass = "x=17;y=12"
	nutriment_desc = list("pun" = 1, "bun" = 1, "clown shoe" = 1, "fast food" = 1)
	nutriment_amt = 195
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 30
		)
	bitesize = 25 // 270 nutrition, 9 bites

/obj/item/reagent_containers/food/mimeburger
	name = "Mime Burger"
	desc = "Its taste defies language."
	icon_state = "mimeburger"
	filling_color = "#ffffff"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("pantomime" = 2, "silence" = 2, "mime paint" = 2, "fast food" = 2)
	nutriment_amt = 50
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 30,
		/datum/reagent/drink/nothing = 120
		)
	bitesize = 1 // 125 nutrition, 200 bites

/obj/item/reagent_containers/food/spellburger
	name = "Spell Burger"
	desc = "This is absolutely Ei Nath."
	icon_state = "spellburger"
	filling_color = "#d505ff"
	nutriment_desc = list("magic" = 2, "fast food" = 2)
	nutriment_amt = 195
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 30
		)
	bitesize = 25 // 270 nutrition, 9 bites

/obj/item/reagent_containers/food/bigbiteburger
	name = "Big Bite Burger"
	desc = "Forget the Big Mac. THIS is the future!"
	icon_state = "bigbiteburger"
	filling_color = "#e3d681"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("jaw dislocation" = 5, "fast food" = 3)
	nutriment_amt = 120
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 30,
		/datum/reagent/nutriment/protein/cooked = 500,
		/datum/reagent/nutriment/protein/egg/cooked = 45
		)
	bitesize = 25 // 1557.5 nutrition, 16 bites

/obj/item/reagent_containers/food/superbiteburger
	name = "Super Bite Burger"
	desc = "This is a mountain of a burger. FOOD!"
	icon_state = "superbiteburger"
	filling_color = "#cca26a"
	center_of_mass = "x=16;y=3"
	nutriment_desc = list("jaw fracture" = 5, "fast food" = 3)
	nutriment_amt = 280
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 60,
		/datum/reagent/nutriment/protein/cooked = 660,
		/datum/reagent/nutriment/protein/egg/cooked = 90
		)
	bitesize = 25 // 2305 nutrition, 32 bites

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


/obj/item/reagent_containers/food/hotdog
	name = "hotdog"
	desc = "Unrelated to dogs, maybe."
	icon_state = "hotdog"
	center_of_mass = "x=16;y=17"
	nutriment_desc = list("bread" = 3)
	nutriment_amt = 120
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 75,
		/datum/reagent/nutriment/protein/gluten/cooked = 30
		)
	bitesize = 30 // 382.5 nutrition, 8 bites

/obj/item/reagent_containers/food/classichotdog
	name = "classic hotdog"
	desc = "Going literal."
	icon_state = "hotcorgi"
	w_class = ITEM_SIZE_LARGE
	center_of_mass = "x=16;y=17"
	nutriment_amt = 120
	nutriment_desc = list("hot" = 2.5, "dog" = 2.5)
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 300,
		/datum/reagent/nutriment/protein/gluten/cooked = 30
		)
	bitesize = 30 // Whooping 945 nutrition (a whole Ian plus some bread), 15 bites
