# Ultima 7 Revisited - Scripts Plan

## Overview

This document outlines a systematic plan to work through all decompiled Ultima 7 scripts, identify missing engine functions, create unit tests, and organize the codebase for maintainability.

## Current State Assessment

### Script Inventory
- **Total Scripts**: 1,026 Lua files in `Redist/Data/Scripts/`
- **Catalogued Functions**: 1,012 func_XXXX entries documented in `function_comments.txt`
- **Unknown Intrinsics**: ~4,573 calls to `unknown_XXXXH()` functions that need C++ implementations
- **Named Scripts**: A few scripts already renamed (e.g., `erethian.lua`, `ferryman_09BH.lua`, `armor_vendor_0953.lua`)

### Script Categories

Based on analysis of `function_comments.txt`, scripts fall into these categories:

1. **NPC Dialogues** (~200-300 scripts)
   - Named characters with quest dialogues
   - Generic NPCs (guards, vendors, etc.)
   - Animals (cats, dogs, cows, parrots)
   - Monsters and special encounters

2. **Interactive Items** (~300-400 scripts)
   - Consumables (food, potions)
   - Tools (keys, lockpicks, fishing poles)
   - Crafting stations (looms, forges, spinning wheels)
   - Magic items (rings, gems)
   - Light sources (candles, torches)

3. **Doors & Gates** (~50-100 scripts)
   - Multi-part door systems (shapes 270/376/432/433)
   - Locked doors
   - Portcullises and gates
   - Secret doors

4. **Game Mechanics** (~100-150 scripts)
   - Time displays (clocks, sundials)
   - Ships and barges (sailing, gangplanks)
   - Mini-games (triples, rat race, gambling wheel)
   - Forging systems (bellows, hammers, swords)
   - Environmental triggers

5. **Utility Functions** (~100-200 scripts)
   - Position helpers
   - Container management
   - State toggles
   - Music/sound triggers
   - Flag management

### Known Intrinsic Functions (Partially Mapped)

From analyzing scripts, some intrinsics are already identified:

- `unknown_0018H()` - Get object position (returns {x, y, z} table)
- `unknown_0025H()` - Check if object is contained
- `unknown_0026H()` - Set object position
- `unknown_0035H()` - Find/search for objects (stub)
- `unknown_0048H()` - Unknown function called by func_00B2
- `unknown_006EH()` - Unknown function (used in ring of regeneration)
- `unknown_007EH()` - Unknown function (sail-related)
- `unknown_0058H()` - Unknown function (object check)
- `unknown_0081H()` - Unknown function (condition check)
- `unknown_0088H()` - Check item/inventory condition
- `unknown_0089H()` - Set object property (2 params)
- `unknown_008AH()` - Set object property (2 params)
- `unknown_0809H()` - Call external function for object
- `unknown_080DH()` - Unknown check function
- `unknown_0818H()` - Unknown action
- `unknown_0819H()` - Unknown action on object
- `unknown_081AH()` - Unknown action on object
- `unknown_081BH()` - Get object property
- `unknown_081DH()` - Complex check (6+ params) - likely pathfinding/movement
- `unknown_081EH()` - Complex action (9+ params) - likely pathfinding/movement
- `unknown_0829H()` - Check gangplank blocked
- `unknown_0830H()` - Sail manipulation
- `unknown_0831H()` - Ship preparation
- `unknown_08B3H()` - Get property from array element
- `unknown_08FFH()` - Display message (dialog text)

### Comparison with Exult's Approach

