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