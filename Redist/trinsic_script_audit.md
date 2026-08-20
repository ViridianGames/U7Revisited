# Trinsic Object Script Audit

Bounds: **x 944–1104, z 2096–2336** (`AnalyzeTrinsicObjectList`)
Sources: STATIC IFIX + INITGAME IREG for superchunks (3,8)/(3,9)/(4,8)/(4,9)

| Metric | Count |
|--------|------:|
| Object instances | 2116 |
| Unique shapes | 182 |
| Has real script | 43 |
| Default (no script) | 134 |
| Thin / stub | 4 |
| Missing file | 0 |
| Eggs (special — not shape-scripted) | 1 |

## Needs script work (excluding scenery + eggs)

**76 unique shapes**, **255 instances**

### Priority interactive

| Shape | Name | # | Script | Status |
|------:|------|--:|--------|--------|
| 415 | garbage | 38 | `default` | default |
| 804 | crate | 30 | `default` | default |
| 802 | bag | 11 | `default` | default |
| 587 | boots | 8 | `default` | default |
| 800 | chest | 8 | `default` | default |
| 546 | broken dish | 6 | `default` | default |
| 594 | /dagger//s | 6 | `default` | default |
| 535 | spent sconce | 5 | `default` | default |
| 599 | sword | 4 | `default` | default |
| 740 | well | 4 | `default` | default |
| 257 | fortress gateway | 3 | `default` | default |
| 569 | leather armour | 3 | `default` | default |
| 572 | wooden shield | 3 | `default` | default |
| 579 | leather gloves | 3 | `default` | default |
| 659 | mace | 3 | `default` | default |
| 677 | sack of wheat | 3 | `default` | default |
| 994 | tongs | 3 | `default` | default |
| 1004 | leather helm | 3 | `default` | default |
| 211 | broken door | 2 | `default` | default |
| 272 | portcullis | 2 | `default` | default |
| 271 | portcullis | 1 | `default` | default |
| 542 | crested helm | 1 | `default` | default |
| 561 | great dagger | 1 | `default` | default |
| 588 | swamp boots | 1 | `default` | default |
| 724 | Fellowship Icon | 1 | `default` | default |
| 801 | backpack | 1 | `default` | default |
| 885 | Fellowship Staff | 1 | `default` | default |

(27 shapes)

### Other non-scenery (top 30 by count)

| Shape | Name | # | Script | Status |
|------:|------|--:|--------|--------|
| 426 | stairs | 7 | `default` | default |
| 616 | bottle | 7 | `object_bottle_0616` | stub_empty |
| 427 | stairs | 6 | `default` | default |
| 428 | stairs | 4 | `default` | default |
| 429 | stairs | 4 | `default` | default |
| 430 | stairs | 4 | `default` | default |
| 615 | /kni/fe/ves | 4 | `default` | default |
| 974 | stairs | 4 | `default` | default |
| 385 | stairs | 3 | `default` | default |
| 386 | stairs | 3 | `default` | default |
| 387 | stairs | 3 | `default` | default |
| 973 | stairs | 3 | `default` | default |
| 264 | iron bars | 2 | `default` | default |
| 268 | mirror | 2 | `default` | default |
| 277 | crossbeam | 2 | `default` | default |
| 285 | cloak | 2 | `default` | default |
| 407 | desk | 2 | `default` | default |
| 444 | hood | 2 | `default` | default |
| 543 | buckler | 2 | `default` | default |
| 591 | main gauche | 2 | `default` | default |
| 596 | morning star | 2 | `default` | default |
| 719 | water trough | 2 | `default` | default |
| 1023 | haystack | 2 | `default` | default |
| 249 | top | 1 | `default` | default |
| 276 | crossbeam | 1 | `default` | default |
| 388 | eating utensils | 1 | `default` | default |
| 414 | body | 1 | `default` | default |
| 416 | drawers | 1 | `default` | default |
| 574 | leather leggings | 1 | `default` | default |
| 589 | pitchfork | 1 | `default` | default |

## Already scripted (interactive sample)

| Shape | Name | # | Script |
|------:|------|--:|--------|
| 873 | chair | 43 | `object_chair_0873` |
| 1011 | bed | 36 | `object_bed_1011` |
| 379 | sign | 23 | `object_sign_0379` |
| 642 | book | 20 | `object_book_0642` |
| 292 | seat | 18 | `object_chair_0292` |
| 376 | door | 16 | `object_door_0376` |
| 696 | bed | 15 | `object_bed_0696` |
| 291 | closed shutters | 12 | `object_shutters_0291` |
| 270 | door | 11 | `object_door_0270` |
| 435 | lit sconce | 11 | `object_sconce_0435` |
| 797 | scroll | 10 | `object_book_0797` |
| 372 | open shutters | 9 | `object_shutters_0372` |
| 290 | closed shutters | 8 | `object_shutters_0290` |
| 322 | open shutters | 6 | `object_shutters_0322` |
| 377 | /food item//s | 6 | `object_fooditem_0377` |
| 810 | bucket | 5 | `object_bucket_0810` |
| 340 | /potion//s | 4 | `object_potion_0340` |
| 470 | well | 4 | `object_chest_0470` |
| 644 | /gold coin//s | 3 | `object_coins_0644` |
| 361 | sign | 2 | `utility_spell_0361` |
| 522 | locked chest | 2 | `object_chestlocked_0522` |
| 787 | lever | 2 | `object_lever_0787` |
| 641 | /key//s | 1 | `object_doorkey_0641` |
| 668 | sword blank | 1 | `object_swordblank_0668` |
| 991 | anvil | 1 | `object_anvil_0991` |

## Notes

- **Scenery** (roofs, fences, walls, floors, plants, etc.) usually correctly stays `default`.
- **Eggs (275)** use egg usecode IDs from IREG, not `shapetable` Lua — listed separately.
- **Loot items** (swords, armour on ground) often need no use-script; inventory use is separate.
- **Unlocked chests (800)** may need open/gump behavior; locked (522) already scripted.
- Full JSON: `Redist/trinsic_script_audit.json`