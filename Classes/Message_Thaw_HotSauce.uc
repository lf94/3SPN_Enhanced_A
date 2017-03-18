//Tested and working

class Message_Thaw_HotSauce extends LocalMessage;

/*#exec AUDIO IMPORT FILE=Sounds\Hotsauce.wav GROUP=Sounds

var Sound HotSauceSound;
var localized string YouAreHotSauce;
var localized string PlayerIsHotSauce;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    if(SwitchNum == 1)
	    return default.YouAreHotSauce;
    else
        return RelatedPRI_1.PlayerName@default.PlayerIsHotSauce;

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
		P.ClientPlaySound(default.HotSauceSound);
}

defaultproperties
{
     HotSauceSound=Sound'3SPNv32232.Sounds.Hotsauce'
     YouAreHotSauce="YOU ARE HOT SAUCE!"
     PlayerIsHotSauce="IS HOT SAUCE!"
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
