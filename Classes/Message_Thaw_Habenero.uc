//Tested and working

class Message_Thaw_Habenero extends LocalMessage;

/*#exec AUDIO IMPORT FILE=Sounds\Habenero.wav GROUP=Sounds

var Sound HabeneroSound;
var localized string YouAreHabenero;
var localized string PlayerIsHabenero;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
    if(SwitchNum == 1)
	    return default.YouAreHabenero;
    else
        return RelatedPRI_1.PlayerName@default.PlayerIsHabenero;
	
}

static simulated function ClientReceive(
	PlayerController P,
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, SwitchNum, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	if(SwitchNum==1)
		P.ClientPlaySound(default.HabeneroSound);
}

defaultproperties
{
     HabeneroSound=Sound'3SPN_Enhanced_A.Sounds.Habenero'   //todo: get correct Habenaro.wav
     YouAreHabenero="YOU ARE A HABENERO!"
     PlayerIsHabenero="IS A HABENERO!"
     bIsUnique=True
     bFadeMessage=True
     Lifetime=5
     DrawColor=(R=0)
     StackMode=SM_Down
     PosY=0.100000
}*/
defaultproperties
{
}
