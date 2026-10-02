--- Best guess: Triggers an external function call (0699H) after setting up a game state, likely for a specific event or cleanup.
function utility_fade_party_formation_0411(eventid, objectref)
    fade_palette(0, 1, 12)
    utility_party_formation_ritual_0409(objectref)
end