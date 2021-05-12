/decl/prefab/ic_assembly/hand_teleporter
	assembly_name = "hand-teleporter"
	assembly_icon = 'icons/obj/device.dmi'
	assembly_icon_state = "hand_tele"
	assembly_w_class = ITEM_SIZE_SMALL
	data = {"{'assembly':{'type':'type-c electronic machine','name':'Hand Teleporter'},'components':\[{'type':'button','name':'Open RIft'},{'type':'teleporter locator'},{'type':'bluespace rift generator'}],'wires':\[\[\[1,'A',1],\[3,'A',1]],\[\[2,'O',1],\[3,'I',1]]]}"}
	power_cell_type = /obj/item/weapon/cell/hyper

/obj/prefab/hand_teleporter
	name = "hand teleporter"
	prefab_type = /decl/prefab/ic_assembly/hand_teleporter
