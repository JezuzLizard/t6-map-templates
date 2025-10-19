_DEFAULT( value, default_value )
{
	if ( !isdefined( value ) )
	{
		return default_value;
	}

	return value;
}

/*generic_obj_t*/ generic_obj_t_new( obj_type )
{
	generic_obj = spawnstruct();
	generic_obj.warning = false;
	generic_obj.errored = false;
	generic_obj.msg = "";
	generic_obj.obj_type = obj_type;
	generic_obj.is_null = false;

	return generic_obj;
}

/*csv_obj_t*/ csv_obj_t_new( row, column )
{
	csv_obj = generic_obj_t_new( "csv_cast" );
	csv_obj.row = row;
	csv_obj.column = column;

	return csv_obj;
}

/*result_obj_t*/ set_cast_error( result_obj, error_msg, expected_value_type )
{
	result_obj.errored = true;
	result_obj.value = undefined;
	result_obj.type = _DEFAULT( expected_value_type, undefined );
	result_obj.msg = error_msg;
	result_obj.is_null = false;

	return result_obj;
}

/*result_obj_t*/ set_cast_success( result_obj, new_value, success_msg, expected_value_type )
{
	result_obj.value = new_value;
	result_obj.msg = success_msg;
	result_obj.type = _DEFAULT( expected_value_type, undefined );
	result_obj.is_null = false;

	return result_obj;
}

/*result_obj_t*/ set_cast_optional( result_obj, new_value, success_msg, expected_value_type )
{
	result_obj = set_cast_success( result_obj, new_value, success_msg, expected_value_type );
	result_obj.is_null = true;
	
	return result_obj;
}

is_str_int( str )
{
	cast_obj = cast_str_to_number( str, "int" );
	return !cast_obj.errored;
}

is_str_natural_int( str )
{
	cast_obj = cast_str_to_number( str, "natural_int" );
	return !cast_obj.errored;
}

is_str_positive_int( str )
{
	cast_obj = cast_str_to_number( str, "positive_int" );
	return !cast_obj.errored;
}

is_str_float( str )
{
	cast_obj = cast_str_to_number( str, "float" );
	return !cast_obj.errored;
}

is_str_positive_float( str )
{
	cast_obj = cast_str_to_number( str, "positive_float" );
	return !cast_obj.errored;
}

/*str_cast_obj_t*/ str_cast_obj_t_new( type, str_value )
{
	str_cast_obj = generic_obj_t_new( "str_cast" );
	str_cast_obj.number_type = type;
	str_cast_obj.str_value = str_value;

	if ( !isdefined( type ) || !isdefined( level._number_strings[ type ] ) )
	{
		assert( false );
		return set_cast_error( str_cast_obj, "Unknown type: " + type );
	}
	if ( !isdefined( str_value ) || str_value == "" )
	{
		assert( false );
		return set_cast_error( str_cast_obj, "Unknown str_value" );
	}
	return str_cast_obj;
}

cast_str_to_number( str, type )
{
	str_cast_obj = str_cast_obj_t_new( type, str );

	if ( str_cast_obj.errored )
	{
		return str_cast_obj;
	}

	if ( str[ 0 ] == "-" )
	{
		if ( type != "float" && type != "int" )
		{
			return set_cast_error( str_cast_obj, "Unexpected negative sign" );
		}
		start_index = 1;
	}
	else 
	{
		start_index = 0;
	}

	syntax = level._number_strings[ type ];

	period_allowed = false;
	if ( type == "float" || type == "positive_float" )
	{
		period_allowed = true;
	}
	
	periods_found = 0;
	if ( str[ str.size - 1 ] == "." )
	{
		return set_cast_error( str_cast_obj, "Trailing decimal point is not allowed" );
	}
	for ( i = start_index; i < _SIZE( str.size ); i++ )
	{
		if ( period_allowed && str[ i ] == "." )
		{
			periods_found++;
			if ( periods_found > 1 )
			{
				return set_cast_error( str_cast_obj, "Cannot have more than one decimal point" );
			}
			continue;
		}
		if ( str[ i ] == "-" )
		{
			return set_cast_error( str_cast_obj, "Succeeding or multiple negative signs are not allowed" );
		}
		if ( !is_numeric( str[ i ] ) )
		{
			return set_cast_error( str_cast_obj, "Invalid character for type '" + type + "': '" + str[ i ] + "'" );
		}
	}

	value = 0;
	switch ( type )
	{
		case "natural_int":
		case "positive_int":
		case "int":
			value = int( str );
			break;
		case "positive_float":
		case "float":
			value = float( str );
			break;
	}

	return set_cast_success( str_cast_obj, value, type + "==" + str );
}

