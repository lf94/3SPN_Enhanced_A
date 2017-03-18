class Misc_DeathMessage extends xDeathMessage;

var color TextColor;

var string Text;

var config bool bDrawColoredNamesInDeathMessages;
var config bool bEnableTeamColoredDeaths;

static function string MakeTeamColor(PlayerReplicationInfo PRI)
{
	if(PRI==None || PRI.Team==None || PRI.Team.TeamIndex>1)
		return class'DMStatsScreen'.static.MakeColorCode(class'Hud'.default.WhiteColor);
	if(PRI.Team.TeamIndex==0)
		return class'DMStatsScreen'.static.MakeColorCode(class'Misc_Player'.default.RedMessageColor);
	return class'DMStatsScreen'.static.MakeColorCode(class'Misc_Player'.default.BlueMessageColor);
}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
	local string KillerName, VictimName;
	local Misc_PRI PRI;

    if(class<DamageType>(OptionalObject) == None)
        return "";

	PRI = Misc_PRI(RelatedPRI_2);
	
    if(RelatedPRI_2 == None)
        VictimName = default.SomeoneString;
    else if(default.bDrawColoredNamesInDeathMessages && PRI!=None && PRI.GetColoredName()!="")
		VictimName = MakeTeamColor(PRI)$PRI.GetColoredName()$class'DMStatsScreen'.static.MakeColorCode(class'HUD'.Default.GreenColor);
    else if(default.bEnableTeamColoredDeaths)
		VictimName = MakeTeamColor(PRI)$RelatedPRI_2.PlayerName$class'DMStatsScreen'.static.MakeColorCode(class'HUD'.Default.GreenColor);
    else
        VictimName = RelatedPRI_2.PlayerName;

    if(Switch == 1)
        return class'GameInfo'.static.ParseKillMessage(KillerName, VictimName, class<DamageType>(OptionalObject).static.SuicideMessage(RelatedPRI_2));

	PRI = Misc_PRI(RelatedPRI_1);
			
    if(RelatedPRI_1 == None)
        KillerName = default.SomeoneString;
    else if(default.bDrawColoredNamesInDeathMessages && PRI!=None && PRI.GetColoredName()!="")
            KillerName = MakeTeamColor(PRI)$PRI.GetColoredName()$class'DMStatsScreen'.static.MakeColorCode(class'HUD'.Default.GreenColor);
    else if(default.bEnableTeamColoredDeaths)
		KillerName = MakeTeamColor(PRI)$RelatedPRI_1.PlayerName$class'DMStatsScreen'.static.MakeColorCode(class'HUD'.Default.GreenColor);
    else
        KillerName = RelatedPRI_1.PlayerName;

    return class'GameInfo'.static.ParseKillMessage(KillerName, VictimName, class<DamageType>(OptionalObject).static.DeathMessage(RelatedPRI_1, RelatedPRI_2));
}

defaultproperties
{
	TextColor=(B=210,G=210,R=210,A=255)
	bEnableTeamColoredDeaths=True
}
