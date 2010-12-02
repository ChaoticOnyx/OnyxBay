/obj/item/weapon/disk
	name = "Disk"
	icon = 'items.dmi'
	w_class = 1.0


/obj/item/weapon/disk/data
	name = "Data Disk"
	var/title = "Data Disk"
	icon_state = "datadisk0"
	item_state = "card-id"
	var/datum/computer/folder/root = null
	var/file_amount = 32.0
	var/file_used = 0.0
	var/data = ""
	var/data_type = ""
	var/read_only = 0
	var/portable = 1

/obj/item/weapon/disk/data/New()
	src.root = new /datum/computer/folder
	src.root.holder = src
	src.root.name = "root"

/obj/item/weapon/disk/data/attack_self(mob/user as mob)
	src.read_only = !src.read_only
	user << "You flip the write-protect tab to [src.read_only ? "protected" : "unprotected"]."

/obj/item/weapon/disk/data/examine()
	set src in oview(5)
	..()
	usr << text("The write-protect tab is set to [src.read_only ? "protected" : "unprotected"].")
	return


//TO DO: Look over this code. Something is fishy in it, possibly the way it stores the UI and the UE.
/obj/item/weapon/disk/data/genetics
	name = "Genetics Data Disk"
	icon_state = "datadiskgen0" //Gosh I hope syndies don't mistake them for the nuke disk.
	data_type = "ui"
	var/owner = ""
	var/ue = 0

/obj/item/weapon/disk/data/genetics/New()
	..()
	var/diskcolor = pick(0,1,2)
	src.icon_state = "datadiskgen[diskcolor]"


/obj/item/weapon/disk/data/fixed_disk
	name = "Storage Drive"
	icon_state = "harddisk"
	title = "Storage Drive"
	file_amount = 80.0
	portable = 0

	attack_self(mob/user as mob)
		return


/obj/item/weapon/disk/nuclear
	name = "Nuclear Authentication Disk"
	icon_state = "nucleardisk"
	item_state = "card-id"