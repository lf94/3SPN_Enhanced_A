class Message_ForceAutoBalance extends LocalMessage;

var string ForceAutoBalanceString;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
    return default.ForceAutoBalanceString;
}

defaultproperties
{
	ForceAutoBalanceString="Teams will be balanced at round start."
  bIsSpecial=false
	bIsConsoleMessage=true
}
