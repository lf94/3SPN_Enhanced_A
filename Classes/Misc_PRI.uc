class Misc_PRI extends xPlayerReplicationInfo;

// NR = not automatically replicated

var string ColoredName;

var bool bWarned;               // has been warned for camping (next time will receive penalty) - NR
var int CampCount;              // the number of times penalized for camping - NR
var int ConsecutiveCampCount;   // the number of times penalized for camping consecutively - NR

var int EnemyDamage;            // damage done to enemies - NR
var int AllyDamage;             // damage done to allies and self - NR
var float ReverseFF;            // percentage of friendly fire that is returned - NR

var int FlawlessCount;          // number of flawless victories - NR
var int OverkillCount;          // number of overkills - NR
var int DarkHorseCount;         // number of darkhorses - NR

var int RoxCount;				// number of rocket kills

var int PlayedRounds;           // the number of rounds that the player has played

var float Rank;
var float AvgPPR;

var localized string StringDeadNoRez;

/* hitstats */
struct HitStat
{
    var int Fired;
    var int Hit;
    var int Damage;
};

struct HitStats
{
    var HitStat Primary;
    var HitStat Secondary;
};

var HitStats    Assault;
var HitStat     Bio;
var HitStats    Shock;
var HitStat     Combo;
var HitStats    Link;
var HitStats    Mini;
var HitStats    Flak;
var HitStat     Rockets;
var HitStat     Sniper;

var int         SGDamage;
var int         HeadShots;
var float       AveragePercent;
/* hitstats */

var class<Misc_PawnReplicationInfo> PawnInfoClass;
var Misc_PawnReplicationInfo PawnReplicationInfo;

replication
{
    reliable if(bNetDirty && Role == ROLE_Authority)
        PlayedRounds, PawnReplicationInfo, ColoredName, Rank, AvgPPR;
		
    reliable if(Role<Role_Authority)
        SetColoredName;
}

event PostBeginPlay()
{
    Super.PostBeginPlay();

    if(!bDeleteMe && Level.NetMode != NM_Client)
        PawnReplicationInfo = Spawn(PawnInfoClass, self,, vect(0,0,0), rot(0,0,0));
}

simulated function string GetColoredName()
{
	if(ColoredName=="")
		return PlayerName;
	return ColoredName;
}

function SetColoredName(string S)
{
    ColoredName=S;
}

simulated function string GetLocationName()
{
    if(bOutOfLives && !bOnlySpectator)
        return default.StringDead;
    return Super.GetLocationName();
}

static function string GetFormattedPPR(float val)
{
	local string ret;
	
	if(int((val - int(val)) * 10) < 0)
	{
		if(int(val) == 0)
			ret = "-"$string(int(val));
		else
			ret = string(int(val));
		ret = ret$"."$-int((val - int(val)) * 10);
	}
	else
	{
		ret = string(int(val));
		ret = ret$"."$int((val - int(val)) * 10);
	}
	
	return ret;
}

function Reset()
{
//	Super.Reset();
//	Score = 0;
//	Deaths = 0;
	HasFlag = None;
	bReadyToPlay = false;
	NumLives = 0;
	bOutOfLives = false;
}

function ProcessHitStats()
{
    local int count;

    AveragePercent = 0.0;

    if(Assault.Primary.Fired > 9)
    {
        AveragePercent += class'Misc_StatBoard'.static.GetPercentage(Assault.Primary.Fired, Assault.Primary.Hit);
        count++;
    }

    if(Assault.Secondary.Fired > 2)
    {
        AveragePercent += class'Misc_StatBoard'.static.GetPercentage(Assault.Secondary.Fired, Assault.Secondary.Hit);
        count++;
    }

    if(Bio.Fired > 0)
    {
        AveragePercent += class'Misc_StatBoard'.static.GetPercentage(Bio.Fired, Bio.Hit);
        count++;
    }

    if(Shock.Primary.Fired > 4)
    {
        AveragePercent += class'Misc_StatBoard'.static.GetPercentage(Shock.Primary.Fired, Shock.Primary.Hit);
        count++;
    }

    if(Shock.Secondary.Fired > 4)
    {
        AveragePercent += class'Misc_StatBoard'.static.GetPercentage(Shock.Secondary.Fired, Shock.Secondary.Hit);
        count++;
    }

    if(Combo.Fired > 2)
    {
        AveragePercent += class'Misc_StatBoard'.static.GetPercentage(Combo.Fired, Combo.Hit);
        count++;
    }

    if(Link.Primary.Fired > 9)
    {
        AveragePercent += class'Misc_StatBoard'.static.GetPercentage(Link.Primary.Fired, Link.Primary.Hit);
        count++;
    }

    if(Link.Secondary.Fired > 14)
    {
        AveragePercent += class'Misc_StatBoard'.static.GetPercentage(Link.Secondary.Fired, Link.Secondary.Hit);
        count++;
    }

    if(Mini.Primary.Fired > 19)
    {
        AveragePercent += class'Misc_StatBoard'.static.GetPercentage(Mini.Primary.Fired, Mini.Primary.Hit);
        count++;
    }

    if(Mini.Secondary.Fired > 14)
    {
        AveragePercent += class'Misc_StatBoard'.static.GetPercentage(Mini.Secondary.Fired, Mini.Secondary.Hit);
        count++;
    }

    if(Flak.Primary.Fired > 19)
    {
        AveragePercent += class'Misc_StatBoard'.static.GetPercentage(Flak.Primary.Fired / 9, Flak.Primary.Hit / 9);
        count++;
    }

    if(Flak.Secondary.Fired > 2)
    {
        AveragePercent += class'Misc_StatBoard'.static.GetPercentage(Flak.Secondary.Fired, Flak.Secondary.Hit);
        count++;
    }

    if(Rockets.Fired > 2)
    {
        AveragePercent += class'Misc_StatBoard'.static.GetPercentage(Rockets.Fired, Rockets.Hit);
        count++;
    }

    if(Sniper.Fired > 2)
    {
        AveragePercent += class'Misc_StatBoard'.static.GetPercentage(Sniper.Fired, Sniper.Hit);
        count++;
    }

    if(count > 0)
        AveragePercent /= count;
}

defaultproperties
{
     PawnInfoClass=Class'3SPN_Enhanced_A.Misc_PawnReplicationInfo'
	 StringDeadNoRez="Dead [Inactive]"
}
