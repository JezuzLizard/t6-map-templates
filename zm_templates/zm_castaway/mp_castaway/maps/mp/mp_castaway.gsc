#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_score;
#include maps\mp\_demo;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zombies\_zm_weap_cymbal_monkey;

// setup autoexec
#include maps\mp\mp_castaway_fx;

main()
{
	maps\mp\maptypes\_zm_usermap::setup_zombie_defaults();

    // you can edit the tables or redirect these calls to your script
    maps\mp\maptypes\_zm_usermap::include_powerups(); // zm/include_powerups.csv
    maps\mp\maptypes\_zm_usermap::include_fx(); // zm/include_fx.csv
    maps\mp\maptypes\_zm_usermap::add_zombie_weapons(); // zm/add_zombie_weapons.csv

    // map specific setup here
    maps\mp\zombies\_zm_ai_dogs::init();
    level.enable_magic = getgametypesetting( "magic" );
    maps\mp\_sticky_grenade::init();
    level._melee_weapons = []; // since we dont have bowie or tazers, init as empty

    level._post_zm_overrides_func = ::castaway_post_zm_init;
    level.givecustomloadout = ::givecustomloadout;
    level.zombie_init_done = ::zombie_init_done;
	onplayerconnect_callback( ::castaway_connected );
	
    // perk opt ins
    level.zombiemode_using_pack_a_punch = 1;
    level.zombiemode_reusing_pack_a_punch = 0;
    level.zombiemode_using_revive_perk = 1;
    level.zombiemode_using_juggernaut_perk = 1;
    level.zombiemode_using_marathon_perk = 1;
    level.zombiemode_using_doubletap_perk = 1;
    level.zombiemode_using_sleightofhand_perk = 1;
    level.zombiemode_using_tombstone_perk = 0;
    level.zombiemode_using_divetonuke_perk = 1;

    maps\mp\zombies\_zm_perk_divetonuke::enable_divetonuke_perk_for_level();

    // the vision looks really ugly on phd, so remove it
    replacefunc( maps\mp\zombies\_zm_perk_divetonuke::init_divetonuke, ::init_divetonuke );

    level.custom_vending_precaching = ::custom_vending_precaching;

    // disable loading random tranzit fx
    level.disable_fx_upgrade_aquired = true;
    level.fx_exclude_tesla_head_light = true;
    level.disable_fx_zmb_tranzit_shield_explo = true;

	level.culldist = 5000;
	setup_characters();
	castaway_setup_zones();
	determine_team_characters();
}

castaway_setup_zones()
{
	// init zone manager
	level.zone_manager_init_func = ::castaway_zone_init;
    level.zones = [];

	// init spawn zone
	init_zones[0] = "start_volume";
	maps\mp\maptypes\_zm_usermap::start_zombie_mode( init_zones );
}

castaway_post_zm_init()
{
	level.player_out_of_playable_area_monitor = false;
	level.player_too_many_weapons_monitor = true;
	level._use_choke_weapon_hints = true;
	level._use_choke_blockers = true;
	level.calc_closest_player_using_paths = false;
	level.zombie_melee_in_water = true;
	level.put_timed_out_zombies_back_in_queue = true;
	level.use_alternate_poi_positioning = true;

	// monkey bombs
    level.legacy_cymbal_monkey = 1;
    maps\mp\zombies\_zm_weap_cymbal_monkey::init();

	// init mystery box, teleporters, and the music easter egg
    castaway_magicbox_init();
	maps\mp\mp_castaway_amb::main();
	maps\mp\mp_castaway_music_egg::init();
	
	// turn them on by default
	turn_on_perks();

	// this is originally at -1000, this map's playable areas are lower than that
	set_zombie_var( "below_world_check", -4000 );

	// dog rounds
	maps\mp\zombies\_zm_ai_dogs::enable_dog_rounds();

	// for testing
	if ( GetDvarInt( "zombie_unlock_all" ) > 0 )
	{
		level.round_number = 100;
		level.next_dog_round = 101;
		level.first_round = 0;
		level.zombie_vars["zombie_spawn_delay"] = 0.08;
		level.zombie_move_speed = 130;
	}
}

