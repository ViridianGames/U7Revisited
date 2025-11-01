--- Best guess: Silently destroys an item, possibly a cleanup function for ritual or event completion.
function utility_event_0520(eventid, objectref)
    destroy_object_silent(objectref) --- Guess: Destroys item silently
end