cast_str_to_vector( str )
{
	result_obj = generic_obj_t_new( "vector" );
	float_strs = strTok( str, "," );
	if ( float_strs.size != 3 )
	{
		return set_cast_error( result_obj, "expected vector in format of x,x,x" );
	}

	casted_floats = [];
	for ( i = 0; i < _SIZE( float_strs.size ); i++ )
	{
		casted_floats[ i ] = cast_str_to_number( float_strs[ i ], "float" );
		if ( casted_floats[ i ].errored )
		{
			return set_cast_error( result_obj, "Error at vector component '" + i + "': " + casted_floats[ i ].msg );
		}
	}

	new_vector = ( casted_floats[ 0 ].value, casted_floats[ 1 ].value, casted_floats[ 2 ].value );
	return set_cast_success( result_obj, new_vector, "vector==" + new_vector );
}

cast_bool_to_str( bool, binary_string_options )
{
	options = strTok( binary_string_options, " " );
	if ( options.size == 2 )
	{
		if ( bool )
		{
			return options[ 0 ];
		}
		else 
		{
			return options[ 1 ];
		}
	}
	return bool + "";
}

cast_str_to_bool( str )
{
	lower_str = tolower( str );
	result_obj = generic_obj_t_new( "boolean" );
	result_obj.str = str;
	if ( lower_str == "true" )
	{
		return set_cast_success( result_obj, true, "boolean==true" );
	}
	else if ( lower_str == "false" )
	{
		return set_cast_success( result_obj, false, "boolean==false" );
	}

	return set_cast_error( result_obj, "boolean!=boolean" );
}

cast_str_to_weapon( str )
{
	find = generic_obj_t_new();

	exists = _WEAPON_EXISTS( str );

	if ( !exists )
	{
		return set_cast_error( find, "Weapon: '" + str + "' not precached" );
	}

	return set_cast_success( find, str, "weapon==" + str );
}

_WEAPON_EXISTS( name )
{
	// csc alternative
	return weaponclass( name ) != "none";
}

cast_str_to_model( str )
{
	find = generic_obj_t_new();

	model_exists = _MODEL_EXISTS( str );
	if ( !model_exists )
	{
		return set_cast_error( find, "Model not precached: '" + str + "'" );
	}

	return set_cast_success( find, str, "model==" + str );
}

private delete_after_time( entity )
{
	entity endon( "death" );

	wait 0.05;

	entity delete();
}

private spawn_test_ent()
{
	test_ent = spawn( "script_model", ( 0, 0, -5000 ) );
	level thread delete_after_time( test_ent );

	return test_ent;
}

_MODEL_EXISTS( arg )
{
	test_ent = spawn_test_ent();
	test_ent setmodel( arg );

	if ( test_ent.model == "" )
	{
		test_ent delete();
		return false;
	}

	test_ent delete();
	return true;
}

_OPTIONAL( value )
{
	if ( isdefined( value ) )
	{
		return value;
	}

	return undefined;
}

// this function isn't intended to handle script errors, it just stops infinite loops from happening due to the arr being undefined so they can be caught immediately
// can't use like a method unfortunately as self may not be defined
_SIZE( arr_size )
{
	if ( !isdefined( arr_size ) )
	{
		// exits the loop as undefined is used in a truthy way
		assert( false );
		return 0;
	}

	return arr_size;
}

