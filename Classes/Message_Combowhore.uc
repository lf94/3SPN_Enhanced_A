//player killed needs a towel
class Message_Combowhore extends LocalMessage;

#exec AUDIO IMPORT FILE=Sounds\Combowhore.wav GROUP=Sounds

var Sound CombowhoreSound;
var localized string YouAreCombowhore;
var localized string PlayerIsCombowhore;

static function string GetString(
    optional int SwitchNum,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
  if(SwitchNum == 1)
    return default.YouAreCombowhore;
  else
    return RelatedPRI_1.PlayerName@default.PlayerIsCombowhore;
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
        P.ClientPlaySound(default.CombowhoreSound);
}

defaultproperties
{
  YouAreCombowhore="YOU ARE A COMBOWHORE!"
  PlayerIsCombowhore="IS A COMBOWHORE!"
  CombowhoreSound=Sound'3SPNv32232.Sounds.Combowhore'
  bIsUnique=True
  bFadeMessage=True
  Lifetime=5
  DrawColor=(R=196,G=58,B=224)
  StackMode=SM_Down
  PosY=0.10
}

