
LOOT_TABLES = {}

function newLootTable(name)

    LOOT_TABLES[name] = {

        name = name,

        multipleDrops = {},
        oneTimeDrops  = {},

        addMultiple = addMultipleDrop,
        addOneTime  = addOneTimeDrop,

        returnDrops = returnRandomDrops

    }

end

function addMultipleDrop(lootTable, name, chance)   -- Add multiple drop

    table.insert(lootTable.multipleDrops, {

        name = name, chance = chance

    })

end

function addOneTimeDrop(lootTable, drops)           -- Add one time drop

    table.insert(lootTable.oneTimeDrops, drops)

end

function returnRandomDrops(lootTable)

    local items = {}

    for id, item in ipairs(lootTable.multipleDrops) do -- Multiple drops

        local rawChance = item.chance / 100

        local amount = math.floor(rawChance)

        local extraChance = rawChance - amount

        if love.math.random(0, 100) < extraChance * 100 then amount = amount + 1 end

        for x = 1, amount do table.insert(items, deepcopyTable(ITEMS[item.name])) end

    end

    for id, oneTimeItems in  ipairs(lootTable.oneTimeDrops) do -- One time drops

        table.insert(items, deepcopyTable(ITEMS[oneTimeItems[love.math.random(1, #oneTimeItems)]]))

    end

    return items

end

function getLootTable(name) return LOOT_TABLES[name] end

-- Enemy loot tables:

newLootTable("slimeDrop")                                       -- SLIME

getLootTable("slimeDrop"):addMultiple("jello", 250)

newLootTable("giantFireflyDrop")                                -- GIANT FIREFLY

getLootTable("giantFireflyDrop"):addMultiple("glowDrop", 250)

newLootTable("skeletonMinerDrop")                               -- SKELETON MINER

getLootTable("skeletonMinerDrop"):addMultiple("bone", 250)

newLootTable("battleflyDrop")                                   -- BATTLE FLY

getLootTable("battleflyDrop"):addMultiple("flyDust", 250)

-- Biome chest loot tables

newLootTable("caveChest")                                       -- CAVE

getLootTable("caveChest"):addMultiple("stone", 250)
getLootTable("caveChest"):addMultiple("wood", 250)

getLootTable("caveChest"):addMultiple("jello", 250)
getLootTable("caveChest"):addMultiple("glowDrop", 150)
getLootTable("caveChest"):addMultiple("bone", 150)

getLootTable("caveChest"):addOneTime({

    "woodenBow", "stoneTribow", "boneBow",

    "bat", "stoneSword", "boneDagger",

    "jelloRod", "boneRod", "rodOfLight"

})

newLootTable("sporeCavernChest")                                       -- SPORE_CAVERN

getLootTable("sporeCavernChest"):addMultiple("wood", 250)
getLootTable("sporeCavernChest"):addMultiple("shroomOre", 250)

getLootTable("sporeCavernChest"):addMultiple("jello", 250)
getLootTable("sporeCavernChest"):addMultiple("flyDust", 250)

getLootTable("sporeCavernChest"):addOneTime({

    "flyDustBow", "mushboomBow",

    "shroomBat",

    "mushboomRod", "rodOfChase"

})