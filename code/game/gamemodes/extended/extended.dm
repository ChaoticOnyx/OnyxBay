/datum/game_mode/extended
	name = "Extended Role-Playing"
	config_tag = "extended"
	uplink_welcome = "Syndicate Uplink Console:"
	uplink_items = {"/obj/item/weapon/storage/syndie_kit/imp_freedom (3);/obj/item/weapon/storage/syndie_kit/imp_compress (5);/obj/item/weapon/storage/syndie_kit/imp_vfac (5);
/obj/item/weapon/storage/syndie_kit/imp_explosive (6);/obj/item/device/hacktool (4);
/obj/item/clothing/under/chameleon (3);/obj/item/weapon/gun/revolver (7);
/obj/item/weapon/ammo/a357 (3);/obj/item/weapon/card/emag (3);
/obj/item/weapon/card/id/syndicate (3);/obj/item/weapon/cloaking_device (5);
/obj/item/weapon/storage/emp_kit (4);/obj/item/device/powersink (5);
/obj/item/weapon/cartridge/syndicate (3);/obj/item/device/chameleon (4);
/obj/item/weapon/sword (5);/obj/item/weapon/pen/sleepypen (4);
/obj/item/weapon/gun/energy/crossbow (5);/obj/spawner/newbomb/timer/syndicate (4);
/obj/item/clothing/mask/gas/voice (3);/obj/item/weapon/aiModule/freeform (3)"}

	uplink_uses = 10

/datum/game_mode/extended/announce()
	..()
	world << "<B>Just have fun and role-play!</B>"

/datum/game_mode/extended/process()
	if (blobs.len > 0)
		for (var/i = 1 to 25)
			if (blobs.len == 0)
				break

			var/obj/blob/B = pick(blobs)
			if(B.z != 1)
				continue

			for (var/atom/A in B.loc)
				A.blob_act()

			B.Life()
