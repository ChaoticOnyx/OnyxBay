// All signals send the source datum of the signal as the first argument.

/// When a component is added to a datum: (/datum/component).
#define SIGNAL_COMPONENT_ADDED "component_added"
/// Before a component is removed from a datum because of ClearFromParent: (/datum/component).
#define SIGNAL_COMPONENT_REMOVING "component_removing"
/// Before a datum's Destroy() is called: (force), returning a nonzero value will cancel the qdel operation.
#define SIGNAL_PARENT_PREQDELETED "parent_preqdeleted"
/// Just before a datum's Destroy() is called: (force), at this point none of the other components chose to interrupt qdel and Destroy will be called.
#define SIGNAL_PARENT_QDELETING "parent_qdeleting"
/// Generic topic handler (usr, href_list).
#define SIGNAL_TOPIC "handle_topic"
/// From datum ui_act (usr, action).
#define SIGNAL_UI_ACT "SIGNAL_UI_ACT"

/// Fires on the target datum when an element is attached to it (/datum/element).
#define SIGNAL_ELEMENT_ATTACH "element_attach"
/// Fires on the target datum when an element is attached to it (/datum/element).
#define SIGNAL_ELEMENT_DETACH "element_detach"
