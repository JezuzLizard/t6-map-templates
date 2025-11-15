#include clientscripts\mp\_utility;
#include clientscripts\mp\zombies\_zm_weapons;
#include clientscripts\mp\zombies\_zm_utility;
#include clientscripts\mp\zombies\_zm_weap_thundergun;
#include clientscripts\mp\zombies\_zm_weap_cymbal_monkey;

// setup autoexecs
#include clientscripts\mp\karma_fx;

main()
{
	clientscripts\mp\maptypes\_zm_usermap::setup_zombie_defaults();

	// you can edit the tables or redirect these calls to your map script
	clientscripts\mp\maptypes\_zm_usermap::include_weapons(); // zm/include_weapons.csv
	clientscripts\mp\maptypes\_zm_usermap::include_powerups(); // zm/include_powerups.csv
	clientscripts\mp\maptypes\_zm_usermap::include_fx(); // zm/include_fx.csv

    level.zombiemode_using_pack_a_punch = 1;
    level.zombiemode_reusing_pack_a_punch = 0;
    level.zombiemode_using_revive_perk = 1;
    level.zombiemode_using_juggernaut_perk = 1;
    level.zombiemode_using_marathon_perk = 1;
    level.zombiemode_using_doubletap_perk = 1;
    level.zombiemode_using_sleightofhand_perk = 1;
    level.zombiemode_using_tombstone_perk = 0;

	// blue
	level._override_eye_fx = level._effect["blue_eyes"];
	
	clientscripts\mp\maptypes\_zm_usermap::start_zombie_mode();

	// monkeys have to be initialized after _zm:init()
	level.legacy_cymbal_monkey = 1;
	clientscripts\mp\zombies\_zm_weap_cymbal_monkey::init();
	clientscripts\mp\zombies\_zm_weap_thundergun::init();

	thread clientscripts\mp\karma_amb::main();
	thread clientscripts\mp\karma_gump::karma_gump_init();

	waitforclient( 0 );
	println( "*** Client : '" + level.script + "' map running..." );
}