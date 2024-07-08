/// Called on `/obj/item/proc/equipped` (/obj/item, /mob, slot)
#define SIGNAL_ITEM_EQUIPPED "item_equipped"

/// Called on `/obj/item/proc/dropped`, (/obj/item, /mob)
#define SIGNAL_ITEM_UNEQUIPPED "item_unequipped"

/// Called before '/obj/item/proc/afterattack' is called from mob's attack chain. (/atom/target, /mob/user, adjacent (TRUE/FALSE), params)
#define SIGNAL_ITEM_AFTERATTACK "item_afterattack"
