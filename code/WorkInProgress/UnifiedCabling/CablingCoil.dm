// =
// = The Unified(-Type-Tree) Cable Network System
// = Written by Sukasa with assistance from Googolplexed
// =
// = Cleans up the type tree and reduces future code maintenance
// = Also makes it easy to add new cable & network types
// =

// Unified Cable Network System - Generic Cable Coil Class

/obj/item/weapon/CableCoil
	icon_state     = "whitecoil3"
	icon           = 'Coils.dmi'
	flags          = TABLEPASS | USEDELAY | FPRINT | CONDUCT
	throwforce     = 10
	w_class        = 1.5
	throw_speed    = 2
	throw_range    = 5
	item_state     = ""

	var/CoilColour = "generic"
	var/BaseName   = "Generic"
	var/ShortDesc  = "A piece of Generic Cable"
	var/LongDesc   = "A long piece of Generic Cable"
	var/CoilDesc   = "A Spool of Generic Cable"
	var/MaxAmount  = 30
	var/Amount     = 30
	var/CableType  = /obj/cabling
	var/CanLayDiagonally = 1

/obj/item/weapon/CableCoil/New(var/Location, var/Length)
	if(!Length)
		Length = MaxAmount
	Amount = Length
	item_state     = "[CoilColour]coil"
	icon_state     = "[CoilColour]coil"
	pixel_x = rand(-4,4)
	pixel_y = rand(-4,4)
	UpdateIcon()
	name = "[BaseName] Cable"
	..(Location)

/obj/item/weapon/CableCoil/proc/UpdateIcon()
	if(Amount == 1)
		icon_state = "[CoilColour]coil1"
		item_state = "[CoilColour]coil1"
	else if(Amount == 2)
		icon_state = "[CoilColour]coil2"
		item_state = "[CoilColour]coil2"
	else
		icon_state = "[CoilColour]coil3"
		item_state = "[CoilColour]coil3"

/obj/item/weapon/CableCoil/examine()

	if (Amount == 1)
		usr << ShortDesc
	else if(Amount == 2)
		usr << LongDesc
	else
		usr << CoilDesc
		usr << "There are [Amount] usable lengths on the spool"

/obj/item/weapon/CableCoil/attackby(obj/item/weapon/W, mob/user)
	if( istype(W, /obj/item/weapon/wirecutters) && Amount > 2)
		Amount--
		new/obj/item/weapon/CableCoil(user.loc, 1)
		user << "You cut a length off the [name]."
		UpdateIcon()
		return

	else if( istype(W, /obj/item/weapon/CableCoil) )
		var/obj/item/weapon/CableCoil/C = W
		if (C.CableType != CableType)
			user << "You can't combine different kinds of cabling!"
			return

		if(C.Amount == 30)
			user << "The coil is too long, you cannot add any more cable to it."
			return

		if( (C.Amount + Amount <= 30) )
			C.Amount += Amount
			user << "You join the [name]s together."
			C.UpdateIcon()
			del src
			return

		else
			user << "You transfer [30 - Amount] lengths of cable from one coil to the other."
			Amount -= (30-C.Amount)
			UpdateIcon()
			C.Amount = 30
			C.UpdateIcon()
			return

/obj/item/weapon/CableCoil/proc/UseCable(var/used)
	if(Amount < used)
		return 0
	else if (Amount == used)
		del src
		return 1
	else
		Amount -= used
		UpdateIcon()
		return 1

/obj/item/weapon/CableCoil/proc/LayOnTurf(turf/simulated/floor/Target, mob/user)

	if(!isturf(user.loc))
		return

	if(get_dist(Target,user) > 1)
		user << "You can't lay cable at a place that far away."
		return

	if(Target.intact)
		user << "You can't lay cable there unless the floor tiles are removed."
		return

	else
		var/NewDirection

		if(user.loc == Target)
			NewDirection = user.dir
		else
			NewDirection = get_dir(Target, user)

		if(!CanLayDiagonally && (NewDirection & NewDirection - 1))
			user << "This type of cable cannot be laid diagonally."
			return

		var/obj/cabling/Cable = new CableType(null)

		for(var/obj/cabling/ExistingCable in Target)
			if((ExistingCable.Direction1 == NewDirection || ExistingCable.Direction2 == NewDirection) && ExistingCable.EquivalentCableType == Cable.EquivalentCableType)
				user << "There's already a cable at that position."
				del Cable
				return

		del Cable

		var/obj/cabling/NewCable = new CableType(Target)
		NewCable.Direction1 = 0
		NewCable.Direction2 = NewDirection
		NewCable.add_fingerprint(user)
		NewCable.UpdateIcon()
		UseCable(1)

