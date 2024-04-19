GLOBAL_LIST(uplink_purchase_logs_by_key)	//assoc key = /datum/uplink_purchase_log

/datum/uplink_purchase_log
	var/owner
	var/list/purchase_log				//assoc path-of-item = /datum/uplink_purchase_entry
	var/total_spent = 0

/datum/uplink_purchase_log/New(_owner, datum/component/uplink/_parent)
	owner = _owner
	LAZYINITLIST(GLOB.uplink_purchase_logs_by_key)
	if(owner)
		if(GLOB.uplink_purchase_logs_by_key[owner])
			util_crash_with("WARNING: DUPLICATE PURCHASE LOGS DETECTED. [_owner] [_parent] [_parent.type]")
			MergeWithAndDel(GLOB.uplink_purchase_logs_by_key[owner])
		GLOB.uplink_purchase_logs_by_key[owner] = src
	purchase_log = list()

/datum/uplink_purchase_log/Destroy()
	purchase_log = null
	if(GLOB.uplink_purchase_logs_by_key[owner] == src)
		GLOB.uplink_purchase_logs_by_key -= owner
	return ..()

/datum/uplink_purchase_log/proc/MergeWithAndDel(datum/uplink_purchase_log/other)
	if(!istype(other))
		return

	. = owner == other.owner
	if(!.)
		return

	for(var/hash in other.purchase_log)
		if(!purchase_log[hash])
			purchase_log[hash] = other.purchase_log[hash]
		else
			var/datum/uplink_purchase_entry/UPE = purchase_log[hash]
			var/datum/uplink_purchase_entry/UPE_O = other.purchase_log[hash]
			UPE.amount_purchased += UPE_O.amount_purchased
	qdel(other)

/datum/uplink_purchase_log/proc/TotalTelecrystalsSpent()
	. = total_spent

/datum/uplink_purchase_log/proc/LogPurchase(atom/A, datum/uplink_item/uplink_item, spent_cost)
	if(SSticker.end_game_state >= END_GAME_MODE_FINISH_DONE) // Don't log purchases past round-end
		return

	var/datum/uplink_purchase_entry/UPE
	var/hash = hash_purchase(uplink_item, spent_cost)
	if(purchase_log[hash])
		UPE = purchase_log[hash]
	else
		UPE = new
		purchase_log[hash] = UPE
		UPE.path = A.type
		UPE.icon_b64 = "[icon2base64html(A)]"
		UPE.desc = uplink_item.desc
		UPE.name = uplink_item.name
		UPE.base_cost = initial(uplink_item.item_cost)
		UPE.spent_cost = spent_cost

	UPE.amount_purchased++
	total_spent += spent_cost

/datum/uplink_purchase_log/proc/hash_purchase(datum/uplink_item/uplink_item, spent_cost)
	return "[uplink_item.type]|[uplink_item.name]|[uplink_item.item_cost]|[spent_cost]"

/datum/uplink_purchase_entry
	var/amount_purchased = 0
	var/path
	var/icon_b64
	var/desc
	var/base_cost
	var/spent_cost
	var/name
