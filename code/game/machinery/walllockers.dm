/obj/machinery/walllocker
	name = "Wall Locker"
	icon = 'lockwall.dmi'
	icon_state = "emerg"
	var/list/spawnitems = list()
	var/ammount = 3 // spawns each items X times.
/obj/machinery/walllocker/attack_hand()
	if(!ammount)
		usr << "It's eampty.."
		return
	if(ammount)
		for(var/path in spawnitems)
			new path(src.loc)
		ammount--
	return
/obj/machinery/walllocker/emerglocker
	name = "Emergency Locker"
	spawnitems = list(/obj/item/weapon/tank/emergency_oxygen,/obj/item/clothing/mask/breath,/obj/item/weapon/crowbar)




