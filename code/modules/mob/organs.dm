/datum/organ/proc/process()
	return

/datum/organ/proc/receive_chem(chemical as obj)
	return

/datum/organ/external/proc/take_damage(brute, burn)
	if ((brute <= 0 && burn <= 0))
		return 0
	if ((brute_dam + burn_dam + brute + burn) < max_damage)
		brute_dam += brute
		burn_dam += burn
	else
		var/can_inflict = max_damage - (brute_dam + burn_dam)
		if (can_inflict)
			if (brute > 0 && burn > 0)
				brute = can_inflict/2
				burn = can_inflict/2
				var/ratio = brute / (brute + burn)
				brute_dam += ratio * can_inflict
				burn_dam += (1 - ratio) * can_inflict
			else
				if (brute > 0)
					brute = can_inflict
					brute_dam += brute
				else
					burn = can_inflict
					burn_dam += burn
		else
			return 0

	var/result = update_icon()

	return result

/datum/organ/external/proc/heal_damage(brute, burn)
	brute_dam = max(0, brute_dam - brute)
	burn_dam = max(0, brute_dam - burn)
	return update_icon()

/datum/organ/external/proc/get_damage()	//returns total damage
	return brute_dam + burn_dam	//could use health?

// new damage icon system
// returns just the brute/burn damage code

/datum/organ/external/proc/damage_state_text()

	var/tburn = 0
	var/tbrute = 0

	if(burn_dam ==0)
		tburn =0
	else if (burn_dam < (max_damage * 0.25 / 2))
		tburn = 1
	else if (burn_dam < (max_damage * 0.75 / 2))
		tburn = 2
	else
		tburn = 3

	if (brute_dam == 0)
		tbrute = 0
	else if (brute_dam < (max_damage * 0.25 / 2))
		tbrute = 1
	else if (brute_dam < (max_damage * 0.75 / 2))
		tbrute = 2
	else
		tbrute = 3

	return "[tbrute][tburn]"

// new damage icon system
// adjusted to set damage_state to brute/burn code only (without r_name0 as before)

/datum/organ/external/proc/update_icon()

	var/n_is = damage_state_text()
	if (n_is != damage_state)
		damage_state = n_is
		return 1
	else
		return 0
	return
