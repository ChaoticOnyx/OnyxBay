/// An ordered list, using the cmp proc to weight the list elements

/datum/priority_queue
	/// The actual queue
	var/list/L
	/// The weight function used to order the queue
	var/cmp

/datum/priority_queue/New(compare)
	L = new()
	cmp = compare

/datum/priority_queue/proc/IsEmpty()
	return !L.len

/// Add an element in the list,
/// immediatly ordering it to its position using dichotomic search
/datum/priority_queue/proc/Enqueue(atom/A)
	ADD_SORTED(L, A, cmp)

/// Removes and returns the first element in the queue
/datum/priority_queue/proc/Dequeue()
	if(!L.len)
		return 0
	. = L[1]

	Remove(.)

/// Removes an element
/datum/priority_queue/proc/Remove(atom/A)
	. = L.Remove(A)

/// Returns a copy of the elements list
/datum/priority_queue/proc/List()
	. = L.Copy()

/// Return the position of an element or 0 if not found
/datum/priority_queue/proc/Seek(atom/A)
	. = L.Find(A)

/// Return the element at the i_th position
/datum/priority_queue/proc/Get(i)
	if(i > L.len || i < 1)
		return 0
	return L[i]

/// Return the length of the queue
/datum/priority_queue/proc/Length()
	. = L.len

/// Replace the passed element at it's right position using the cmp proc
/datum/priority_queue/proc/ReSort(atom/A)
	var/i = Seek(A)
	if(i == 0)
		return
	while(i < L.len && call(cmp)(L[i],L[i+1]) > 0)
		L.Swap(i,i+1)
		i++
	while(i > 1 && call(cmp)(L[i],L[i-1]) <= 0) // last inserted element being first in case of ties (optimization)
		L.Swap(i,i-1)
		i--
