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
    health_func = getFunction( "maps/mp/zombies/_zm", "ai_calculate_health" );
    if ( isdefined( health_func ) )
    {
        replaceFunc( health_func, ::karma_ai_calculate_health );
    }

	level.uses_gumps = 1;
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

    level._post_zm_overrides_func = ::karma_post_zm_init;
    level.special_weapon_magicbox_check = ::karma_special_weapon_magicbox_check;
    level.givecustomloadout = ::givecustomloadout;
    level.zombie_init_done = ::zombie_init_done;
	onplayerconnect_callback( ::karma_connected );
	
    // perk opt ins
    level.zombiemode_using_pack_a_punch = 1;
    level.zombiemode_reusing_pack_a_punch = 0;
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

	karma_setup_zones();
	setup_characters();
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

setup_characters()
{
	level.precachecustomcharacters = ::precache_team_characters;
	level.givecustomcharacters = ::give_team_characters;

    determine_team_characters();
}

determine_team_characters()
{
    level.should_use_cia = 0;

    if ( randomint( 100 ) >= 50 )
	{
        level.should_use_cia = 1;
	}
}

precache_team_characters()
{
    precachemodel( "c_zom_player_cdc_fb" );
    precachemodel( "c_zom_hazmat_viewhands" );
    precachemodel( "c_zom_player_cia_fb" );
    precachemodel( "c_zom_suit_viewhands" );
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

karma_connected()
{
	self setclientdvars(
        "r_lodbiasskinned", "-1000",
        "r_lodbiasrigid", "-1000",
        "ragdoll_enable", "0"
    );

	// for testing
	if ( GetDvarInt( "zombie_unlock_all" ) > 0 )
	{
		self.score = 500000;
	}
}

karma_setup_zones()
{
	// init zone manager
	level.zone_manager_init_func = ::karma_zone_init;
    level.zones = [];

	// init spawn zone
	init_zones[0] = "construction_volume";
	maps\mp\maptypes\_zm_usermap::start_zombie_mode( init_zones );
}

karma_zone_init()
{
	// security room
	add_adjacent_zone( "construction_volume", "security_volume", "activate_security_zone" );

	// outside the housing
	add_adjacent_zone( "construction_volume", "outer_housing_volume", "activate_housing_zone" );

	// the housing areas
	add_adjacent_zone( "outer_housing_volume", "housing_volume", "activate_housing_zone" );

	// the "system unavailable" desk area
	add_adjacent_zone( "housing_volume", "lobby_volume", "activate_housing_zone" );

	// the elevators hallway
	add_adjacent_zone( "lobby_volume", "elevators_volume", "activate_housing_zone" );
}

karma_magicbox_init()
{
    housing_chest = GetStruct( "housing_chest", "script_noteworthy" );
    security_chest = GetStruct( "security_chest", "script_noteworthy" );
    lobby_chest_1 = GetStruct( "lobby_chest_1", "script_noteworthy" );
    lobby_chest_2 = GetStruct( "lobby_chest_2", "script_noteworthy" );

    level.chests = [];
    level.chests[level.chests.size] = housing_chest;
    level.chests[level.chests.size] = security_chest;
    level.chests[level.chests.size] = lobby_chest_1;
    level.chests[level.chests.size] = lobby_chest_2;

    maps\mp\zombies\_zm_magicbox::treasure_chest_init( "security_chest" );
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
	maps\mp\karma_utility::turn_on_perks();

	// this is originally at -1000, this map's playable areas are lower than that
	set_zombie_var( "below_world_check", -4000 );

	// dog rounds
	maps\mp\zombies\_zm_ai_dogs::enable_dog_rounds();

    karma_fix_glitch_spots();

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

karma_fix_glitch_spots()
{
    // spawn room
    maps\mp\karma_utility::spawn_perk_collision( ( 4495.56, -6456.13, -3527.88 ), ( 0, 0, 0 ) ); // flour pile
    maps\mp\karma_utility::spawn_perk_collision( ( 4626.56, -6316.13, -3527.88 ), ( 0, 0, 0 ) ); // pallet stack
    maps\mp\karma_utility::spawn_perk_collision( ( 5156.56, -6305.13, -3552.88 ), ( 0, 0, 0 ) ); // corner stack
    maps\mp\karma_utility::spawn_perk_collision( ( 5096.56, -6180.13, -3552.88 ), ( 0, 120, 0 ) );

    // housing
    maps\mp\karma_utility::spawn_perk_collision( ( 3777.56, -6555.13, -3462.88 ), ( 0, 120, 0 ) );

    // lobby
    maps\mp\karma_utility::spawn_perk_collision( ( 3787.56, -5340.13, -3512.88 ), ( 90, 0, 0 ) ); // right flower pot
    maps\mp\karma_utility::spawn_perk_collision( ( 3777.56, -5325.13, -3552.88 ), ( 0, 90, 0 ) );
    maps\mp\karma_utility::spawn_perk_collision( ( 3777.56, -5275.13, -3552.88 ), ( 0, 90, 0 ) );
    maps\mp\karma_utility::spawn_perk_collision( ( 3777.56, -5225.13, -3552.88 ), ( 0, 90, 0 ) );
    maps\mp\karma_utility::spawn_perk_collision( ( 3777.56, -5207.13, -3552.88 ), ( 0, 90, 0 ) );

    maps\mp\karma_utility::spawn_perk_collision( ( 3082.56, -5340.13, -3512.88 ), ( 90, 0, 0 ) ); // left flower pot
    maps\mp\karma_utility::spawn_perk_collision( ( 3292.56, -5325.13, -3552.88 ), ( 0, 90, 0 ) );
    maps\mp\karma_utility::spawn_perk_collision( ( 3292.56, -5275.13, -3552.88 ), ( 0, 90, 0 ) );
    maps\mp\karma_utility::spawn_perk_collision( ( 3292.56, -5225.13, -3552.88 ), ( 0, 90, 0 ) );
    maps\mp\karma_utility::spawn_perk_collision( ( 3292.56, -5207.13, -3552.88 ), ( 0, 90, 0 ) );
}

karma_ai_calculate_health( round_number )
{
    level.zombie_health = level.zombie_vars["zombie_health_start"];

    // change: t5 instas
    if ( maps\mp\karma_utility::is_insta_round( round_number ) )
    {
        return;
    }

    for ( i = 2; i <= round_number; i++ )
    {
        if ( i >= 10 )
        {
            old_health = level.zombie_health;
            level.zombie_health = level.zombie_health + int( level.zombie_health * level.zombie_vars["zombie_health_increase_multiplier"] );

            if ( level.zombie_health < old_health )
            {
                level.zombie_health = old_health;
                return;
            }
        }
        else
            level.zombie_health = int( level.zombie_health + level.zombie_vars["zombie_health_increase"] );
    }
}

karma_special_weapon_magicbox_check( weapon )
{
	if ( isdefined( level.raygun2_included ) && level.raygun2_included )
	{
		if ( weapon == "ray_gun_zm" )
		{
			if ( self has_weapon_or_upgrade( "raygun_mark2_zm" ) )
				return false;
		}

		if ( weapon == "raygun_mark2_zm" )
		{
			if ( self has_weapon_or_upgrade( "ray_gun_zm" ) )
				return false;
		}
	}

	return true;
}