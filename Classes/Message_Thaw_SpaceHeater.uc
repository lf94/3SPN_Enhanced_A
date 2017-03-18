//Tested and working

class Message_Thaw_SpaceHeater extends LocalMessage;

/*#exec AUDIO IMPORT FILE=Sounds\Spaceheater.wav GROUP=Sounds

var Sound SpaceHeaterSound;
var localized string YouAreSpaceHeater;
var localized string PlayerIsSpaceHeater;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    if(SwitchNum == 1)
	    return default.YouAreSpaceHeater;
    else
        return RelatedPRI_1.PlayerName@default.PlayerIsSpaceHeater;

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
		P.ClientPlaySound(default.SpaceHeaterSound);
}

defaultproperties
{
     SpaceHeaterSound=Sound'3SPNv32232.Sounds.Spaceheater' //TODO:get correct SpaceHeater.wav
     YouAreSpaceHeater="YOU ARE A SPACE HEATER!"
     PlayerIsSpaceHeater="IS A SPACE HEATER!"
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
