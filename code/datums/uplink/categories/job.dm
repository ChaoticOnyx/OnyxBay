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
