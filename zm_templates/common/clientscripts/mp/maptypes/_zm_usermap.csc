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
}

start_zombie_mode()
{
	clientscripts\mp\zombies\_zm::init();
	clientscripts\mp\_teamset_cdc::level_init();
	level thread clientscripts\mp\zombies\_zm::init_perk_machines_fx();
}

include_weapons()
{
	table = "zm/include_weapons.csv";
	for ( index = 0; tablelookuprownum( table, 0, index ) != -1; index++ )
	{
		weapon_name = tablelookup( table, 0, index, 1 );
		in_box = tablelookup( table, 0, index, 2 );

		in_box_value = false;
		if ( in_box == "" || in_box == "0" || in_box == "false" )
		{
			in_box_value = false;
		}
		else if ( in_box == "1" || in_box == "true" )
		{
			in_box_value = true;
		}

		include_weapon( weapon_name, in_box );
	}
}

include_powerups()
{
	table = "zm/include_powerups.csv";
	for ( index = 0; tablelookuprownum( table, 0, index ) != -1; index++ )
	{
		powerup_name = tablelookup( table, 0, index, 1 );

		include_powerup( powerup_name );
	}
}

add_map_fx( fx_alias, asset_name )
{
	level._effect[ fx_alias ] = loadfx( asset_name );
	if ( !isdefined( level._effect[ fx_alias ] ) )
	{
		assert( false );
		println( "*******Missing map fx, alias: '" + fx_alias + "', asset: '" + asset_name + "'" );
	}
}

include_fx()
{
	table = "zm/include_fx.csv";

	for ( index = 0; tablelookuprownum( table, 0, index ) != -1; index++ )
	{
		fx_alias = tablelookup( table, 0, index, 1 );
		asset_name = tablelookup( table, 0, index, 2 );

		// TODO: assert alias is non colliding, and isdefined
		// TODO: assert asset_name isdefined

		add_map_fx( fx_alias, asset_name );
	}
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