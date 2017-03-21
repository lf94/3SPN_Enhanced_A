class Freon_Player extends Misc_Player;

var Freon_Pawn FrozenPawn;

replication
{
    reliable if(Role == ROLE_Authority)
        ClientSendStatsFreon, ClientListBestFreon;
}

exec function SwitchTeam()
{
	super.SwitchTeam();
	if(FrozenPawn != None && FrozenPawn.MyTrigger != None)
	{
		FrozenPawn.MyTrigger.Team = GetTeamNum();
		FrozenPawn.MyTrigger.Toucher.Length = 0;
	}
}

exec function ChangeTeam(int N)
{
	super.ChangeTeam(N);
	if(FrozenPawn != None && FrozenPawn.MyTrigger != None)
	{
		FrozenPawn.MyTrigger.Team = GetTeamNum();
		FrozenPawn.MyTrigger.Toucher.Length = 0;
	}
}

function ServerUpdateStatArrays(TeamPlayerReplicationInfo PRI)
{
    local Freon_PRI P;

	if(PRI!=None)
		Super.ServerUpdateStatArrays(PRI);

    P = Freon_PRI(PRI);
    if(P == None)
        return;

    ClientSendStatsFreon(P, P.Thaws, P.Git);
}

function ClientSendStatsFreon(Freon_PRI P, int thaws, int git)
{
    P.Thaws = thaws;
    P.Git = git;
}

function ClientListBestFreon(string acc, string dam, string hs, string th, string gt)
{
	Super.ClientListBest(acc, dam, hs);

    if(class'Misc_Player'.default.bDisableAnnouncement)
        return;
	
    if(th != "")
        ClientMessage(th);
    if(gt != "")
        ClientMessage(gt);
}

function AwardAdrenaline(float amount)
{
    amount *= 0.8;
    Super.AwardAdrenaline(amount);
}

simulated event Destroyed()
{
    if(FrozenPawn != None)
        FrozenPawn.Died(self, class'Suicided', FrozenPawn.Location);

    Super.Destroyed();
}

function BecomeSpectator()
{
    if(FrozenPawn != None)
        FrozenPawn.Died(self, class'DamageType', FrozenPawn.Location);

    Super.BecomeSpectator();
}

function ServerDoCombo(class<Combo> ComboClass)
{
    if(class<ComboSpeed>(ComboClass) != None)
        ComboClass = class<Combo>(DynamicLoadObject("3SPN_Enhanced_A.Freon_ComboSpeed", class'Class'));

    Super.ServerDoCombo(ComboClass);
}

function Reset()
{
    Super.Reset();
    FrozenPawn = None;
}

function Freeze()
{
    if(Pawn == None)
        return;

    FrozenPawn = Freon_Pawn(Pawn);

    bBehindView = true;
    LastKillTime = -5.0;
    EndZoom();

    Pawn.RemoteRole = ROLE_SimulatedProxy;

    Pawn = None;
    PendingMover = None;
	
	NextRezTime = Level.TimeSeconds+1; // 1 second before can be resurrected

    if(!IsInState('GameEnded') && !IsInState('RoundEnded'))
    {
        ServerViewSelf();
        GotoState('Frozen');
    }
}

function ServerViewNextPlayer()
{
    local Controller C, Pick;
    local bool bFound, bRealSpec, bWasSpec;
	local TeamInfo RealTeam;

    bRealSpec = PlayerReplicationInfo.bOnlySpectator;
    bWasSpec = (ViewTarget != FrozenPawn) && (ViewTarget != Pawn) && (ViewTarget != self);
    PlayerReplicationInfo.bOnlySpectator = true;
    RealTeam = PlayerReplicationInfo.Team;

    // view next player
    for ( C=Level.ControllerList; C!=None; C=C.NextController )
    {
		if ( bRealSpec && (C.PlayerReplicationInfo != None) ) // hack fix for invasion spectating
			PlayerReplicationInfo.Team = C.PlayerReplicationInfo.Team;
        if ( Level.Game.CanSpectate(self,bRealSpec,C) )
        {
            if ( Pick == None )
                Pick = C;
            if ( bFound )
            {
                Pick = C;
                break;
            }
            else
                bFound = ( (RealViewTarget == C) || (ViewTarget == C) );
        }
    }
    PlayerReplicationInfo.Team = RealTeam;
    SetViewTarget(Pick);
    ClientSetViewTarget(Pick);

    if(!bWasSpec)
        bBehindView = false;

    ClientSetBehindView(bBehindView);
    PlayerReplicationInfo.bOnlySpectator = bRealSpec;
}