castaway_zone_init()
{
	//add_adjacent_zone( "construction_volume", "security_volume", "activate_security_zone" );

}

turn_on_perks()
{
    flag_wait( "start_zombie_round_logic" );
    wait 1;

    level notify( "revive_on" );
    wait_network_frame();
    level notify( "doubletap_on" );
    wait_network_frame();
    level notify( "marathon_on" );
    wait_network_frame();
    level notify( "juggernog_on" );
    wait_network_frame();
    level notify( "sleight_on" );
    wait_network_frame();
    level notify( "Pack_A_Punch_on" );
    wait_network_frame();
    level notify( "divetonuke_on" );
}

castaway_connected()
{
    self SetClientDvars( "r_lightTweakSunLight", "10", "r_lodbiasskinned", "-1000", "r_lodbiasrigid", "-1000" );

	// for testing
	if ( GetDvarInt( "zombie_unlock_all" ) > 0 )
	{
		self.score = 500000;
	}
}

givecustomloadout( takeallweapons, alreadyspawned )
{
	self giveweapon( "knife_zm" );
	self give_start_weapon( 1 );
}

zombie_init_done()
{
	self.allowpain = 0;
	self setphysparams( 15, 0, 48 );
}

castaway_magicbox_init()
{
    /*housing_chest = GetStruct( "housing_chest", "script_noteworthy" );
    security_chest = GetStruct( "security_chest", "script_noteworthy" );
    lobby_chest_1 = GetStruct( "lobby_chest_1", "script_noteworthy" );
    lobby_chest_2 = GetStruct( "lobby_chest_2", "script_noteworthy" );

    level.chests = [];
    level.chests[level.chests.size] = housing_chest;
    level.chests[level.chests.size] = security_chest;
    level.chests[level.chests.size] = lobby_chest_1;
    level.chests[level.chests.size] = lobby_chest_2;

    maps\mp\zombies\_zm_magicbox::treasure_chest_init( "security_chest" );*/
}

setup_characters()
{
	level.precachecustomcharacters = ::precache_team_characters;
	level.givecustomcharacters = ::give_team_characters;
}

precache_team_characters()
{
    precachemodel( "c_zom_player_cdc_fb" );
    precachemodel( "c_zom_hazmat_viewhands" );
    precachemodel( "c_zom_player_cia_fb" );
    precachemodel( "c_zom_suit_viewhands" );
}

determine_team_characters()
{
    level.should_use_cia = 0;

    if ( randomint( 100 ) >= 50 )
	{
        level.should_use_cia = 1;
	}
}

give_team_characters()
{
	if ( isdefined( level.hotjoin_player_setup ) && [[ level.hotjoin_player_setup ]]( "c_zom_suit_viewhands" ) )
	{
		return;
	}

	self detachall();
    self set_player_is_female( 0 );

    if ( isdefined( level.should_use_cia ) )
    {
        if ( level.should_use_cia )
        {
            self setmodel( "c_zom_player_cia_fb" );
            self setviewmodel( "c_zom_suit_viewhands" );
            self.characterindex = 0;
        }
        else
        {
            self setmodel( "c_zom_player_cdc_fb" );
            self setviewmodel( "c_zom_hazmat_viewhands" );
            self.characterindex = 1;
        }
    }
    else
    {
        if ( !isdefined( self.characterindex ) )
        {
            self.characterindex = 1;

            if ( self.team == "axis" )
                self.characterindex = 0;
        }

        switch ( self.characterindex )
        {
            case 0:
            case 2:
                self setmodel( "c_zom_player_cia_fb" );
                self.voice = "american";
                self.skeleton = "base";
                self setviewmodel( "c_zom_suit_viewhands" );
                self.characterindex = 0;
                break;
            case 1:
            case 3:
                self setmodel( "c_zom_player_cdc_fb" );
                self.voice = "american";
                self.skeleton = "base";
                self setviewmodel( "c_zom_hazmat_viewhands" );
                self.characterindex = 1;
                break;
        }
    }

	self setmovespeedscale( 1 );
	self setsprintduration( 4 );
	self setsprintcooldown( 0 );
}

