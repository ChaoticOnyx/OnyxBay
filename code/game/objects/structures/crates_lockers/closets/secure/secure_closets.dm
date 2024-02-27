/obj/structure/closet/secure_closet
	name = "secure locker"
	desc = "It's a card-locked storage unit."

	setup = CLOSET_HAS_LOCK | CLOSET_CAN_BE_WELDED
	locked = TRUE

	icon_state = "secure1"
	icon_closed = "secure"
	icon_locked = "secure1"
	icon_off = "secureoff"

	icon_opened = "secureopen"

	wall_mounted = 0 //never solid (You can always pass over it)
	health = 200

/obj/structure/closet/secure_closet/slice_into_parts(obj/item/weldingtool/WT, mob/user)
	to_chat(user, "<span class='notice'>\The [src] is too strong to be taken apart.</span>")

/obj/structure/closet/secure_closet/vault
	name = "secure locker"
	icon_state = "vault1"
	icon_closed = "vault"
	icon_locked = "vault1"
	icon_opened = "vaultopen"
	icon_off = "vaultoff"
	dremovable = FALSE
