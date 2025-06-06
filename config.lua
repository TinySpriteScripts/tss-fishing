Config = {
    System = {
        Debug = true,            -- set true to view target/ped areas
        Menu = "ox",            -- "qb", "ox"
        Notify = "qb",            -- "qb", "ox", "esx, "okok", "gta"
        ProgressBar = "ox",     -- "qb", "ox"
        skillCheck = "ox",
    },
    Crafting = { --only here for bridge support
        showItemBox = true,--will only show if your inventory supports it
    },
    UseLevelSystem = false, --requires free script "tss-skills" link: https://github.com/TinySpriteScripts/tss-skills   (or configure your own in server/main/AddSkillXP)
    SkillCode = 'fishing', --must match a code from "tss-skills"
    DoubleXP = false, -- simply doubles the xp gained from fishing
    JobRequired = {
        Enable = false,
        Jobcode = 'fisherman',
        Label = "Fisherman",
    },
    FishAnywhere = true,-- if true will ignore table below
    FishingZones = {--ignored if Config.FishAnywhere = true
        {Coords = vector3(-198.2, 794.38, 198.11),Radius = 20.0},
    },
    FishingRelievesStress = true,
    StressReliefAmount = 1,
    MiniGame = true,
    CatchTime = {Min = 5,Max = 10},--how long from baiting rod to getting a "Bite"
    PutRodAwayTime = 60,--how many seconds of being idle before rod is put away
    FishingItems = {
        ['fishingrod'] = { -- item code
            Type = 'rod', --using 'rod' means you can use this item as fishing rod
            CatchMultiplier = 20, --in % so 20 mulitplier would mean a 20% increase in chance of catching the fish
        },
        ['fishingbait'] = {
            Type = 'bait', --using 'bait' means you can use this item as bait
            CatchList = { --items from Config.FishingRewards below
                "fish",           
                "stripedbass",    
                "bluefish",       
                "salmon",         
                "redfish",        
            },
        },
        ['fishingbait2'] = {
            Type = 'bait', 
            CatchList = {  
                "pacifichalibut", 
                "goldfish",       
                "largemouthbass", 
                "catfish",        
            },
        },
        ['fishingbait3'] = {
            Type = 'bait',
            CatchList = { 
                "tigersharkmeat", 
                "stingraymeat",   
                "killerwhalemeat",
            },
        },
    },
    FishingRewards = {
        ["fish"] =            {Chance = 90,     XPGive = 1},
        ["stripedbass"] =     {Chance = 70,     XPGive = 1},
        ["bluefish"] =        {Chance = 70,     XPGive = 1},
        ["salmon"] =          {Chance = 70,     XPGive = 1},
        ["redfish"] =         {Chance = 60,     XPGive = 1},
        ["pacifichalibut"] =  {Chance = 60,     XPGive = 1},
        ["goldfish"] =        {Chance = 60,     XPGive = 1},
        ["largemouthbass"] =  {Chance = 50,     XPGive = 1},
        ["catfish"] =         {Chance = 50,     XPGive = 1},
        ["tigersharkmeat"] =  {Chance = 30,     XPGive = 1},
        ["stingraymeat"] =    {Chance = 30,     XPGive = 1},
        ["killerwhalemeat"] = {Chance = 100,     XPGive = 1},
    },
}