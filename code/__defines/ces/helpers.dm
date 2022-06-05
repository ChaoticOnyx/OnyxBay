/// Used to trigger signals and call procs registered for that signal.
/// The datum hosting the signal is automaticaly added as the first argument.
/// Returns a bitfield gathered from all registered procs.
/// Arguments given here are packaged in a list and given to _send_signal.
#define SEND_SIGNAL(target, sigtype, arguments...) ( !target.comp_lookup?[sigtype] ? FALSE : target._send_signal(sigtype, list(##arguments)) )

#define SEND_GLOBAL_SIGNAL(sigtype, arguments...) ( SEND_SIGNAL(SSelements, sigtype, ##arguments) )

/// A wrapper for _AddElement that allows us to pretend we're using normal named arguments.
#define AddElement(arguments...) _add_element(list(##arguments))
/// A wrapper for _RemoveElement that allows us to pretend we're using normal named arguments.
#define RemoveElement(arguments...) _remove_element(list(##arguments))

/// A wrapper for _add_component that allows us to pretend we're using normal named arguments.
#define AddComponent(arguments...) _add_component(list(##arguments))

/// A wrapper for _load_component that allows us to pretend we're using normal named arguments.
#define LoadComponent(arguments...) _load_component(list(##arguments))
