/obj/item/weapon/storage/briefcase
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. Its owner must be a real professional."
	icon_state = "briefcase"
	item_state = "briefcase"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = ITEM_SIZE_HUGE
	mod_weight = 1.5
	mod_reach = 0.75
	mod_handy = 1.0
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = DEFAULT_BACKPACK_STORAGE

/obj/item/weapon/storage/briefcase/iaa
	startswith = list(/obj/item/weapon/paper/trade_lic/trade_guide,\
	/obj/item/weapon/folder/nt,\
	/obj/item/weapon/pen,\
	/obj/item/device/camera)