is_alpha( chr, start, end )
{
	start = _DEFAULT( start, 0 );
	end = _DEFAULT( end, chr.size );
	if ( end > chr.size )
	{
		end = chr.size;
	}
	for ( i = start; i < _SIZE( end ); i++ )
	{
		if ( !isdefined( level._alphabet_array[ chr[ i ] ] ) )
		{
			return false;
		}
	}

	return true;
}

is_alpha_numeric( chr, check_underscore, start, end )
{
	check_underscore = _DEFAULT( check_underscore, false );
	start = _DEFAULT( start, 0 );
	end = _DEFAULT( end, chr.size );
	if ( end > chr.size )
	{
		end = chr.size;
	}
	for ( i = start; i < _SIZE( end ); i++ )
	{
		if ( !isdefined( level._alphabet_array[ tolower( chr[ i ] ) ] ) && !isdefined( level._numeric_array[ chr[ i ] ] ) )
		{
			if ( !check_underscore )
			{
				return false;
			}
			else if ( chr[ i ] != "_" )
			{
				return false;
			}
		}
	}

	return true;
}

is_numeric( chr, start, end )
{
	start = _DEFAULT( start, 0 );
	end = _DEFAULT( end, chr.size );
	if ( end > chr.size )
	{
		end = chr.size;
	}
	for ( i = start; i < end; i++ )
	{
		if ( !isdefined( level._numeric_array[ chr[ i ] ] ) )
		{
			return false;
		}
	}

	return true;
}

set_working_table( table )
{
	if ( !isdefined( table ) )
	{
		// clear it
		level._current_parsing_table = undefined;
		return true;
	}
	test_table = tablelookuprownum( table, 0, 0 );
	if ( !isdefined( test_table ) )
	{
		// table didn't exist...
		return false;
	}

	level._current_parsing_table = table;
	return true;
}

set_working_row_num( row_num )
{
	level._current_working_table_row_num = row_num;
}

get_working_table()
{
	cur_table = level._current_parsing_table;
	if ( !isdefined( cur_table ) || cur_table == "" )
	{
		assert( false );
		return undefined;
	}

	return cur_table;
}

get_csv_float( row, column )
{
	row = _DEFAULT( row, level._current_working_table_row_num );
	str_cast_obj = csv_obj_t_new( row, column );
	table = get_working_table();
	if ( !isdefined( table ) )
	{
		return set_cast_error( str_cast_obj, "Table was not defined!" );
	}

	str = tablelookup( table, 0, row, column );

	if ( str == "" )
	{
		return set_cast_optional( str_cast_obj, undefined, "csv_float==null" );
	}

	return cast_str_to_number( str, "float" );
}

get_csv_int( column, row )
{
	row = _DEFAULT( row, level._current_working_table_row_num );
	str_cast_obj = csv_obj_t_new( row, column );
	table = get_working_table();
	if ( !isdefined( table ) )
	{
		return set_cast_error( str_cast_obj, "Table was not defined!" );
	}

	str = tablelookup( table, 0, row, column );

	if ( str == "" )
	{
		return set_cast_optional( str_cast_obj, undefined, "csv_int==null" );
	}

	return cast_str_to_number( str, "int" );
}

get_csv_str( column, row )
{
	row = _DEFAULT( row, level._current_working_table_row_num );
	str_cast_obj = csv_obj_t_new( row, column );
	table = get_working_table();
	if ( !isdefined( table ) )
	{
		return set_cast_error( str_cast_obj, "Table was not defined!" );
	}

	str = tablelookup( table, 0, row, column );

	if ( str == "" )
	{
		return set_cast_optional( str_cast_obj, undefined, "csv_str==null" );
	}

	return set_cast_success( str_cast_obj, str, "csv_str==" + str );
}

get_csv_bool( column, row )
{
	row = _DEFAULT( row, level._current_working_table_row_num );
	str_cast_obj = csv_obj_t_new( row, column );
	table = get_working_table();
	if ( !isdefined( table ) )
	{
		return set_cast_error( str_cast_obj, "Table was not defined!" );
	}

	str = tablelookup( table, 0, row, column );

	if ( str == "" )
	{
		return set_cast_optional( str_cast_obj, undefined, "csv_bool==null" );
	}

	return cast_str_to_bool( str );
}