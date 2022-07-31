/*********************
* Job-specific Items *
*********************/
/datum/uplink_item/item/job
	category = /datum/uplink_category/job

/datum/uplink_item/item/job/butch
	name = "Meat Cleaver"
	desc = "Looks almost like a regular cleaver, but is even more robust and capable of chopping dead bodies into meat slabs."
	item_cost = 5
	job_specific = list("Chef")
	path = /obj/item/material/knife/butch/kitchen/syndie

/datum/uplink_item/item/job/mimesword
	name = "Baguette Sword"
	desc = "A sword made from a baguette. It's not very sharp, but it's still a good weapon. You can sharpen it, if you are brave enough."
	item_cost = 4
	job_specific = list("Mime")
	path = /obj/item/melee/mimesword

/datum/uplink_item/item/job/lubeshoes
	name = "Lube Shoes Honk Edition"
	desc = "A pair of clown shoes, which can sometimes spill lube on floor. Slippery!"
	item_cost = 4
	job_specific = list("Clown")
	path = /obj/item/clothing/shoes/clown_shoes/traitorshoes

/datum/uplink_item/item/job/vuvuzela 
	name = "Vuvuzela"
	desc = "A very loud vuvuzela. It's loud enough to make you and all around you deaf."
	item_cost = 2
	job_specific = list("Clown")
	path = /obj/item/bikehorn/vuvuzela/traitor 

/datum/uplink_item/item/job/empty_grenades
	name = "Empty Grenades"
	desc = "A box of empty grenades. For your little experiments."
	item_cost = 2
	job_specific = list("Chief Medical Officer", "Chemist")
	path = /obj/item/storage/box/syndie_kit/empty_grenades

/datum/uplink_item/item/job/random_gland
	name = "Random mutated organ."
	desc = "A box with a special organ inside. Just put it inside someone, and see, what it does!"
	item_cost = 5
	job_specific = list("Chief Medical Officer", "Medical Doctor")
	path = /obj/item/storage/box/syndie_kit/gland

/datum/uplink_item/item/job/strange_seeds
	name = "Strange Seeds"
	desc = "A box of strange seeds. Just put it in tray and watch something horrible grow."
	item_cost = 2
	job_specific = list("Xenobotanist", "Gardener")
	path = /obj/item/storage/box/syndie_kit/strange_seeds

/datum/uplink_item/item/job/applenades
	name = "Box of applenades"
	desc = "A box of grenades, that look like apples. Comes with water-pottasium sollution, but you can experiment and change reaction!"
	item_cost = 5
	job_specific = list("Xenobotanist", "Gardener")
	path = /obj/item/storage/box/syndie_kit/applenades