/obj/item/weapon/CableCoil/proc/JoinCable(obj/cabling/Cable, mob/user)


	var/turf/UserLocation = user.loc

	if(!isturf(UserLocation))
		return
	var/turf/CableLocation = Cable.loc

	if(!isturf(CableLocation) || CableLocation.intact)
		return
	if(get_dist(Cable, user) > 1)
		user << "You can't lay cable at a place that far away."
		return

	if(UserLocation == CableLocation)
		return

	var/DirectionToUser = get_dir(Cable, user)

	if(!CanLayDiagonally && (DirectionToUser & DirectionToUser - 1))
		user << "This type of cable cannot be laid diagonally."
		return

	if(Cable.Direction1 == DirectionToUser || Cable.Direction2 == DirectionToUser)
		if(UserLocation.intact)
			user << "You can't lay cable there unless the floor tiles are removed."
			return

		var/DirectionToCable = reverse_dir_3d(DirectionToUser)

		for(var/obj/cabling/UnifiedCable in UserLocation)
			if((UnifiedCable.Direction1 == DirectionToCable || UnifiedCable.Direction2 == DirectionToCable) && UnifiedCable.EquivalentCableType == Cable.EquivalentCableType)
				user << "There's already a [Cable.name] at that position."
				return

		var/obj/cabling/NewCable = new CableType(CableLocation, 0, DirectionToCable)
		NewCable.add_fingerprint(user)
		NewCable.UserTouched(user)
		NewCable.UpdateIcon()
		UseCable(1)

	else if(Cable.Direction1 == 0)
		var/NewDirection1 = Cable.Direction2
		var/NewDirection2 = DirectionToUser

		if(NewDirection1 > NewDirection2)
			NewDirection1 = DirectionToUser
			NewDirection2 = Cable.Direction2

		for(var/obj/cabling/ExistingCable in CableLocation)
			if(ExistingCable == Cable || ExistingCable.EquivalentCableType != Cable.EquivalentCableType)
				continue
			if((ExistingCable.Direction1 == NewDirection1 && ExistingCable.Direction2 == NewDirection2) || (ExistingCable.Direction1 == NewDirection2 && ExistingCable.Direction2 == NewDirection1) )	// make sure no cable matches either direction
				user << "There's already a [Cable.name] at that position."
				return

		var/obj/cabling/NewCable = new CableType(CableLocation, NewDirection1, NewDirection2)
		NewCable.add_fingerprint(user)
		NewCable.UserTouched(user)
		NewCable.UpdateIcon()

		del Cable

		UseCable(1)

	return

/obj/item/weapon/CableCoil/afterattack(var/atom/Target, var/mob/User, var/Flag)
	var/obj/cabling/Cable = new CableType(null)

	if (!Cable.CanConnect(Target))
		del Cable
		return


	var/turf/CableLocation = get_turf(Target)

	if(CableLocation.intact || !istype(CableLocation, /turf/simulated/floor))
		return

	if(get_dist(Target, User) > 1)
		return

	var/DirectionToUser = get_dir(Target, User)

	for(var/obj/cabling/ExistingCable in CableLocation)
		if((ExistingCable.Direction1 == DirectionToUser || ExistingCable.Direction2 == DirectionToUser) && ExistingCable.EquivalentCableType == Cable.EquivalentCableType)
			User << "There's already a cable at that position."
			return

	var/obj/cabling/NewCable = new CableType(CableLocation, 0, DirectionToUser)
	NewCable.add_fingerprint(User)
	NewCable.UserTouched(User)
	NewCable.UpdateIcon()
	UseCable(1)
	del Cable

	..()
	return