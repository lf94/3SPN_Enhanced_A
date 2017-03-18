//player killed needs a towel
class Message_Bukkake extends LocalMessage;

#exec AUDIO IMPORT FILE=Sounds\Bukkake.wav GROUP=Sounds

var Sound BukkakeSound;
var localized string YouGaveBukkake;
var localized string PlayerGaveBukkake;

static function string GetString(
    optional int SwitchNum,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
  if(SwitchNum == 1)
    return default.YouGaveBukkake;
  else
    return RelatedPRI_1.PlayerName@default.PlayerGaveBukkake;
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
        P.ClientPlaySound(default.BukkakeSound);
}

defaultproperties
{
  YouGaveBukkake="YOU GAVE A BUKKAKE!"
  PlayerGaveBukkake="SPLASHED A BUKKAKE!"
  BukkakeSound=Sound'3SPNv32232.Sounds.Bukkake'
  bIsUnique=True
  bFadeMessage=True
  Lifetime=5
  DrawColor=(B=93,G=220,R=126)
  StackMode=SM_Down
  PosY=0.10
}

