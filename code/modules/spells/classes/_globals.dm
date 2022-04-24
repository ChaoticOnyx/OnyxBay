// Normally this instances are not going to change in runtime
// and they are the same for all wizards.
// But it may be useful sometimes to change some variables through VV.
GLOBAL_LIST_INIT(wizard_classes, list(); for(var/class in subtypesof(/datum/wizard_class)) wizard_classes.Add(list("[class]" = new class));)
