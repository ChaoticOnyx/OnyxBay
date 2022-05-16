// All signals send the source datum of the signal as the first argument.

/// When a component is added to a datum: (/datum/component).
#define SIGNAL_COMPONENT_ADDED "component_added"
/// Before a component is removed from a datum because of clear_from_parent: (/datum/component).
#define SIGNAL_COMPONENT_REMOVING "component_removing"
/// Generic topic handler (usr, href_list).
#define SIGNAL_TOPIC "handle_topic"
/// From datum ui_act (usr, action).
#define SIGNAL_UI_ACT "SIGNAL_UI_ACT"

/// Fires on the target datum when an element is attached to it (/datum/element).
#define SIGNAL_ELEMENT_ATTACH "element_attach"
/// Fires on the target datum when an element is attached to it (/datum/element).
#define SIGNAL_ELEMENT_DETACH "element_detach"
