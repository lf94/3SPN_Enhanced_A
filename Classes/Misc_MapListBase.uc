class Misc_MapListBase extends MapList dependson(MapLimits3SPNCW);

function string UpdateMapNum(int NewMapNum)
{
  local string CurrentMapName, MapName;
  
	if ( Maps.Length == 0 )
	{
		Warn("No maps configured for game maplist! Unable to change maps!");
		return "";
	}

  if(MapNum>=0 && MapNum<Maps.Length)
    CurrentMapName = Maps[MapNum];
  
  while(true)
	{
		if ( NewMapNum < 0 || NewMapNum >= Maps.Length )
			NewMapNum = 0;

    MapName = Maps[NewMapNum];
      
		if ( NewMapNum == MapNum || MapNum < 0 || MapNum >= Maps.Length )
			break;
   
		if ( class'MapLimits3SPNCW'.static.IsSuitableMap(CurrentMapName,MapName,Level.Game.NumPlayers) && FindCacheIndex( MapName ) != -1 )
        break;

		NewMapNum++;
	}

	MapNum = NewMapNum;
  class'MapLimits3SPNCW'.static.SetLastMap(MapName);
  
	// Notify MaplistHandler of the change in current map
	if ( Level.Game.MaplistHandler != None )
		Level.Game.MaplistHandler.MapChange(MapName);

  class'MapLimits3SPNCW'.static.StaticSaveConfig();
	SaveConfig();
	return MapName;
}

