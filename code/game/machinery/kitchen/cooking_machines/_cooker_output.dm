// Wrapper obj for cooked food. Appearance is set in the cooking code, not on spawn.
/obj/item/reagent_containers/food/variable
	name = "cooked food"
	icon = 'icons/obj/food_custom.dmi'
	desc = "If you can see this description then something is wrong. Please report the bug on the tracker."
	nutriment_amt = 5
	bitesize = 2

/obj/item/reagent_containers/food/variable/pizza
	name = "personal pizza"
	desc = "A personalized pan pizza meant for only one person."
	icon_state = "personal_pizza"

/obj/item/reagent_containers/food/sliceable/bread/variable
	icon = 'icons/obj/food_custom.dmi'
	name = "bread"
	desc = "Tasty bread."
	icon_state = "breadcustom"

/obj/item/reagent_containers/food/pie/variable
	icon = 'icons/obj/food_custom.dmi'
	name = "pie"
	desc = "Tasty pie."
	icon_state = "piecustom"

/obj/item/reagent_containers/food/sliceable/plaincake/variable
	icon = 'icons/obj/food_custom.dmi'
	name = "cake"
	desc = "A popular band."
	icon_state = "cakecustom"

/obj/item/reagent_containers/food/donkpocket/variable
	icon = 'icons/obj/food_custom.dmi'
	name = "hot pocket"
	desc = "You wanna put a bangin- oh, nevermind."
	icon_state = "donk"

/obj/item/reagent_containers/food/donkpocket/variable/Initialize()
	. = ..()
	heat()

/obj/item/reagent_containers/food/tofukabob/variable
	icon = 'icons/obj/food_custom.dmi'
	name = "kebab"
	desc = "Remove this!"
	icon_state = "kabob"
	nutriment_desc = list("metal" = 1)

/obj/item/reagent_containers/food/waffles/variable
	icon = 'icons/obj/food_custom.dmi'
	name = "waffles"
	desc = "Made with love."
	icon_state = "waffles"
	gender = PLURAL

/obj/item/reagent_containers/food/pancakes/variable
	icon = 'icons/obj/food_custom.dmi'
	name = "pancakes"
	desc = "How does an oven make pancakes?"
	icon_state = "pancakescustom"
	gender = PLURAL

/obj/item/reagent_containers/food/cookie/variable
	icon = 'icons/obj/food_custom.dmi'
	name = "cookie"
	desc = "Sugar snap!"
	icon_state = "cookie"

/obj/item/reagent_containers/food/donut/variable
	icon = 'icons/obj/food_custom.dmi'
	name = "filled donut"
	desc = "Donut eat this!" // kill me
	icon_state = "donut"

/obj/item/reagent_containers/food/variable/jawbreaker
	name = "flavored jawbreaker"
	desc = "It's like cracking a molar on a rainbow."
	icon_state = "jawbreaker"

/obj/item/reagent_containers/food/candy/variable
	icon = 'icons/obj/food_custom.dmi'
	name = "flavored chocolate bar"
	desc = "Made in a factory downtown."
	icon_state = "bar"

/obj/item/reagent_containers/food/variable/sucker
	name = "flavored sucker"
	desc = "Suck, suck, suck."
	icon_state = "sucker"

/obj/item/reagent_containers/food/variable/jelly
	name = "jelly"
	desc = "All your friends will be jelly."
	icon_state = "jellycustom"

/obj/item/reagent_containers/food/variable/cereal
	name = "cereal"
	desc = "Eat to become a cereal killer"
	icon_state = "cerealcustom"
