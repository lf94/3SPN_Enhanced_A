class MapLimits3SPNCW extends Actor config(MapLimits3SPNCW);

var config array<string> MapLimits;
var config string LastMapName;

static function bool FindMap(string MapName, out int MinPlayers, out int MaxPlayers, out int Probability, out int Group)
{
  local int P, j;
  local string MapLimitsEntry;
  local array<string> Parts;
  
  // Find the map in the limits list
  for(j=0; j<default.MapLimits.Length; ++j)
  {
    MapLimitsEntry = default.MapLimits[j];  
  
    P = Split(MapLimitsEntry, "?", Parts);
    if(P<1)
      continue;
      
    // Found a match?
    if(Parts[0] ~= MapName)
    {        
      if(P>=2) // Min players
        MinPlayers = int(Parts[1]);
      else
        MinPlayers = 0;
      
      if(P>=3) // Max players
        MaxPlayers = int(Parts[2]);
      else
        MaxPlayers = 999;
        
      if(P>=4) // Selection probability
        Probability = Clamp(int(Parts[3]),0,100);
      else
        Probability = 100;
      
      if(P>=5) // Group
        Group = int(Parts[4]);
      else
        Group = 0;
        
      return true;
    }
  }
  
  return false;
}

static function bool IsSuitableMap(string CurrentMapName, string MapName, int NumPlayers)
{
  local int MinPlayers, MaxPlayers, Probability, NewGroup, CurrentGroup;
  local int Dice;
  
  if(!FindMap(MapName, MinPlayers, MaxPlayers, Probability, NewGroup))
    return true;
    
  if(NumPlayers<MinPlayers || NumPlayers>MaxPlayers)
    return false;

  Dice = int(FRand()*100);
  if(Dice > Probability)
    return false;
    
  if(Len(CurrentMapName)>0 && FindMap(CurrentMapName, MinPlayers, MaxPlayers, Probability, CurrentGroup))
  {
    if(CurrentGroup!=0 && NewGroup!=0)
    {
      if(CurrentGroup == NewGroup)
        return false;
    }
  }
  
  return true;
}

static function SetLastMap(string MapName)
{
  default.LastMapName = MapName;
}

defaultproperties
{
  MapLimits(0)="DM-Rankin?0?999";
}