// Normally this instances are not going to change in runtime
// and they are the same for all wizards.
GLOBAL_LIST_INIT(wizard_classes, list(); for(var/class in subtypesof(/datum/wizard_class)) wizard_classes.Add(list("[class]" = new class));)
