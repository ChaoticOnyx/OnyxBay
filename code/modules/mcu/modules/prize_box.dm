/obj/item/mcu_module/prize_box
	name = "prize box module"
	desc = "A module that may dispatch prizes."
	icon_state = "prizebox"

	device_type = Z_DEVICE_TYPE_PRIZE_BOX

	/// Weighted list of prizes.
	var/list/prizes = list()
	var/prizes_left = 0

/obj/item/mcu_module/prize_box/__syscall(cmd, ...)
	var/obj/item/device/mcu/M = __host.resolve()
	ASSERT(Z_MACHINE_APPEND_COUNTERS(M.id, 0, 1000, 0))

	switch(cmd)
		if(Z_PRIZE_BOX_N2B_CMD_VEND)
			// is_ready and is_empty checked underhood, so it should succeed always
			ASSERT(dispatch() == TRUE)

			set_next_think(world.time + config.mcu.prize_box_cooldown)
			ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_PRIZE_BOX_B2N_CMD_READY_STATUS, FALSE) == TRUE)

			return TRUE
	
	return FALSE

/obj/item/mcu_module/prize_box/proc/dispatch()
	if(length(prizes) == 0 || prizes_left == 0)
		return FALSE

	var/type_selected = util_pick_weight(prizes)
	new type_selected(get_turf(src))

	prizes_left -= 1

	if(prizes_left > 0)
		return TRUE
	
	if(__host != null)
		var/obj/item/device/mcu/M = __host.resolve()
		ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_PRIZE_BOX_B2N_CMD_IS_EMPTY, TRUE) == TRUE)

	return TRUE

/obj/item/mcu_module/prize_box/think()
	var/obj/item/device/mcu/M = __host.resolve()

	if(QDELETED(M))
		return

	ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_PRIZE_BOX_B2N_CMD_READY_STATUS, TRUE) == TRUE)

	return

/obj/item/mcu_module/prize_box/__reset(attached)
	set_next_think(0)

	if(!attached)
		return

	var/obj/item/device/mcu/M = __host.resolve()
	ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_PRIZE_BOX_B2N_CMD_READY_STATUS, TRUE) == TRUE)
	ASSERT(Z_MACHINE_SYSCALL(M.id, __pci_slot, Z_PRIZE_BOX_B2N_CMD_IS_EMPTY, prizes_left <= 0) == TRUE)

// Presets

/obj/item/mcu_module/prize_box/preset/arcade
	prizes = list(
		/obj/item/storage/box/snappops					= 2,
		/obj/item/toy/blink								= 2,
		/obj/item/clothing/under/syndicate/tacticool	= 2,
		/obj/item/toy/sword								= 2,
		/obj/item/gun/projectile/revolver/capgun		= 2,
		/obj/item/toy/crossbow							= 2,
		/obj/item/clothing/suit/syndicatefake			= 2,
		/obj/item/storage/fancy/crayons					= 2,
		/obj/item/toy/spinningtoy						= 2,
		/obj/item/toy/prize/ripley						= 1,
		/obj/item/toy/prize/fireripley					= 1,
		/obj/item/toy/prize/deathripley					= 1,
		/obj/item/toy/prize/gygax						= 1,
		/obj/item/toy/prize/durand						= 1,
		/obj/item/toy/prize/honk						= 1,
		/obj/item/toy/prize/marauder					= 1,
		/obj/item/toy/prize/seraph						= 1,
		/obj/item/toy/prize/mauler						= 1,
		/obj/item/toy/prize/odysseus					= 1,
		/obj/item/toy/prize/phazon						= 1,
		/obj/item/reagent_containers/spray/waterflower	= 1,
		/obj/random/action_figure						= 1,
		/obj/random/plushie								= 1,
		/obj/item/toy/cultsword							= 1
	)
	prizes_left = 10