function ServerViewSelf()
{
    if(PlayerReplicationInfo != None)
    {
        if(PlayerReplicationInfo.bOnlySpectator)
        {
            Super.ServerViewSelf();
        }
        else if(FrozenPawn != None)
        {
            SetViewTarget(FrozenPawn);
            ClientSetViewTarget(FrozenPawn);
            bBehindView = true;
            ClientSetBehindView(true);
            ClientMessage(OwnCamera, 'Event');
        }
        else
        {
            if(ViewTarget == None)
            {
                Fire();
            }
            else
            {
                bBehindView = !bBehindView;
                ClientSetBehindView(bBehindView);
            }
        }
    }
}

/*
//dont extend this just re-do it as it's getting unbound / scopeing bug?
state Frozen extends Spectating
{
    exec function AltFire(optional float f)
    {
        ServerViewSelf();
    }
}
*/


//based on Spectating and BaseSpectating from PlayerController.uc
//trying to get round bug where we can't always get back to own camera
state Frozen
{
    ignores SwitchWeapon, RestartLevel, ClientRestart, Suicide,
     ThrowWeapon, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange;

    exec function Fire( optional float F )
    {
        ServerViewNextPlayer();
    }

    // Return to spectator's own camera.
    exec function AltFire( optional float F )
    {
        ServerViewSelf();
    }

    function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
    {
        Acceleration = NewAccel;
        MoveSmooth(SpectateSpeed * Normal(Acceleration) * DeltaTime);
    }

    function PlayerMove(float DeltaTime)
    {
        local vector X,Y,Z;

        if ( (Pawn(ViewTarget) != None) && (Level.NetMode == NM_Client) )
        {
            if ( Pawn(ViewTarget).bSimulateGravity )
                TargetViewRotation.Roll = 0;

            BlendedTargetViewRotation.Pitch = BlendRot(DeltaTime, BlendedTargetViewRotation.Pitch, TargetViewRotation.Pitch & 65535);
            BlendedTargetViewRotation.Yaw = BlendRot(DeltaTime, BlendedTargetViewRotation.Yaw, TargetViewRotation.Yaw & 65535);
            BlendedTargetViewRotation.Roll = BlendRot(DeltaTime, BlendedTargetViewRotation.Roll, TargetViewRotation.Roll & 65535);
        }
        GetAxes(Rotation,X,Y,Z);

        Acceleration = 0.02 * (aForward*X + aStrafe*Y + aUp*vect(0,0,1));

        UpdateRotation(DeltaTime, 1);

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
        else
            ProcessMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
    }


    function BeginState()
    {
        if(Pawn != None)
        {
            SetLocation(Pawn.Location);
            UnPossess();
        }
        
        bCollideWorld = true;
        CameraDist = Default.CameraDist;
    }

    function EndState()
    {
        bCollideWorld = false;
    }
}


function TakeShot()
{
    ConsoleCommand("shot Freon-"$Left(string(Level), InStr(string(Level), "."))$"-"$Level.Month$"-"$Level.Day$"-"$Level.Hour$"-"$Level.Minute);
    bShotTaken = true;
}

defaultproperties
{
     SoundHitVolume=1.026164
     SoundAloneVolume=1.3.2108
     PlayerReplicationInfoClass=Class'3SPN_Enhanced_A.Freon_PRI'
}
