class Message_ForceAutoBalanceCooldown extends LocalMessage;

var string ForceAutoBalanceCooldownString;
var string ForceAutoBalanceCooldownString2;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
    return default.ForceAutoBalanceCooldownString$SwitchNum$default.ForceAutoBalanceCooldownString2;
}

defaultproperties
{
	ForceAutoBalanceCooldownString="Forced auto balance is on cooldown. Time left: ";
  ForceAutoBalanceCooldownString2=" seconds.";
  bIsSpecial=false
	bIsConsoleMessage=true
}
