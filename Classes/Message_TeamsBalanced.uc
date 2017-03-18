class Message_TeamsBalanced extends LocalMessage;

var string TeamsBalancedString;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
    return default.TeamsBalancedString;
}

defaultproperties
{
	TeamsBalancedString="Teams have been automatically balanced!"
    bIsSpecial=false
	bIsConsoleMessage=true
}
