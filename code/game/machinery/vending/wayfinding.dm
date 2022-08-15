/obj/machinery/vending/wayfinding
	name = "wayfinding pinpointer vending machine"
	desc = "A machine given the thankless job of trying to give wayfinding pinpointers. They point to common locations."
	icon_state = "cart"
	use_vend_state = TRUE
	vend_delay = 23 SECONDS
	slogan_list = list("Find a wayfinding pinpointer? Give it to me! I'll make it worth your while. Please. Daddy needs his medicine.", //last sentence is a reference to Sealab 2021
						"See a wayfinding pinpointer? Don't let it go to the crusher! Recycle it with me instead. I'll pay you or not.", //I see these things heading for disposals through cargo all the time
						"Can't find the disk? Need a pinpointer? Buy a wayfinding pinpointer and find the captain's office today!",
						"Bleeding to death? Can't read? Find your way to medbay today!", //there are signs that point to medbay but you need basic literacy to get the most out of them
						"Voted tenth best pinpointer in the universe in 2560!", //there were no more than ten pinpointers in the game in 2020
						"Helping assistants find the departments they tide since 2560.", //not really but it's advertising
						"These pinpointers are flying out the airlock!", //because they're being thrown into space
						"Grey pinpointers for the grey tide!", //I didn't pick the colour but it works
						"Feeling lost? Find direction.",
						"Automate your sense of direction. Buy a wayfinding pinpointer today!",
						"Feed me a stray pinpointer.", //American Psycho reference
						"We need a slogan!") //Liberal Crime Squad reference
    component_types = list(/obj/item/vending_cartridge/wayfinding)
	legal = list(/obj/item/pinpointer/wayfinding = 10)

/obj/item/vending_cartridge/wayfinding
    name = "wayfinding"
    build_path = /obj/machinery/vending/wayfinding
