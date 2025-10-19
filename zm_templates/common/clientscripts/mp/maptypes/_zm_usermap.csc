#include clientscripts\mp\_utility;
#include clientscripts\mp\zombies\_zm_utility;
#include clientscripts\mp\zombies\_zm_powerups;
#include clientscripts\mp\zombies\_zm_weapons;

#include clientscripts\mp\maptypes\_zm_usermap_utility;

call_function_safe( func, threaded )
{
	threaded = isdefined( threaded ) ? threaded : false;
	if ( !isdefined( func ) )
	{
		assert( false );
		return false;
	}

	level thread [[ func ]]();

	return true;
}

setup_zombie_defaults()
{
	level.script = getdvar( "mapname" );
	level.gametype = getdvar( "g_gametype" );
	level.default_start_location = level.script;
	level.default_game_mode = level.gametype;
	level._no_water_risers = 1;
	level._no_navcards = true;
	level.riser_fx_on_client = 1;
	level.setupcustomcharacterexerts = ::setup_personality_character_exerts;
	level.raygun2_included = 1;
	level._is_clienside = true; // runtime checks instead of optimizing for csc

	level._alphabet_array = [];

	alpha_string = "abcdefghijklmnopqrstuvwxyz";

	for ( i = 0; i < alpha_string.size; i++ )
	{
		level._alphabet_array[ alpha_string[ i ] ] = i;
	}

	level._numeric_array = [];

	numeric_string = "0123456789";

	for ( i = 0; i < numeric_string.size; i++ )
	{
		level._numeric_array[ numeric_string[ i ] ] = i;
	}

	level._number_strings = [];
	level._number_strings[ "float" ] = "-.0123456789";
	level._number_strings[ "positive_float" ] = ".0123456789";
	level._number_strings[ "int" ] = "-0123456789";
	level._number_strings[ "positive_int" ] = "0123456789";
	level._number_strings[ "natural_int" ] = "123456789";

	level._include_fx_columns = [];
	level._include_fx_columns[ level._include_fx_columns.size ] = "index";
	level._include_fx_columns[ level._include_fx_columns.size ] = "fx_name";
	level._include_fx_columns[ level._include_fx_columns.size ] = "asset_name";

	level._add_zombie_weapons = [];
	level._add_zombie_weapons[ level._add_zombie_weapons.size ] = "index";
	level._add_zombie_weapons[ level._add_zombie_weapons.size ] = "weapon_name";
	level._add_zombie_weapons[ level._add_zombie_weapons.size ] = "upgrade_name";
	level._add_zombie_weapons[ level._add_zombie_weapons.size ] = "hint";
	level._add_zombie_weapons[ level._add_zombie_weapons.size ] = "cost";
	level._add_zombie_weapons[ level._add_zombie_weapons.size ] = "weapon_voice_over";
	level._add_zombie_weapons[ level._add_zombie_weapons.size ] = "weapon_voice_over_response";
	level._add_zombie_weapons[ level._add_zombie_weapons.size ] = "ammo_cost";
	level._add_zombie_weapons[ level._add_zombie_weapons.size ] = "create_vox";
	level._add_zombie_weapons[ level._add_zombie_weapons.size ] = "in_box";
	level._add_zombie_weapons[ level._add_zombie_weapons.size ] = "box_limit";

	level._include_powerups_columns = [];
	level._include_powerups_columns[ level._include_powerups_columns.size ] = "index";
	level._include_powerups_columns[ level._include_powerups_columns.size ] = "powerup_name";
}

start_zombie_mode()
{
	clientscripts\mp\zombies\_zm::init();
	clientscripts\mp\_teamset_cdc::level_init();
	level thread clientscripts\mp\zombies\_zm::init_perk_machines_fx();
}

assert_include_weapon_success( weapon_name )
{
	assert( _WEAPON_EXISTS( weapon_name ) ); // precached failed...
}

