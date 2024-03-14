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

/datum/uplink_item/item/job/meathook
	name = "Meat Hook"
	desc = "A high-tech version of an ancient assassin weapon, disguised as a meat hook. It can be thrown with an incredible accuracy, and will snag the first target it encounters, dragging it back to you. However, all the witnesses will know for sure that you're up for something."
	item_cost = 4
	job_specific = list("Chef")
	path = /obj/item/gun/meathook
