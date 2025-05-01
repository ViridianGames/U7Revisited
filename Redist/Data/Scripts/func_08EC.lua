-- Function 08EC: Manages poem recitation
function func_08EC()
    -- Local variables (3 as per .localc)
    local local0, local1, local2

    local0 = call_08F7H(-2)
    local1 = call_08F7H(-1)
    local2 = call_08F7H(-3)
    add_dialogue("\"Hubert the Lion was haughty and vain ~And especially proud of his elegant mane. ~But conceit of this sort isn't proper at all ~And Hubert the Lion was due for a fall.\"")
    add_dialogue("One day as he sharpened his claws on a rock ~He received a most horrible, terrible shock. ~A flaming hot spark flew up into the air, ~Came down on his head and ignited his hair.")
    add_dialogue("With a roar of surprise he took off like a streak, ~Away through the jungle to Zamboozi Creek. ~He leaped in kersplash! with a shower of bubbles, ~And came bobbing up with a head full of stubbles.")
    add_dialogue("At first he just stared with a wide-open mouth ~At the cloud of black smoke drifting off to the south. ~Then he felt with his paws just in back of his ears ~And he suddenly realized the worst of his fears.")
    add_dialogue("'I'm ruined,' he shouted, 'oh what'll I do! ~I'd rather be dead or go live in a zoo! ~And if anyone sees me, oh what a disgrace, ~So I'd better discover a good hiding place!'")
    callis_0008()

    return
end

-- Helper functions
function add_dialogue(...)
    print(table.concat({...}))
end