include_weapons()
{
	succeeded = set_working_table( "zm/zm_weapons.csv" );
	if ( !succeeded )
	{
		// no "zm/zm_weapons.csv" was found to parse, user will need to define the add weapons manually
		assert( false );
		return;
	}

	table = get_working_table();
	level._usermap_add_weapons = [];
	for ( index = 0; tablelookuprownum( table, 0, index ) != -1; index++ )
	{
		set_working_row_num( index );
		weapon_name_res = get_csv_str( 1 ); // required
		// box logic section, formerly include_weapons.csv
		in_box_res = get_csv_str( 9 ); // optional

		if ( !in_box_res.is_null )
		{
			include_weapon( weapon_name_res.value, in_box_res.value );
		}
		else
		{
			include_weapon( weapon_name_res.value );
		}

		assert_include_weapon_success( weapon_name_res.value );
	}

	set_working_table( undefined );
	set_working_row_num( undefined );
}

assert_include_powerup_entry( powerup_res )
{
	assert( !powerup_res.is_null );
	assert( !powerup_res.errored );

	success = !powerup_res.is_null && !powerup_res.errored;
	return success;
}

include_powerups()
{
	succeeded = set_working_table( "zm/include_powerups.csv" );
	if ( !succeeded )
	{
		// no "zm/include_powerups.csv" was found to parse, user will need to define the powerups manually
		assert( false );
		return;
	}

	table = get_working_table();
	for ( index = 0; tablelookuprownum( table, 0, index ) != -1; index++ )
	{
		set_working_row_num( index );
		powerup_name_res = get_csv_str( 1 ); // required

		if ( !assert_include_powerup_entry( powerup_name_res ) )
		{
			continue;
		}

		include_powerup( powerup_name_res.value );
	}

	set_working_table( undefined );
	set_working_row_num( undefined );
}

assert_include_fx_success( fx_alias, asset_name )
{
	if ( !isdefined( level._effect[ fx_alias ] ) )
	{
		assert( false );
		println( "*******Missing map fx, alias: '" + fx_alias + "', asset: '" + asset_name + "'" );
	}
}

add_map_fx( fx_alias, asset_name )
{
	level._effect[ fx_alias ] = loadfx( asset_name );
	assert_include_fx_success( fx_alias, asset_name );
}

assert_include_fx_entry( alias_res, asset_res, override_res )
{
	assert( !alias_res.errored );
	assert( !alias_res.is_null );
	assert( !asset_res.errored );
	assert( !asset_res.is_null );
	assert( !override_res.errored );
	if ( !override_res.value )
	{
		assert( !isdefined( level._effect[ alias_res.value ] ) );
	}
	
	override_allowed = override_res.value;
	if ( !alias_res.errored && !alias_res.is_null && isdefined( level._effect[ alias_res.value ] ) )
	{
		if ( !override_allowed )
		{
			return false;
		}
	}

	success = !alias_res.errored && !alias_res.is_null && !asset_res.errored && !asset_res.is_null;
	return success;
}

include_fx()
{
	succeeded = set_working_table( "zm/include_fx.csv" );
	if ( !succeeded )
	{
		// no "zm/include_fx.csv" was found to parse, user will need to define the fx manually
		assert( false );
		return;
	}

	table = get_working_table();
	for ( index = 0; tablelookuprownum( table, 0, index ) != -1; index++ )
	{
		set_working_row_num( index );
		alias_res = get_csv_str( 1 ); // required
		asset_res = get_csv_str( 2 ); // required
		override_res = get_csv_bool( 3 ); // optional
		override_res.value = _DEFAULT( override_res.value, false );

		if ( !assert_include_fx_entry( alias_res, asset_res, override_res ) )
		{
			continue;
		}

		add_map_fx( alias_res.value, asset_res.value );
	}

	set_working_table( undefined );
	set_working_row_num( undefined );
}

