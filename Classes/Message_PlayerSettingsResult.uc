class Message_PlayerSettingsResult extends LocalMessage;

var string PlayerName;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
	if(SwitchNum==0)
		return "No settings found. Make sure your stats username is configured.";
	if(SwitchNum==1)
		return "Unable to save settings. Have you configured an unique stats username?";
	if(SwitchNum==2)
		return "Settings loaded.";
	if(SwitchNum==3)
		return "Settings saved.";
	if(SwitchNum==4)
		return "You have loaded settings too recently, please wait 5 seconds and try again!";
	if(SwitchNum==5)
		return "You have saved settings too recently, please wait 5 seconds and try again!";
	if(SwitchNum==6)
		return "Server side settings are currently disabled.";
}

static simulated function ClientReceive( 
	PlayerController P,
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if(SwitchNum<=1)
	{
		default.DrawColor.R = 255;
		default.DrawColor.G = 0;
		default.DrawColor.B = 0;
	}
	else if(SwitchNum<=3)
	{
		default.DrawColor.R = 0;
		default.DrawColor.G = 255;
		default.DrawColor.B = 0;
	}
	else
	{
		default.DrawColor.R = 255;
		default.DrawColor.G = 255;
		default.DrawColor.B = 0;
	}
	
	Super.ClientReceive(P, SwitchNum, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

defaultproperties
{
     bIsUnique=True
     bIsConsoleMessage=True
     bFadeMessage=True
     Lifetime=3
     StackMode=SM_Down
     PosY=0.5000
}
