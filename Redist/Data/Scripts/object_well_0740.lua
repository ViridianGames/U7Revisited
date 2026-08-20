--- Well (shape 740): draw water into an empty bucket (810) if the party carries one.
--- Restored/renamed from the misnamed object_chest_0740 / func_02E4.
function object_well_0740(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    -- Empty bucket in party inventory? (frame 0 of shape 810)
    local buckets = get_container_objects(0, 359, 810, 356)
    if not buckets then
        bark(objectref, "@You need a bucket.@")
        return
    end

    -- Prefer first matching bucket id if table returned
    local bucket = buckets
    if type(buckets) == "table" then
        bucket = buckets[1]
    end
    if not bucket then
        bark(objectref, "@You need a bucket.@")
        return
    end

    -- Original usecode repositioned near well 470; keep a simple fill for now.
    set_object_frame(bucket, 1) -- filled water frame (common U7 convention)
    bark(objectref, "@You fill the bucket.@")
end

-- Compat for older shapetable / callers
object_chest_0740 = object_well_0740