setup_personality_character_exerts()
{
	level.exert_sounds[1]["playerbreathinsound"][0] = "vox_plr_0_exert_inhale_0";
	level.exert_sounds[1]["playerbreathinsound"][1] = "vox_plr_0_exert_inhale_1";
	level.exert_sounds[1]["playerbreathinsound"][2] = "vox_plr_0_exert_inhale_2";
	level.exert_sounds[2]["playerbreathinsound"][0] = "vox_plr_0_exert_inhale_0";
	level.exert_sounds[2]["playerbreathinsound"][1] = "vox_plr_0_exert_inhale_1";
	level.exert_sounds[2]["playerbreathinsound"][2] = "vox_plr_0_exert_inhale_2";
	level.exert_sounds[3]["playerbreathinsound"][0] = "vox_plr_2_exert_inhale_0";
	level.exert_sounds[3]["playerbreathinsound"][1] = "vox_plr_2_exert_inhale_1";
	level.exert_sounds[3]["playerbreathinsound"][2] = "vox_plr_2_exert_inhale_2";
	level.exert_sounds[4]["playerbreathinsound"][0] = "vox_plr_3_exert_inhale_0";
	level.exert_sounds[4]["playerbreathinsound"][1] = "vox_plr_3_exert_inhale_1";
	level.exert_sounds[4]["playerbreathinsound"][2] = "vox_plr_3_exert_inhale_2";
	level.exert_sounds[1]["playerbreathoutsound"][0] = "vox_plr_0_exert_exhale_0";
	level.exert_sounds[1]["playerbreathoutsound"][1] = "vox_plr_0_exert_exhale_1";
	level.exert_sounds[1]["playerbreathoutsound"][2] = "vox_plr_0_exert_exhale_2";
	level.exert_sounds[2]["playerbreathoutsound"][0] = "vox_plr_1_exert_exhale_0";
	level.exert_sounds[2]["playerbreathoutsound"][1] = "vox_plr_1_exert_exhale_1";
	level.exert_sounds[2]["playerbreathoutsound"][2] = "vox_plr_1_exert_exhale_2";
	level.exert_sounds[3]["playerbreathoutsound"][0] = "vox_plr_2_exert_exhale_0";
	level.exert_sounds[3]["playerbreathoutsound"][1] = "vox_plr_2_exert_exhale_1";
	level.exert_sounds[3]["playerbreathoutsound"][2] = "vox_plr_2_exert_exhale_2";
	level.exert_sounds[4]["playerbreathoutsound"][0] = "vox_plr_3_exert_exhale_0";
	level.exert_sounds[4]["playerbreathoutsound"][1] = "vox_plr_3_exert_exhale_1";
	level.exert_sounds[4]["playerbreathoutsound"][2] = "vox_plr_3_exert_exhale_2";
	level.exert_sounds[1]["playerbreathgaspsound"][0] = "vox_plr_0_exert_exhale_0";
	level.exert_sounds[1]["playerbreathgaspsound"][1] = "vox_plr_0_exert_exhale_1";
	level.exert_sounds[1]["playerbreathgaspsound"][2] = "vox_plr_0_exert_exhale_2";
	level.exert_sounds[2]["playerbreathgaspsound"][0] = "vox_plr_1_exert_exhale_0";
	level.exert_sounds[2]["playerbreathgaspsound"][1] = "vox_plr_1_exert_exhale_1";
	level.exert_sounds[2]["playerbreathgaspsound"][2] = "vox_plr_1_exert_exhale_2";
	level.exert_sounds[3]["playerbreathgaspsound"][0] = "vox_plr_2_exert_exhale_0";
	level.exert_sounds[3]["playerbreathgaspsound"][1] = "vox_plr_2_exert_exhale_1";
	level.exert_sounds[3]["playerbreathgaspsound"][2] = "vox_plr_2_exert_exhale_2";
	level.exert_sounds[4]["playerbreathgaspsound"][0] = "vox_plr_3_exert_exhale_0";
	level.exert_sounds[4]["playerbreathgaspsound"][1] = "vox_plr_3_exert_exhale_1";
	level.exert_sounds[4]["playerbreathgaspsound"][2] = "vox_plr_3_exert_exhale_2";
	level.exert_sounds[1]["falldamage"][0] = "vox_plr_0_exert_pain_low_0";
	level.exert_sounds[1]["falldamage"][1] = "vox_plr_0_exert_pain_low_1";
	level.exert_sounds[1]["falldamage"][2] = "vox_plr_0_exert_pain_low_2";
	level.exert_sounds[1]["falldamage"][3] = "vox_plr_0_exert_pain_low_3";
	level.exert_sounds[1]["falldamage"][4] = "vox_plr_0_exert_pain_low_4";
	level.exert_sounds[1]["falldamage"][5] = "vox_plr_0_exert_pain_low_5";
	level.exert_sounds[1]["falldamage"][6] = "vox_plr_0_exert_pain_low_6";
	level.exert_sounds[1]["falldamage"][7] = "vox_plr_0_exert_pain_low_7";
	level.exert_sounds[2]["falldamage"][0] = "vox_plr_1_exert_pain_low_0";
	level.exert_sounds[2]["falldamage"][1] = "vox_plr_1_exert_pain_low_1";
	level.exert_sounds[2]["falldamage"][2] = "vox_plr_1_exert_pain_low_2";
	level.exert_sounds[2]["falldamage"][3] = "vox_plr_1_exert_pain_low_3";
	level.exert_sounds[2]["falldamage"][4] = "vox_plr_1_exert_pain_low_4";
	level.exert_sounds[2]["falldamage"][5] = "vox_plr_1_exert_pain_low_5";
	level.exert_sounds[2]["falldamage"][6] = "vox_plr_1_exert_pain_low_6";
	level.exert_sounds[2]["falldamage"][7] = "vox_plr_1_exert_pain_low_7";
	level.exert_sounds[3]["falldamage"][0] = "vox_plr_2_exert_pain_low_0";
	level.exert_sounds[3]["falldamage"][1] = "vox_plr_2_exert_pain_low_1";
	level.exert_sounds[3]["falldamage"][2] = "vox_plr_2_exert_pain_low_2";
	level.exert_sounds[3]["falldamage"][3] = "vox_plr_2_exert_pain_low_3";
	level.exert_sounds[3]["falldamage"][4] = "vox_plr_2_exert_pain_low_4";
	level.exert_sounds[3]["falldamage"][5] = "vox_plr_2_exert_pain_low_5";
	level.exert_sounds[3]["falldamage"][6] = "vox_plr_2_exert_pain_low_6";
	level.exert_sounds[3]["falldamage"][7] = "vox_plr_2_exert_pain_low_7";
	level.exert_sounds[4]["falldamage"][0] = "vox_plr_3_exert_pain_low_0";
	level.exert_sounds[4]["falldamage"][1] = "vox_plr_3_exert_pain_low_1";
	level.exert_sounds[4]["falldamage"][2] = "vox_plr_3_exert_pain_low_2";
	level.exert_sounds[4]["falldamage"][3] = "vox_plr_3_exert_pain_low_3";
	level.exert_sounds[4]["falldamage"][4] = "vox_plr_3_exert_pain_low_4";
	level.exert_sounds[4]["falldamage"][5] = "vox_plr_3_exert_pain_low_5";
	level.exert_sounds[4]["falldamage"][6] = "vox_plr_3_exert_pain_low_6";
	level.exert_sounds[4]["falldamage"][7] = "vox_plr_3_exert_pain_low_7";
	level.exert_sounds[1]["mantlesoundplayer"][0] = "vox_plr_0_exert_grunt_0";
	level.exert_sounds[1]["mantlesoundplayer"][1] = "vox_plr_0_exert_grunt_1";
	level.exert_sounds[1]["mantlesoundplayer"][2] = "vox_plr_0_exert_grunt_2";
	level.exert_sounds[1]["mantlesoundplayer"][3] = "vox_plr_0_exert_grunt_3";
	level.exert_sounds[1]["mantlesoundplayer"][4] = "vox_plr_0_exert_grunt_4";
	level.exert_sounds[1]["mantlesoundplayer"][5] = "vox_plr_0_exert_grunt_5";
	level.exert_sounds[1]["mantlesoundplayer"][6] = "vox_plr_0_exert_grunt_6";
	level.exert_sounds[2]["mantlesoundplayer"][0] = "vox_plr_1_exert_grunt_0";
	level.exert_sounds[2]["mantlesoundplayer"][1] = "vox_plr_1_exert_grunt_1";
	level.exert_sounds[2]["mantlesoundplayer"][2] = "vox_plr_1_exert_grunt_2";
	level.exert_sounds[2]["mantlesoundplayer"][3] = "vox_plr_1_exert_grunt_3";
	level.exert_sounds[2]["mantlesoundplayer"][4] = "vox_plr_1_exert_grunt_4";
	level.exert_sounds[2]["mantlesoundplayer"][5] = "vox_plr_1_exert_grunt_5";
	level.exert_sounds[2]["mantlesoundplayer"][6] = "vox_plr_1_exert_grunt_6";
	level.exert_sounds[3]["mantlesoundplayer"][0] = "vox_plr_2_exert_grunt_0";
	level.exert_sounds[3]["mantlesoundplayer"][1] = "vox_plr_2_exert_grunt_1";
	level.exert_sounds[3]["mantlesoundplayer"][2] = "vox_plr_2_exert_grunt_2";
	level.exert_sounds[3]["mantlesoundplayer"][3] = "vox_plr_2_exert_grunt_3";
	level.exert_sounds[3]["mantlesoundplayer"][4] = "vox_plr_2_exert_grunt_4";
	level.exert_sounds[3]["mantlesoundplayer"][5] = "vox_plr_2_exert_grunt_5";
	level.exert_sounds[3]["mantlesoundplayer"][6] = "vox_plr_2_exert_grunt_6";
	level.exert_sounds[4]["mantlesoundplayer"][0] = "vox_plr_3_exert_grunt_0";
	level.exert_sounds[4]["mantlesoundplayer"][1] = "vox_plr_3_exert_grunt_1";
	level.exert_sounds[4]["mantlesoundplayer"][2] = "vox_plr_3_exert_grunt_2";
	level.exert_sounds[4]["mantlesoundplayer"][3] = "vox_plr_3_exert_grunt_3";
	level.exert_sounds[4]["mantlesoundplayer"][4] = "vox_plr_3_exert_grunt_4";
	level.exert_sounds[4]["mantlesoundplayer"][5] = "vox_plr_3_exert_grunt_5";
	level.exert_sounds[4]["mantlesoundplayer"][6] = "vox_plr_3_exert_grunt_6";
	level.exert_sounds[1]["meleeswipesoundplayer"][0] = "vox_plr_0_exert_knife_swipe_0";
	level.exert_sounds[1]["meleeswipesoundplayer"][1] = "vox_plr_0_exert_knife_swipe_1";
	level.exert_sounds[1]["meleeswipesoundplayer"][2] = "vox_plr_0_exert_knife_swipe_2";
	level.exert_sounds[1]["meleeswipesoundplayer"][3] = "vox_plr_0_exert_knife_swipe_3";
	level.exert_sounds[1]["meleeswipesoundplayer"][4] = "vox_plr_0_exert_knife_swipe_4";
	level.exert_sounds[1]["meleeswipesoundplayer"][5] = "vox_plr_0_exert_knife_swipe_5";
	level.exert_sounds[2]["meleeswipesoundplayer"][0] = "vox_plr_1_exert_knife_swipe_0";
	level.exert_sounds[2]["meleeswipesoundplayer"][1] = "vox_plr_1_exert_knife_swipe_1";
	level.exert_sounds[2]["meleeswipesoundplayer"][2] = "vox_plr_1_exert_knife_swipe_2";
	level.exert_sounds[2]["meleeswipesoundplayer"][3] = "vox_plr_1_exert_knife_swipe_3";
	level.exert_sounds[2]["meleeswipesoundplayer"][4] = "vox_plr_1_exert_knife_swipe_4";
	level.exert_sounds[2]["meleeswipesoundplayer"][5] = "vox_plr_1_exert_knife_swipe_5";
	level.exert_sounds[3]["meleeswipesoundplayer"][0] = "vox_plr_2_exert_knife_swipe_0";
	level.exert_sounds[3]["meleeswipesoundplayer"][1] = "vox_plr_2_exert_knife_swipe_1";
	level.exert_sounds[3]["meleeswipesoundplayer"][2] = "vox_plr_2_exert_knife_swipe_2";
	level.exert_sounds[3]["meleeswipesoundplayer"][3] = "vox_plr_2_exert_knife_swipe_3";
	level.exert_sounds[3]["meleeswipesoundplayer"][4] = "vox_plr_2_exert_knife_swipe_4";
	level.exert_sounds[3]["meleeswipesoundplayer"][5] = "vox_plr_2_exert_knife_swipe_5";
	level.exert_sounds[4]["meleeswipesoundplayer"][0] = "vox_plr_3_exert_knife_swipe_0";
	level.exert_sounds[4]["meleeswipesoundplayer"][1] = "vox_plr_3_exert_knife_swipe_1";
	level.exert_sounds[4]["meleeswipesoundplayer"][2] = "vox_plr_3_exert_knife_swipe_2";
	level.exert_sounds[4]["meleeswipesoundplayer"][3] = "vox_plr_3_exert_knife_swipe_3";
	level.exert_sounds[4]["meleeswipesoundplayer"][4] = "vox_plr_3_exert_knife_swipe_4";
	level.exert_sounds[4]["meleeswipesoundplayer"][5] = "vox_plr_3_exert_knife_swipe_5";
	level.exert_sounds[1]["dtplandsoundplayer"][0] = "vox_plr_0_exert_pain_medium_0";
	level.exert_sounds[1]["dtplandsoundplayer"][1] = "vox_plr_0_exert_pain_medium_1";
	level.exert_sounds[1]["dtplandsoundplayer"][2] = "vox_plr_0_exert_pain_medium_2";
	level.exert_sounds[1]["dtplandsoundplayer"][3] = "vox_plr_0_exert_pain_medium_3";
	level.exert_sounds[2]["dtplandsoundplayer"][0] = "vox_plr_1_exert_pain_medium_0";
	level.exert_sounds[2]["dtplandsoundplayer"][1] = "vox_plr_1_exert_pain_medium_1";
	level.exert_sounds[2]["dtplandsoundplayer"][2] = "vox_plr_1_exert_pain_medium_2";
	level.exert_sounds[2]["dtplandsoundplayer"][3] = "vox_plr_1_exert_pain_medium_3";
	level.exert_sounds[3]["dtplandsoundplayer"][0] = "vox_plr_2_exert_pain_medium_0";
	level.exert_sounds[3]["dtplandsoundplayer"][1] = "vox_plr_2_exert_pain_medium_1";
	level.exert_sounds[3]["dtplandsoundplayer"][2] = "vox_plr_2_exert_pain_medium_2";
	level.exert_sounds[3]["dtplandsoundplayer"][3] = "vox_plr_2_exert_pain_medium_3";
	level.exert_sounds[4]["dtplandsoundplayer"][0] = "vox_plr_3_exert_pain_medium_0";
	level.exert_sounds[4]["dtplandsoundplayer"][1] = "vox_plr_3_exert_pain_medium_1";
	level.exert_sounds[4]["dtplandsoundplayer"][2] = "vox_plr_3_exert_pain_medium_2";
	level.exert_sounds[4]["dtplandsoundplayer"][3] = "vox_plr_3_exert_pain_medium_3";
}