init_divetonuke()
{
    level.zombiemode_divetonuke_perk_func = ::divetonuke_explode;
    level._effect["divetonuke_groundhit"] = loadfx( "maps/zombie/fx_zmb_phdflopper_exp" );
    set_zombie_var( "zombie_perk_divetonuke_radius", 300 );
    set_zombie_var( "zombie_perk_divetonuke_min_damage", 1000 );
    set_zombie_var( "zombie_perk_divetonuke_max_damage", 5000 );
}

divetonuke_explode( attacker, origin )
{
    radius = level.zombie_vars["zombie_perk_divetonuke_radius"];
    min_damage = level.zombie_vars["zombie_perk_divetonuke_min_damage"];
    max_damage = level.zombie_vars["zombie_perk_divetonuke_max_damage"];

    if ( isdefined( level.flopper_network_optimized ) && level.flopper_network_optimized )
        attacker thread divetonuke_explode_network_optimized( origin, radius, max_damage, min_damage, "MOD_GRENADE_SPLASH" );
    else
        radiusdamage( origin, radius, max_damage, min_damage, attacker, "MOD_GRENADE_SPLASH" );

    playfx( level._effect["divetonuke_groundhit"], origin );
    attacker playsound( "zmb_phdflop_explo" );
}

custom_vending_precaching()
{
    if ( isdefined( level.zombiemode_using_pack_a_punch ) && level.zombiemode_using_pack_a_punch )
    {
        precacheitem( "zombie_knuckle_crack" );
        precachemodel( "p6_anim_zm_buildable_pap" );
        precachemodel( "p6_anim_zm_buildable_pap_on" );
        precachestring( &"ZOMBIE_PERK_PACKAPUNCH" );
        precachestring( &"ZOMBIE_PERK_PACKAPUNCH_ATT" );
        level._effect["packapunch_fx"] = loadfx( "maps/zombie/fx_zombie_packapunch" );
        level.machine_assets["packapunch"] = spawnstruct();
        level.machine_assets["packapunch"].weapon = "zombie_knuckle_crack";
        level.machine_assets["packapunch"].off_model = "p6_anim_zm_buildable_pap";
        level.machine_assets["packapunch"].on_model = "p6_anim_zm_buildable_pap_on";
    }

    if ( isdefined( level.zombiemode_using_additionalprimaryweapon_perk ) && level.zombiemode_using_additionalprimaryweapon_perk )
    {
        precacheitem( "zombie_perk_bottle_additionalprimaryweapon" );
        precacheshader( "specialty_additionalprimaryweapon_zombies" );
        precachemodel( "zombie_vending_three_gun" );
        precachemodel( "zombie_vending_three_gun_on" );
        precachestring( &"ZOMBIE_PERK_ADDITIONALWEAPONPERK" );
        level._effect["additionalprimaryweapon_light"] = loadfx( "misc/fx_zombie_cola_arsenal_on" );
        level.machine_assets["additionalprimaryweapon"] = spawnstruct();
        level.machine_assets["additionalprimaryweapon"].weapon = "zombie_perk_bottle_additionalprimaryweapon";
        level.machine_assets["additionalprimaryweapon"].off_model = "zombie_vending_three_gun";
        level.machine_assets["additionalprimaryweapon"].on_model = "zombie_vending_three_gun_on";
    }

    if ( isdefined( level.zombiemode_using_deadshot_perk ) && level.zombiemode_using_deadshot_perk )
    {
        precacheitem( "zombie_perk_bottle_deadshot" );
        precacheshader( "specialty_ads_zombies" );
        precachemodel( "zombie_vending_ads" );
        precachemodel( "zombie_vending_ads_on" );
        precachestring( &"ZOMBIE_PERK_DEADSHOT" );
        level._effect["deadshot_light"] = loadfx( "misc/fx_zombie_cola_dtap_on" );
        level.machine_assets["deadshot"] = spawnstruct();
        level.machine_assets["deadshot"].weapon = "zombie_perk_bottle_deadshot";
        level.machine_assets["deadshot"].off_model = "zombie_vending_ads";
        level.machine_assets["deadshot"].on_model = "zombie_vending_ads_on";
    }

    if ( isdefined( level.zombiemode_using_divetonuke_perk ) && level.zombiemode_using_divetonuke_perk )
    {
        level._custom_perks[ "specialty_flakjacket" ].precache_func = ::castaway_divetonuke_precache;
        level._effect["divetonuke_light"] = loadfx( "misc/fx_zombie_cola_dtap_on" );
        level.machine_assets["divetonuke"] = spawnstruct();
        level.machine_assets["divetonuke"].weapon = "zombie_perk_bottle_nuke";
        level.machine_assets["divetonuke"].off_model = "p6_zm_al_vending_nuke";
        level.machine_assets["divetonuke"].on_model = "p6_zm_al_vending_nuke_on";
    }

    if ( isdefined( level.zombiemode_using_doubletap_perk ) && level.zombiemode_using_doubletap_perk )
    {
        precacheitem( "zombie_perk_bottle_doubletap" );
        precacheshader( "specialty_doubletap_zombies" );
        precachemodel( "zombie_vending_doubletap2" );
        precachemodel( "zombie_vending_doubletap2_on" );
        precachestring( &"ZOMBIE_PERK_DOUBLETAP" );
        level._effect["doubletap_light"] = loadfx( "misc/fx_zombie_cola_dtap_on" );
        level.machine_assets["doubletap"] = spawnstruct();
        level.machine_assets["doubletap"].weapon = "zombie_perk_bottle_doubletap";
        level.machine_assets["doubletap"].off_model = "zombie_vending_doubletap2";
        level.machine_assets["doubletap"].on_model = "zombie_vending_doubletap2_on";
    }

    if ( isdefined( level.zombiemode_using_juggernaut_perk ) && level.zombiemode_using_juggernaut_perk )
    {
        precacheitem( "zombie_perk_bottle_jugg" );
        precacheshader( "specialty_juggernaut_zombies" );
        precachemodel( "zombie_vending_jugg" );
        precachemodel( "zombie_vending_jugg_on" );
        precachestring( &"ZOMBIE_PERK_JUGGERNAUT" );
        level._effect["jugger_light"] = loadfx( "misc/fx_zombie_cola_jugg_on" );
        level.machine_assets["juggernog"] = spawnstruct();
        level.machine_assets["juggernog"].weapon = "zombie_perk_bottle_jugg";
        level.machine_assets["juggernog"].off_model = "zombie_vending_jugg";
        level.machine_assets["juggernog"].on_model = "zombie_vending_jugg_on";
    }

    if ( isdefined( level.zombiemode_using_marathon_perk ) && level.zombiemode_using_marathon_perk )
    {
        precacheitem( "zombie_perk_bottle_marathon" );
        precacheshader( "specialty_marathon_zombies" );
        precachemodel( "zombie_vending_marathon" );
        precachemodel( "zombie_vending_marathon_on" );
        precachestring( &"ZOMBIE_PERK_MARATHON" );
        level._effect["marathon_light"] = loadfx( "maps/zombie/fx_zmb_cola_staminup_on" );
        level.machine_assets["marathon"] = spawnstruct();
        level.machine_assets["marathon"].weapon = "zombie_perk_bottle_marathon";
        level.machine_assets["marathon"].off_model = "zombie_vending_marathon";
        level.machine_assets["marathon"].on_model = "zombie_vending_marathon_on";
    }

    if ( isdefined( level.zombiemode_using_revive_perk ) && level.zombiemode_using_revive_perk )
    {
        precacheitem( "zombie_perk_bottle_revive" );
        precacheshader( "specialty_quickrevive_zombies" );
        precachemodel( "zombie_vending_revive" );
        precachemodel( "zombie_vending_revive_on" );
        precachestring( &"ZOMBIE_PERK_QUICKREVIVE" );
        level._effect["revive_light"] = loadfx( "misc/fx_zombie_cola_revive_on" );
        level._effect["revive_light_flicker"] = loadfx( "maps/zombie/fx_zmb_cola_revive_flicker" );
        level.machine_assets["revive"] = spawnstruct();
        level.machine_assets["revive"].weapon = "zombie_perk_bottle_revive";
        level.machine_assets["revive"].off_model = "zombie_vending_revive";
        level.machine_assets["revive"].on_model = "zombie_vending_revive_on";
    }

    if ( isdefined( level.zombiemode_using_sleightofhand_perk ) && level.zombiemode_using_sleightofhand_perk )
    {
        precacheitem( "zombie_perk_bottle_sleight" );
        precacheshader( "specialty_fastreload_zombies" );
        precachemodel( "zombie_vending_sleight" );
        precachemodel( "zombie_vending_sleight_on" );
        precachestring( &"ZOMBIE_PERK_FASTRELOAD" );
        level._effect["sleight_light"] = loadfx( "misc/fx_zombie_cola_on" );
        level.machine_assets["speedcola"] = spawnstruct();
        level.machine_assets["speedcola"].weapon = "zombie_perk_bottle_sleight";
        level.machine_assets["speedcola"].off_model = "zombie_vending_sleight";
        level.machine_assets["speedcola"].on_model = "zombie_vending_sleight_on";
    }

    if ( isdefined( level.zombiemode_using_tombstone_perk ) && level.zombiemode_using_tombstone_perk )
    {
        precacheitem( "zombie_perk_bottle_tombstone" );
        precacheshader( "specialty_tombstone_zombies" );
        precachemodel( "zombie_vending_tombstone" );
        precachemodel( "zombie_vending_tombstone_on" );
        precachemodel( "ch_tombstone1" );
        precachestring( &"ZOMBIE_PERK_TOMBSTONE" );
        level._effect["tombstone_light"] = loadfx( "misc/fx_zombie_cola_on" );
        level.machine_assets["tombstone"] = spawnstruct();
        level.machine_assets["tombstone"].weapon = "zombie_perk_bottle_tombstone";
        level.machine_assets["tombstone"].off_model = "zombie_vending_tombstone";
        level.machine_assets["tombstone"].on_model = "zombie_vending_tombstone_on";
    }

    if ( isdefined( level.zombiemode_using_chugabud_perk ) && level.zombiemode_using_chugabud_perk )
    {
        precacheitem( "zombie_perk_bottle_whoswho" );
        precacheshader( "specialty_quickrevive_zombies" );
        precachemodel( "p6_zm_vending_chugabud" );
        precachemodel( "p6_zm_vending_chugabud_on" );
        precachemodel( "ch_tombstone1" );
        precachestring( &"ZOMBIE_PERK_TOMBSTONE" );
        level._effect["tombstone_light"] = loadfx( "misc/fx_zombie_cola_on" );
        level.machine_assets["whoswho"] = spawnstruct();
        level.machine_assets["whoswho"].weapon = "zombie_perk_bottle_whoswho";
        level.machine_assets["whoswho"].off_model = "p6_zm_vending_chugabud";
        level.machine_assets["whoswho"].on_model = "p6_zm_vending_chugabud_on";
    }

    if ( level._custom_perks.size > 0 )
    {
        a_keys = getarraykeys( level._custom_perks );

        for ( i = 0; i < a_keys.size; i++ )
        {
            if ( isdefined( level._custom_perks[a_keys[i]].precache_func ) )
                level [[ level._custom_perks[a_keys[i]].precache_func ]]();
        }
    }
}

castaway_divetonuke_precache()
{
    precacheitem( "zombie_perk_bottle_nuke" );
    precacheshader( "specialty_divetonuke_zombies" );
    precachemodel( "p6_zm_al_vending_nuke" );
    precachemodel( "p6_zm_al_vending_nuke_on" );
    precachestring( &"ZOMBIE_PERK_DIVETONUKE" );
}