/obj/item/weapon/disk
	name = "disk"
	icon = 'items.dmi'
	w_class = 1.0


/obj/item/weapon/disk/data
	name = "data disk"
	//icon = "items.dmi" // to change
	//icon_state = "datadisk0" //to change. maybe make a new icon
	item_state = "card-id"
	var/data = ""
	var/data_type = ""
	var/read_only = 0 //Well,it's still a floppy disk

/obj/item/weapon/disk/data/attack_self(mob/user as mob)
	src.read_only = !src.read_only
	user << "You flip the write-protect tab to [src.read_only ? "protected" : "unprotected"]."

/obj/item/weapon/disk/data/examine()
	set src in oview(5)
	..()
	usr << text("The write-protect tab is set to [src.read_only ? "protected" : "unprotected"].")
	return


/obj/item/weapon/disk/data/genetics
	name = "genetics data disk"
	icon = 'cloning.dmi'
	icon_state = "datadisk0" //Gosh I hope syndies don't mistake them for the nuke disk.
	var/ue = 0
	data_type = "ui" //ui|se
	var/owner = "Farmer Jeff "

/obj/item/weapon/disk/data/genetics/New()
	..()
	var/diskcolor = pick(0,1,2)
	src.icon_state = "datadisk[diskcolor]"


/obj/item/weapon/disk/nuclear
	name = "Nuclear Authentication Disk"
	icon_state = "nucleardisk"
	item_state = "card-id"