/* [ Map Icon System - Created by Vasic - 09.07.2019 - v1.0] */
/* [ CMDs: /create & /delete ] */

#include <	a_samp		>
#include <  zcmd        >
#include <  YSI\y_ini   >
#include <  streamer    >
#include <  sscanf2     >

#define MAX_MAPICONS    150 //'150' is the max number of map icons (limit), you can change it.
#define MAPICONS_FILE   "/MapIcons/%d.ini" //name of folder in scriptfiles must be MapIcons, you can change it.

enum miInfo
{
	Float:miX,
	Float:miY,
	Float:miZ,
	miType,
	miVW,
	miInt,
	miDistance
};
new MI[ MAX_MAPICONS ][ miInfo ];
new Icon[ sizeof( MI ) ];
main()
{
}
public OnGameModeInit()
{
	for(new id = 0; id < MAX_MAPICONS; id++)
	{
		new filename[ 32 ];
		format( filename, sizeof( filename ), MAPICONS_FILE, id );
		if( fexist( filename ) )
		{
		    INI_ParseFile( filename, "LoadMapIcons", .bExtra = true, .extra = id );
		    {
	            Icon[ id ] = CreateDynamicMapIcon( MI[ id ][ miX ],MI[ id ][ miY ],MI[ id ][ miZ ], MI[ id ][ miType ], -1, MI[ id ][ miVW ], MI[ id ][ miInt ], -1, MI[ id ][ miDistance ] );
			}
		}
	}
	return 1;
}
stock MINextID( )
{
	new mifile[ 64 ];
	for( new mapid = 0; mapid < MAX_MAPICONS; mapid++ ) {
		format( mifile, sizeof( mifile ), MAPICONS_FILE, mapid );
		if( !fexist( mifile ) ) return mapid;
	}
	return true;
}

stock SaveMapIcons( id ) {
    new miFile[ 60 ];
    format( miFile, sizeof( miFile ), MAPICONS_FILE, id);
    new INI:File = INI_Open(miFile);
    INI_WriteFloat( File, "Postition_X", MI[ id ][ miX ] );
    INI_WriteFloat( File, "Postition_Y", MI[ id ][ miY ] );
    INI_WriteFloat( File, "Postition_Z", MI[ id ][ miZ ] );
    INI_WriteInt( File, "ViewDistance", MI[ id ][ miDistance ] );
	INI_WriteInt( File, "VirtualWorld", MI[ id ][ miVW ] );
	INI_WriteInt( File, "Interior", MI[ id ][ miInt ] );
	INI_WriteInt( File, "Type", MI[ id ][ miType ] );
    INI_Close(File);
}
forward LoadMapIcons( id, name[], value[] );
public LoadMapIcons( id, name[], value[] ) {
    INI_Float( "Postition_X", MI[ id ][ miX ] );
    INI_Float( "Postition_Y", MI[ id ][ miY ] );
    INI_Float( "Postition_Z", MI[ id ][ miZ ] );
    INI_Int( "ViewDistance", MI[ id ][ miDistance ] );
	INI_Int( "VirtualWorld", MI[ id ][ miVW ] );
	INI_Int( "Interior", MI[ id ][ miInt ] );
	INI_Int( "Type", MI[ id ][ miType ] );
    return true;
}

CMD:create( playerid, params[ ] )
{
    if(!IsPlayerAdmin( playerid ) ) return SendClientMessage( playerid, -1,"{f59342}[ERROR]: {FFFFFF}You must be logged as RCON." );
	new mid = MINextID( ), model, vdistance, Float:x, Float:y, Float:z;
	if( sscanf( params, "ii", model, vdistance ) ) return SendClientMessage( playerid, -1, "{f59342}/create {FFFFFF}[model (0-63) | visible distance (100-300)]" );
 	if( mid >= MAX_MAPICONS) return SendClientMessage( playerid, -1, "{f59342}[ERROR]: {FFFFFF}Reached limit of MapIcons." );
 	if( model < 0 || model > 63 ) return SendClientMessage( playerid, -1, "{f59342}[ERROR]: {FFFFFF}Model of MapIcon can not be bigger than 63 and smaller than 0." );
    if( vdistance < 100 || vdistance > 300 ) return SendClientMessage( playerid, -1, "{f59342}[ERROR]: {FFFFFF}Visible Distance can not be bigger than 300 and smaller than 100." );
	GetPlayerPos( playerid, x, y, z );
	MI[ mid ][ miX ] = x;
	MI[ mid ][ miY ] = y;
	MI[ mid ][ miZ ] = z;
	MI[ mid ][ miVW ] = GetPlayerVirtualWorld( playerid );
	MI[ mid ][ miInt ] = GetPlayerInterior( playerid );
	MI[ mid ][ miDistance ] = vdistance;
	MI[ mid ][ miType ] = model;
	Icon[ mid ] = CreateDynamicMapIcon( MI[ mid ][ miX ],MI[ mid ][ miY ],MI[ mid ][ miZ ], MI[ mid ][ miType ], -1, MI[ mid ][ miVW ], MI[ mid ][ miInt ], -1, MI[ mid ][ miDistance ] );
	SaveMapIcons( mid );
	new str[ 140 ];
	format( str, sizeof str, "{f59342}[INFO]: {FFFFFF}You created Map Icon ID = %d", mid );
	SendClientMessage( playerid, -1, str );
	return 1;
}
CMD:delete( playerid, params[ ] )
{
	if(!IsPlayerAdmin( playerid ) ) return SendClientMessage( playerid, -1,"{f59342}[ERROR]: {FFFFFF}You must be logged as RCON." );
 	new i, miFile[ 60 ], str[ 140 ];
 	if( sscanf( params,"i", i ) ) return SendClientMessage( playerid, -1,"{f59342}/delete {FFFFFF}[id]" );
 	format( miFile, sizeof( miFile ), MAPICONS_FILE, i );
	if(fexist( miFile ) )
	{
		MI[ i ][ miX ] = 0.0;
		MI[ i ][ miY ] = 0.0;
		MI[ i ][ miZ ] = 0.0;
		MI[ i ][ miDistance ] = 0;
		DestroyDynamicMapIcon( Icon[ i ] );
		format( str, sizeof( str ), "{f59342}[INFO]: {FFFFFF}You deleted Map Icon ID = %d.", i );
		SendClientMessage( playerid, -1, str );
		format( miFile, sizeof(miFile), MAPICONS_FILE, i );
		if( fexist( miFile ) )
		{
			fremove( miFile );
		}
	}
	else
	{
		SendClientMessage( playerid, -1, "{f59342}[ERROR]: {FFFFFF}You entered invalid ID." );
	}
	return 1;
}
