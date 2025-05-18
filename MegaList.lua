
-- Define enums for roles
ROLE = {
    DEFAULT = 1,
    TANK = 2,  
    WARLOCK = 3,
    MAGE = 4,
    DRUID = 5,
}

if ROLE_LISTS == nil then
	ROLE_LISTS = {
	    {1, 2, 3, 4, 5, 6, 7, 8},
	    {5, 6},
	    {5, 6,7,8},
	    {5, 6},
	}
end


default_data = "Plagued Ghoul,1,1;Firewalker,1,1;Ragnaros,1,1;Skeletal Guardian,1,1;Diseased Ghoul,2,1;Lord Kri,1,1;Naxxramas Worshipper,2,1;Lava Reaver,4,1;Green Drakonid,1,1;Gordok Captain,1,1;Unstoppable Abomination,1,1;Stitched Giant,1,1;Sludge Belcher,1,1;Grethok the Controller,1,1;Vekniss Hatchling,2,1;Gordok Warlock,1,1;Vekniss Warrior,1,1;Gehennas,1,1;Zulian Panther,2,1;Gordok Reaver,1,1;Core Rager,1,1;Bile Retcher,1,1;Dust Stormer,2,1;Gordok Brute,2,1;Gurubashi Blood Drinker,3,1;Plagued Warrior,1,1;Noth the Plaguebringer,1,1;Doomguard Minion,1,1;Crypt Guard,1,1;Blackwing Spellbinder,1,1;Unrelenting Rider,1,1;Dread Creeper,2,1;Flamegor,1,1;Spectral Trainee,1,1;Spectral Death Knight,1,1;Princess Huhuran,1,1;Qiraji Champion,1,5;Flamewaker Healer,2,2;Frost Wyrm,1,1;Soulflayer,2,7;Stitched Spewer,1,1;Ouro,1,1;Defias Prisoner,3,1;Living Monstrosity,1,1;Ebonroc,1,1;Necro Knight,1,1;Defias Captive,1,1;Gordok Mage-Lord,1,1;Death Talon Hatcher,2,1;Vekniss Guardian,3,1;Vekniss Scorpion,2,1;Defias Convict,1,1;Baron Geddon,1,1;Hamhock,1,1;Viscidus,1,1;Twilight Deacon Farthing,1,1;Blackwing Taskmaster,1,1;Lava Spawn,1,12;Deathknight,1,1;Hive'Zara Stinger,1,1;Death Talon Wyrmguard,1,1;Vekniss Stinger,2,1;Buru Egg,1,1;Lightning Totem,1,12;Grobbulus,1,1;Defias Inmate,2,1;Skeletal Horror,1,1;Skeletal Steed,1,1;Qiraji Lasher,1,1;Kel'Thuzad,1,1;Crypt Crawler,1,1;Defias Bodyguard,1,1;Lucifron,1,1;Anub'Rekhan,1,7;Deathcharger Steed,1,1;Targorr the Dread,1,1;Deathknight Cavalier,1,1;Dark Touched Warrior,3,1;Razorgore the Untamed,1,1;Core Hound,1,1;Necro Knight Guardian,1,1;Molten Giant,2,1;Whirling Invader,1,1;Stephanie Turner,1,1;Princess Yauj,2,1;Living Poison,1,1;Ancient Core Hound,1,1;Gurubashi Berserker,1,7;Patchwerk,1,1;Doom Touched Warrior,2,1;Spectral Rider,1,1;Maexxna,1,1;Anubisath Warder,1,5;Mad Scientist,2,1;Deathknight Vindicator,1,1;Lord Overheat,1,1;Unholy Swords,1,1;Gothik the Harvester,1,1;Chromatic Drakonid,2,1;Sewage Slime,1,1;Deathknight Captain,2,1;The Twin Emperors,1,1;Gurubashi Bat Rider,1,1;Anubisath Defender,1,1;Death Talon Seether,1,1;Blackwing Mage,1,1;Vem,3,1;Death Talon Wyrmkin,2,1;Golemagg the Incinerator,1,1;Deathknight Understudy,1,1;Plague Slime,1,4;Molten Destroyer,1,1;Qiraji Brainwasher,2,1;Unholy Axe,1,1;Qiraji Warrior,2,1;Death Knight Captain,1,1;Rotting Maggot,1,1;Naxxramas Follower,1,1;Lava Annihilator,3,1;Naxxramas Acolyte,1,1;Kam Deepfury,1,1;Nerubian Warrior,1,1;Maexxna's Spiderling,2,1;Hive'Zara Sandstalker,1,1;Firelord,1,1;Shazzrah,1,1;Stormwind City Guard,2,1;Plagued Guardian,1,1;Qiraji Slayer,1,1;Flesh Hunter,1,12;Obsidian Eradicator,1,1;Sartura's Royal Guard,1,1;Vekniss Wasp,3,1;Necropolis Acolyte,1,1;Hakkari Witch Doctor,1,1;Anubisath Swarmer,2,1;Blackwing Warlock,1,1;Anubisath Sentinel,1,1;Plagued Champion,1,1;Swarmguard Needler,1,1;Patchwork Golem,2,1;Hakkari Shadow Hunter,2,7;Venom Stalker,1,1;Death Talon Overseer,1,1;Sapphiron,1,6;Hakkari Shadowcaster,1,1;Tomb Horror,1,1;Firemaw,1,1;Obsidian Destroyer,1,1;Bruegal Ironknuckle,1,1;Death Talon Flamescale,1,1;Lava Elemental,3,1;Dextren Ward,1,1;Qiraji Gladiator,1,1;Gurubashi Champion,2,1;Plagued Construct,1,1;Qiraji Brigadier General,1,1;Black Drakonid,1,1;Lava Surger,2,1;Thaddius,1,1;Loatheb,1,1;Hakkari Priest,1,1;Skeletal Smith,1,1;Plagued Gargoyle,1,1;Unholy Staff,1,1;Flamewaker Priest,1,1;Voodoo Slave,1,1;Unliving Resident,1,1;Gluth’s Minion,1,1;Heigan the Unclean,1,1;Spectral Deathknight,1,1;Unrelenting Death Knight,1,1;Plague Beast,1,1;Carrion Spinner,2,1;Firesworn,1,1;Spirit of Naxxramas,1,12;Death Lord,1,1;Death Touched Warrior,2,1;Blackwing Legionnaire,1,1;Fankriss the Unyielding,1,1;Vekniss Soldier,1,1;Flamewaker Elite,1,1;Sulfuron Harbinger,1,1;Plague Fissure,1,1;Hakkari Blood Priest,1,7;Skeletal Berserker,2,1;C'Thun,1,1;Unrelenting Trainee,1,1;Gluth,1,1;Death Talon Captain,1,9;Vaelastrasz the Corrupt,1,1;Vekniss Hive Crawler,1,1;Diseased Maggot,1,1;Risen Deathknight,2,1;Death Talon Hatchling,1,1;Battleguard Sartura,1,1;Anubisath Guardian,1,1;Defias Pathstalker,1,1;Nefarian,1,1;Bazil Thredd,1,1;Qiraji Swarmguard,2,1;Infectious Ghoul,1,1;Stoneskin Gargoyle,1,1;Blue Drakonid,1,1;The Prophet Skeram,1,1;Qiraji Mindslayer,2,1;Necro Stalker,1,1;Broodlord Lashlayer,1,1;The Four Horsemen,1,1;Deathcharger,1,1;Shade of Naxxramas,1,12;Bronze Drakonid,1,1;Flameguard,2,1;Magmadar,1,1;Crypt Reaver,1,1;Defias Insurgent,2,1;Obsidian Nullifier,1,1;Red Drakonid,1,1;Blackwing Guardsman,1,1;Chromaggus,1,1;Shadowforge Flame Keeper,1,1;"
--if not MegapandaMarkerDB or next(MegapandaMarkerDB) == nil then
function InitializeMarkers(reset)
	reset = reset or false

	if not MegapandaMarkerDB or next(MegapandaMarkerDB) == nil or reset then
		ROLE_LISTS = {
		    {1, 2, 3, 4, 5, 6, 7, 8},
		    {5, 6},
		    {5, 6, 7, 8},
		    {5, 6}
		}

	
		MegapandaMarkerDB = {}  -- Clear existing data
    	for entry in string.gmatch(default_data, "([^;]+)") do
        	local key, priority, role = default_data.match(entry, "([^,]+),([^,]+),([^,]+)")
        	if key and priority and role then
            	MegapandaMarkerDB[key] = {priority = tonumber(priority), role = {role}}
        	end
    	end
    	--print("Revverted to default values")
	end
end

InitializeMarkers()

--function initializeMegapandaMarkerDB () 
--	print("Hellllloooo")
--end