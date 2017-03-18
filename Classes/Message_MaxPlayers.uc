class Message_MaxPlayers extends LocalMessage;

var string MaxPlayersString;
var string ResumingString0;
var string ResumingString1;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
	if(SwitchNum==0)
		return default.MaxPlayersString;
	return default.ResumingString0$SwitchNum$default.ResumingString1;
}

defaultproperties
{
	MaxPlayersString="The game has been suspended until all players join!"
	ResumingString0="All players have joined. Resuming match in "
	ResumingString1=" seconds..."
    bIsSpecial=false
	bIsConsoleMessage=true
}
