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
#include maps\mp\karma_fx;

main()
{
	level.uses_gumps = 1;
	maps\mp\maptypes\_zm_usermap::setup_zombie_defaults();

    // you can edit the tables or redirect these calls to your script
    maps\mp\maptypes\_zm_usermap::include_powerups(); // zm/include_powerups.csv
    maps\mp\maptypes\_zm_usermap::include_fx(); // zm/include_fx.csv
    maps\mp\maptypes\_zm_usermap::add_zombie_weapons(); // zm/add_zombie_weapons.csv

    // map specific setup here
    level.enable_magic = getgametypesetting( "magic" );
    maps\mp\_sticky_grenade::init();
    level._melee_weapons = []; // since we dont have bowie or tazers, init as empty

    level._post_zm_overrides_func = ::karma_post_zm_init;
    level.givecustomloadout = ::givecustomloadout;
    level.zombie_init_done = ::zombie_init_done;
	onplayerconnect_callback( ::karma_connected );
	
    // perk opt ins
    level.zombiemode_using_pack_a_punch = 1;
    level.zombiemode_reusing_pack_a_punch = 1;
    level.zombiemode_using_revive_perk = 1;
    level.zombiemode_using_juggernaut_perk = 1;
    level.zombiemode_using_marathon_perk = 1;
    level.zombiemode_using_doubletap_perk = 1;
    level.zombiemode_using_sleightofhand_perk = 1;
    level.zombiemode_using_tombstone_perk = 0;

    // disable loading random tranzit fx
    level.disable_fx_upgrade_aquired = true;
    level.fx_exclude_tesla_head_light = true;
    level.disable_fx_zmb_tranzit_shield_explo = true;

	level.culldist = 5000;
	setup_characters();

	level.zone_manager_init_func = ::karma_zone_init;
    level.zones = [];

	init_zones[0] = "construction_start_volume";   // spawn room

	//init_zones[1] = "construction_rooms_volume"; // rooms with desks and computers
	//init_zones[2] = "construction_lobby_volume"; // the "system unavailable" desk area
	//init_zones[3] = "construction_crc_volume";   // the security room
	
	maps\mp\maptypes\_zm_usermap::start_zombie_mode( init_zones );
}

karma_post_zm_init()
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
    karma_magicbox_init();
	maps\mp\karma_amb::main();
	//maps\mp\karma_teleporters::init();
	maps\mp\karma_music_egg::init();

	// init thundergun
	maps\mp\zombies\_zm_weap_thundergun::init();
	maps\mp\zombies\_zm_spawner::register_zombie_death_animscript_callback( maps\mp\zombies\_zm_weap_thundergun::enemy_killed_by_thundergun );
	
	// turn them on by default
	turn_on_perks();
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
}

karma_connected()
{
	self setclientdvars( "r_lodbiasskinned", "-1000", "r_lodbiasrigid", "-1000" );
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

karma_zone_init()
{
    flag_init( "always_on" );
    flag_set( "always_on" );

    add_adjacent_zone( "construction_start_volume", "construction_crc_volume", "activate_crc_zone" );
}

karma_magicbox_init()
{
    chest = GetStruct( "karma_crc_chest", "script_noteworthy" );

	// since the map is in development, the box doesnt exist yet
	if ( !IsDefined( chest ) )
	{
		return;
	}

    level.chests = [];
    level.chests[level.chests.size] = chest;
	
    maps\mp\zombies\_zm_magicbox::treasure_chest_init( "karma_crc_chest" );
}

setup_characters()
{
	level.should_use_cia = 1;

	level.precachecustomcharacters = ::precache_team_characters;
	level.givecustomcharacters = ::give_team_characters;
}

precache_team_characters()
{
	precachemodel( "c_zom_player_cia_fb" );
	precachemodel( "c_zom_suit_viewhands" );
}

give_team_characters()
{
	if ( isdefined( level.hotjoin_player_setup ) && [[ level.hotjoin_player_setup ]]( "c_zom_suit_viewhands" ) )
		return;

	self detachall();
	self set_player_is_female( 0 );
	
	self setmodel( "c_zom_player_cia_fb" );
	self setviewmodel( "c_zom_suit_viewhands" );
	self.characterindex = 0;
	self.voice = "american";
	self.skeleton = "base";

	self setmovespeedscale( 1 );
	self setsprintduration( 4 );
	self setsprintcooldown( 0 );
}