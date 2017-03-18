class Message_WinningTeam extends LocalMessage;

var localized string RedTeamWon;
var localized string BlueTeamWon;

var Sound EndCeremonySound;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
    if(SwitchNum == 0)
	    return default.RedTeamWon;
    else
        return default.BlueTeamWon;
}

static simulated function ClientReceive( 
	PlayerController P,
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    if(SwitchNum == 0)
    {
        default.DrawColor.R = 255;
        default.DrawColor.G = 0;
        default.DrawColor.B = 0;
    }
    else
    {
        default.DrawColor.R = 0;
        default.DrawColor.G = 0;
        default.DrawColor.B = 255;
    }

	if(default.EndCeremonySound!=None)
		P.ClientPlaySound(default.EndCeremonySound);
	
	Super.ClientReceive(P, SwitchNum, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

defaultproperties
{
     RedTeamWon="RED TEAM IS THE WINNER!"
     BlueTeamWon="BLUE TEAM IS THE WINNER!"
     bIsUnique=True
     bIsConsoleMessage=False
     bFadeMessage=False
     StackMode=SM_Down
	 FontSize=2
     PosY=0.150000
}
