//
// file: frontend_amb.csc
// description: clientside ambient script for frontend: setup ambient sounds, etc.
// scripter: 		(initial clientside work - laufer)
//

#include clientscripts\mp\_utility; 
#include clientscripts\mp\_ambientpackage;
#include clientscripts\mp\_music;
#include clientscripts\mp\_busing;
#include clientscripts\mp\_audio;

main()
{
	declaremusicstate( "WAVE" );
	//musicaliasloop( "mus_nuked_underscore", 4, 2 );
	declaremusicstate( "EGG" );
	musicalias( "mus_egg", 1 );
	declaremusicstate( "SILENCE" );
	musicalias( "null", 1 );
}