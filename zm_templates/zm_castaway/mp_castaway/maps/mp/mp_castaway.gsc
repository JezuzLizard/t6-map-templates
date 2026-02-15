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
}

castaway_connected()
{
	self setclientdvars( "r_lodbiasskinned", "-1000", "r_lodbiasrigid", "-1000" );

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