The Exult project (https://github.com/exult/exult) uses a different architecture:

**Exult Architecture:**
- Bytecode interpreter (`ucmachine.cc/h`) - VM execution engine
- Intrinsics (`intrinsics.cc`, `bgintrinsics.h`, `siintrinsics.h`) - Native function bridges
- Scheduling system (`ucsched.cc/h`) - Task queue management
- Conversation system (`conversation.cc/h`) - Dialogue handling
- Debugging support (`debugserver.cc/h`, `ucdebugging.cc/h`)

**U7Revisited Architecture:**
- Lua-based scripting (`ScriptingSystem.cpp`)
- C++ intrinsics registered via `RegisterAllLuaFunctions()` in `U7LuaFuncs.cpp`
- Event-driven model (eventid, objectref parameters)
- Coroutine support for wait/yield

**Key Difference:** Exult executes original compiled usecode bytecode; U7Revisited uses decompiled Lua scripts calling C++ intrinsics. This gives us more flexibility but requires mapping all original intrinsics to Lua-callable C++ functions.

## Understanding Script References

### How Scripts Are Connected to Game Objects

The scripting system uses a **dynamic name-based lookup** that makes renaming scripts straightforward:

1. **Script Loading** ([Main.cpp:204-223](Source/Main.cpp#L204-L223))
   - At engine startup, all `.lua` files in `Data/Scripts/` are automatically loaded
   - Creates a lookup table: `m_scriptFiles` (vector of `<script_name, file_path>` pairs)
   - Script names are extracted from filenames (without `.lua` extension)

2. **Shape-to-Script Mapping** ([shapetable.dat](Redist/Data/shapetable.dat))
   - Each shape/frame combination has an associated script name (last field in each line)
   - Example: `270 0 ... Models/3dmodels/zzwrongcube.obj 1 0 270 0 func_010E`
   - The script name (e.g., `func_010E`) is stored in `ShapeData::m_luaScript`

3. **Runtime Execution** ([U7Object.cpp:624-628](Source/U7Object.cpp#L624-L628))
   - Objects call `g_ScriptingSystem->CallScript(m_shapeData->m_luaScript, {event, m_ID})`
   - The script name from shapetable.dat is used as the lookup key
   - No hardcoded paths or filename dependencies

4. **Function Matching** ([ScriptingSystem.cpp:148-172](Source/Geist/ScriptingSystem.cpp#L148-L172))
   - `CallScript()` looks up the global Lua function with that exact name
   - The function name inside the Lua file **must match** the script name
   - Example: If script is named `door_270_multi`, the Lua file must contain `function door_270_multi(objectref)`

### What Changes When Renaming a Script

When renaming `func_010E.lua` → `door_270_multi.lua`, **4 things must change**:

#### 1. The Lua Script File ✅ (Use `git mv`)
```bash
git mv Redist/Data/Scripts/func_010E.lua Redist/Data/Scripts/door_270_multi.lua
```
**Important**: Always use `git mv` instead of regular file rename to preserve git history!

#### 2. Function Name Inside the Lua File ⚠️ (Required)
```lua
-- OLD:
function func_010E(objectref)
    -- door logic...
end

-- NEW:
function door_270_multi(objectref)
    -- door logic...
end
```
The function name **must match** the script name for `CallScript()` to find it.

#### 3. The shapetable.dat Data File ⚠️ (Critical)

**Location**: `Redist/Data/shapetable.dat`

**Format**: Text file with one line per shape/frame combination (space-separated fields)

**What to change**: The **last field** on each affected line

**Before**:
```
270 0 0 0 32 5 0 6 32 20 32 0 18 6 1 1 1 0.6 0 0 0.2 0 1 2 3 4 5 6 Models/3dmodels/zzwrongcube.obj 1 0 270 0 func_010E
                                                                                                                    ^^^^^^^^^^
```

**After**:
```
270 0 0 0 32 5 0 6 32 20 32 0 18 6 1 1 1 0.6 0 0 0.2 0 1 2 3 4 5 6 Models/3dmodels/zzwrongcube.obj 1 0 270 0 door_270_multi
                                                                                                                    ^^^^^^^^^^^^^^^
```

**Finding affected lines**: Search shapetable.dat for lines ending with the old script name.

#### 4. No C++ Code Changes Needed ✅

The dynamic loading system handles everything automatically! No need to modify:
- ❌ ScriptingSystem.cpp
- ❌ U7Object.cpp
- ❌ Main.cpp
- ❌ Any header files

### Migration Tool Specification

To automate the renaming process for all 1,026 scripts, we'll create a Python tool:

#### `migrate_scripts.py` - All-at-Once Migration

**Purpose**: Rename all scripts from generic `func_XXXX.lua` to descriptive names based on `function_comments.txt`.

**Usage**:
```bash
# Preview what would change (safe, read-only)
python migrate_scripts.py --dry-run

# Execute the migration (makes actual changes)
python migrate_scripts.py
```

**What It Does**:

1. **Parse function_comments.txt**
   - Extract all function descriptions (1,012 entries)
   - Generate descriptive names using naming convention:
     ```
     NPCs:         npc_<name>_<id>.lua          (e.g., npc_erethian_009A.lua)
     Items:        item_<type>_<id>.lua         (e.g., item_ring_regen_012A.lua)
     Doors:        door_<shape>_<id>.lua        (e.g., door_270_multi_010E.lua)
     Mechanics:    mech_<system>_<id>.lua       (e.g., mech_forge_bellows_01AF.lua)
     Utility:      util_<purpose>_<id>.lua      (e.g., util_position_0018.lua)
     ```
   - Create mapping: `func_010E` → `door_270_multi`

2. **Rename All Script Files** (using `git mv`)
   - For each of the 1,026 scripts:
     ```python
     subprocess.run(['git', 'mv',
                     'Redist/Data/Scripts/func_010E.lua',
                     'Redist/Data/Scripts/door_270_multi.lua'])
     ```
   - Track all renames for shapetable.dat updates
   - Report any files that don't exist or can't be renamed

3. **Update Function Names Inside Files**
   - Read each renamed file
   - Find the function definition line (regex: `^function func_[0-9A-F]{4}H?\(`)
   - Replace with new function name
   - Write back to file
   - Verify the change was successful
   - **Note**: Scripts do NOT call other scripts directly - they only call `unknown_XXXXH()` intrinsic functions, so no need to update function calls within scripts

4. **Update shapetable.dat**
   - Create backup: `shapetable.dat.backup`
   - Read entire file
   - For each line, replace old script name with new name (last field)
   - Write updated content back
   - Report number of lines modified

5. **Generate Report**
   ```
   Migration Summary:
   ==================
   Files renamed: 1,026
   shapetable.dat entries updated: 3,847
   Backup created: shapetable.dat.backup

   Ready for testing!

   Next steps:
   1. Review changes: git status
   2. Test in-game
   3. Commit when satisfied: git commit -m "Rename all scripts to descriptive names"
   4. Or revert if needed: git reset --hard
   ```

**What It Does NOT Do**:

- ❌ **No `git commit`** - You commit manually after testing
- ❌ **No `git push`** - You push when ready
- ❌ **No C++ modifications** - Not needed
- ❌ **No directory reorganization** (yet) - That's Phase 2, Step 3

**Safety Features**:

1. **Dry-Run Mode** (`--dry-run`)
   - Shows exactly what would be changed
   - No files modified
   - No git operations performed
   - Validates all inputs first

2. **Pre-Flight Checks**
   - Verify git repository exists and is initialized
   - Verify working directory is clean (warn if not)
   - Verify all source files exist
   - Verify function_comments.txt is readable
   - Verify shapetable.dat exists

3. **Backup Creation**
   - Automatically creates `shapetable.dat.backup` before modifications
   - Can be manually restored if needed

4. **Error Handling**
   - Stop on first error
   - Clear error messages
   - Rollback capability (git reset)

5. **Detailed Logging**
   - Write full log to `migration.log`
   - Include timestamp for each operation
   - Log every file rename, function update, shapetable change

**Implementation Notes**:

```python
#!/usr/bin/env python3
import subprocess
import re
import shutil
from pathlib import Path

class ScriptMigrator:
    def __init__(self, dry_run=False):
        self.dry_run = dry_run
        self.renames = {}  # old_name -> new_name mapping

    def parse_function_comments(self):
        """Parse function_comments.txt to generate name mappings"""
        # Extract function descriptions
        # Generate descriptive names based on category
        # Return mapping dict

    def git_mv(self, old_path, new_path):
        """Rename file using git mv"""
        if self.dry_run:
            print(f"[DRY-RUN] git mv {old_path} {new_path}")
        else:
            subprocess.run(['git', 'mv', old_path, new_path], check=True)

    def update_function_name(self, file_path, old_name, new_name):
        """Update function name inside Lua file"""
        # Read file
        # Regex replace function name
        # Write back

    def update_shapetable(self):
        """Update all script references in shapetable.dat"""
        # Backup file
        # Read all lines
        # Replace script names (last field)
        # Write back
```

**Workflow After Migration**:

1. **Preview Changes**:
   ```bash
   python migrate_scripts.py --dry-run > preview.txt
   # Review preview.txt
   ```

2. **Execute Migration**:
   ```bash
   python migrate_scripts.py
   ```

3. **Review Git Status**:
   ```bash
   git status
   # Should show ~1,026 renamed files
   # Should show modified shapetable.dat
   ```

4. **Test In-Game**:
   - Build and run the game
   - Test door interactions (func_010E → door_270_multi)
   - Test NPC dialogues
   - Test various items
   - Verify scripts are being called correctly

5. **Check Logs**:
   ```bash
   # Look for any script errors in debug output
   tail -f debug.log | grep "Calling Lua function"
   ```

6. **Commit Changes** (when satisfied):
   ```bash
   git commit -m "Rename all scripts from func_XXXX to descriptive names

   - Migrated 1,026 Lua scripts to descriptive names based on function_comments.txt
   - Updated shapetable.dat with new script references
   - Updated function names inside all Lua files to match new filenames
   - No C++ code changes required (dynamic loading handles it)
   - Preserved git history using git mv for all renames"
   ```

7. **Or Rollback** (if issues found):
   ```bash
   git reset --hard
   cp shapetable.dat.backup shapetable.dat  # Restore if needed
   ```

## Systematic Work Plan

### Phase 1: Intrinsic Function Mapping (Priority: CRITICAL)

**Goal:** Map all `unknown_XXXXH()` functions to their purposes and implement them in C++.

**Process:**

1. **Generate Intrinsic Inventory**
   - Extract all unique `unknown_XXXXH` calls from all scripts
   - Count usage frequency for prioritization
   - Group by hex range (likely indicates functional categories)

2. **Cross-Reference with Exult**
   - Compare intrinsic IDs with Exult's `bgintrinsics.h` and `siintrinsics.h`
   - Many IDs likely map directly to Exult's intrinsic numbers
   - Document parameter counts and return types

3. **Implementation Priority**
   ```
   Priority 1 - BLOCKING: Functions preventing any script from running
   - Message/dialogue display (0x08FF)
   - Basic object queries (position, shape, frame, quality)
   - Container/inventory checks

   Priority 2 - CORE GAMEPLAY: Functions for main quest progression
   - Dialogue system functions
   - Flag get/set
   - NPC manipulation
   - Item creation/destruction

   Priority 3 - INTERACTIONS: Functions for item/object interactions
   - Door operations
   - Container management
   - Item usage/consumption
   - Equipment handling

   Priority 4 - MECHANICS: Functions for special systems
   - Pathfinding (0x081D, 0x081E already partially done)
   - Ship/barge navigation
   - Crafting systems
   - Mini-games

   Priority 5 - POLISH: Functions for nice-to-have features
   - Music/sound triggers
   - Visual effects
   - Advanced AI behaviors
   ```

4. **Documentation Standard**
   For each intrinsic, document in `INTRINSICS.md`:
   ```markdown
   ### 0x0018 - GetObjectPosition
   **Lua Name:** `get_object_position(objectref)`
   **C++ Implementation:** `U7LuaFuncs.cpp:LuaGetObjectPosition()`
   **Parameters:**
   - objectref (number): Object ID to query
   **Returns:** table {x, y, z} - Position coordinates
   **Usage Count:** 247 scripts
   **Status:** ✅ IMPLEMENTED
   **Notes:** Used for all position-dependent logic
   ```

### Phase 2: Script Organization & Renaming

**Goal:** Rename generic `func_XXXX.lua` files to descriptive names and organize by category.

**Process:**

1. **Use function_comments.txt as Source of Truth**
   - Already contains descriptions for all 1,012 functions
   - Extract description → generate filename mapping

2. **Naming Convention**
   ```
   NPCs:         npc_<name>_<id>.lua          (e.g., npc_erethian_009A.lua)
   Items:        item_<type>_<id>.lua         (e.g., item_ring_regen_012A.lua)
   Doors:        door_<shape>_<id>.lua        (e.g., door_270_multi_010E.lua)
   Mechanics:    mech_<system>_<id>.lua       (e.g., mech_forge_bellows_01AF.lua)
   Utility:      util_<purpose>_<id>.lua      (e.g., util_position_0018.lua)
   ```

3. **Directory Structure**
   ```
   Redist/Data/Scripts/
   ├── npcs/
   │   ├── main_quest/      (critical NPCs)
   │   ├── vendors/
   │   ├── guards/
   │   ├── animals/
   │   └── monsters/
   ├── items/
   │   ├── consumables/
   │   ├── equipment/
   │   ├── tools/
   │   └── magic/
   ├── doors/
   ├── mechanics/
   │   ├── ships/
   │   ├── crafting/
   │   └── minigames/
   ├── utilities/
   └── default.lua
   ```

4. **Migration Script**
   Create `migrate_scripts.py` to:
   - Parse `function_comments.txt`
   - Generate new filenames
   - Move files to categorized directories
   - Update any hardcoded script references in C++ code

### Phase 3: Unit Testing Framework

**Goal:** Create comprehensive test coverage for all scripts.

**Approach:** Lua-based testing inspired by Exult's approach but adapted for our architecture.

**Test Framework Structure:**

```
Tests/
├── framework/
│   ├── test_runner.lua          # Main test executor
│   ├── mock_intrinsics.lua      # Mock implementations
│   ├── assertions.lua           # Test assertions
│   └── fixtures.lua             # Test data/objects
├── unit/
│   ├── npcs/
│   ├── items/
│   ├── doors/
│   └── utilities/
└── integration/
    ├── dialogue_trees/
    ├── quest_chains/
    └── game_mechanics/
```

**Mock Intrinsics:**
```lua
-- mock_intrinsics.lua
local mocks = {}

function mocks.create_mock_object(shape, frame, x, y, z)
    return {
        id = math.random(1000, 9999),
        shape = shape,
        frame = frame,
        position = {x, y, z},
        quality = 0,
        flags = {}
    }
end

function mocks.mock_get_object_position(obj)
    return obj.position
end

function mocks.mock_display_message(msg)
    table.insert(mocks.displayed_messages, msg)
end

return mocks
```

**Example Unit Test:**
```lua
-- test_npc_erethian.lua
local test = require("framework.test_runner")
local mocks = require("framework.mock_intrinsics")
local erethian = require("npcs.npc_erethian_009A")

test.describe("Erethian NPC Dialogue", function()
    test.it("should greet player on first interaction", function()
        local npc = mocks.create_mock_object(NPC_ERETHIAN_SHAPE, 0, 100, 100, 0)
        local flags = {}

        erethian(npc)

        test.assert_contains(mocks.displayed_messages, "Greetings, Avatar")
        test.assert_equals(flags[FLAG_MET_ERETHIAN], 1)
    end)

    test.it("should offer Dark Core information after flag set", function()
        local npc = mocks.create_mock_object(NPC_ERETHIAN_SHAPE, 0, 100, 100, 0)
        local flags = {[FLAG_MET_ERETHIAN] = 1}

        erethian(npc)

        test.assert_dialogue_option_exists("Dark Core")
    end)
end)
```

**Integration Testing:**

Use actual game engine with scripted scenarios:

```lua
-- integration/test_forge_workflow.lua
test.describe("Black Sword Forging", function()
    test.it("should complete full forging sequence", function()
        -- Setup
        local forge = create_object(SHAPE_FIREPIT, ...)
        local bellows = create_object(SHAPE_BELLOWS, ...)
        local hammer = create_object(SHAPE_HAMMER, ...)
        local blank = create_object(SHAPE_SWORD_BLANK, ...)

        -- Execute forging sequence
        use_bellows_on_forge(bellows, forge)
        place_blank_on_forge(blank, forge)
        wait_for_heating()
        use_hammer_on_blank(hammer, blank)

        -- Verify
        test.assert_object_type(blank, SHAPE_BLACK_SWORD)
        test.assert_object_frame(blank, FRAME_COMPLETED)
    end)
end)
```

### Phase 4: Systematic Review Process

**Goal:** Work through all scripts methodically, testing and fixing issues.

**Review Order:**

1. **Week 1-2: Critical Intrinsics** (~50 functions)
   - Implement Priority 1 intrinsics
   - Basic message display, object queries, flags
   - Test with simple item scripts

2. **Week 3-4: Dialogue System** (~30 intrinsics, ~200 scripts)
   - Implement conversation intrinsics
   - Test major NPC dialogues
   - Verify dialogue tree navigation

3. **Week 5-6: Door Systems** (~10 intrinsics, ~80 scripts)
   - Complete door intrinsics (already started)
   - Test all door types
   - Verify multi-part doors work correctly

4. **Week 7-8: Item Interactions** (~40 intrinsics, ~300 scripts)
   - Implement container, inventory, usage intrinsics
   - Test consumables, tools, equipment
   - Verify crafting systems

5. **Week 9-10: NPCs & AI** (~30 intrinsics, ~150 scripts)
   - Implement NPC movement, scheduling, AI
   - Test non-dialogue NPC behaviors
   - Verify animal and monster scripts

6. **Week 11-12: Special Systems** (~40 intrinsics, ~100 scripts)
   - Ships/barges, mini-games, special mechanics
   - Test full quest chains
   - Integration testing

7. **Week 13-14: Polish & Cleanup** (remaining scripts)
   - Implement remaining intrinsics
   - Fix edge cases
   - Performance optimization
   - Final integration tests

**Per-Script Review Checklist:**

```markdown
- [ ] Intrinsics identified and implemented
- [ ] Script renamed to descriptive name
- [ ] Moved to appropriate category directory
- [ ] Unit tests written
- [ ] Integration test coverage
- [ ] Tested in-game
- [ ] Documentation updated
- [ ] Known issues documented in script comments
```

### Phase 5: Documentation & Maintenance

**Deliverables:**

1. **INTRINSICS.md** - Complete reference for all intrinsic functions
2. **SCRIPT_REFERENCE.md** - Index of all scripts by category and purpose
3. **TESTING_GUIDE.md** - How to run and write tests
4. **KNOWN_ISSUES.md** - Tracking bugs and limitations
5. **EXULT_COMPARISON.md** - Mapping between Exult and U7Revisited implementations

**Ongoing Maintenance:**

- All new scripts must include unit tests
- Intrinsic implementations must be documented
- Regular regression testing
- Update documentation with discoveries

## Success Metrics

**Phase 1 Complete When:**
- All unknown_XXXXH functions identified
- Priority 1 & 2 intrinsics implemented (>80% coverage)
- Basic scripts can run without errors

**Phase 2 Complete When:**
- All scripts renamed with descriptive names
- Scripts organized into category directories
- Script loading system updated to handle new structure

**Phase 3 Complete When:**
- Test framework operational
- >50% of scripts have unit tests
- Integration test suite covers major game systems

**Phase 4 Complete When:**
- All scripts reviewed and tested
- All intrinsics implemented
- No critical bugs in script execution
- Main quest playable end-to-end

**Phase 5 Complete When:**
- All documentation complete
- Maintenance processes established
- Knowledge transfer complete

## Tools & Resources

**Existing Resources:**
- `function_comments.txt` - Already catalogues all 1,012 functions
- Exult source code - Reference implementation
- U7 technical docs - Game data formats
- Original usecode - For verification

**Tools Created:**
1. ✅ `migrate_scripts.py` - Rename and reorganize scripts (handles func_04XX NPCs, doors, etc.)
2. ✅ `ScriptTests.exe` - C++ test executable that validates all Lua scripts

**Tools to Create:**
1. `intrinsic_scanner.py` - Extract all unknown_XXXXH calls
2. `test_runner.lua` - Lua test framework for integration tests
3. `script_validator.py` - Check for missing intrinsics

**ScriptTests.exe Usage:**

```bash
# Syntax validation only (default mode)
cd Redist
../build/Debug/ScriptTests.exe

# Execute scripts with test parameters (requires game data)
../build/Debug/ScriptTests.exe --execute
```

**What ScriptTests Validates:**
- ✅ Lua syntax is correct (no parse errors)
- ✅ Script files can be loaded by Lua interpreter
- ✅ Function name matches filename (e.g., func_04FC exists in func_04FC.lua)
- ⚠️  Runtime execution (only with --execute flag, requires full game data)

**Development Workflow:**
1. Identify needed intrinsic
2. Research in Exult source
3. Implement in U7LuaFuncs.cpp
4. Register in RegisterAllLuaFunctions()
5. Write unit test
6. Test affected scripts
7. Document in INTRINSICS.md
8. Commit with clear message

## Notes

- Keep original func_XXXX.lua files as backup until migration complete
- Consider creating a "compatibility layer" to support both old and new script names during transition
- Some scripts may need C++ engine changes beyond just intrinsics
- Prioritize getting main quest working before focusing on side content
- Regular playtesting sessions to verify script behavior matches original game

## Next Steps

1. Create `intrinsic_scanner.py` to generate complete inventory
2. Start implementing Priority 1 intrinsics
3. Set up basic test framework
4. Begin systematic review with high-priority scripts (main quest NPCs, critical items)
