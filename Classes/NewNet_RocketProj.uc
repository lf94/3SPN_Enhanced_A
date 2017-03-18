/*
UTComp - UT2004 Mutator
Copyright (C) 2004-2005 Aaron Everitt & Joël Moffatt

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/
class NewNet_RocketProj extends RocketProj;

var PlayerController PC;
var vector DesiredDeltaFake;
var float CurrentDeltaFakeTime;
var bool bInterpFake;
var bool bOwned;

var NewNet_FakeProjectileManager FPM;

var int Index;

replication
{
    reliable if(Role == Role_Authority && bNetInitial)
       Index;
    unreliable if(bDemoRecording)
       DoMove, DoSetLoc;
}

const INTERP_TIME = 0.50;

simulated function PostNetBeginPlay()
{
    super.PostNetBeginPlay();
    if(Level.NetMode != NM_Client)
        return;

    PC = Level.GetLocalPlayerController();
    if (CheckOwned())
       CheckForFakeProj();
}

simulated function bool CheckOwned()
{
	if(class'Misc_Player'.default.bEnableEnhancedNetCode==False)
		return false;
    bOwned = (PC!=None && PC.Pawn!=None && PC.Pawn == Instigator);
    return bOwned;
}

simulated function DoMove(Vector V)
{
    Move(V);
}

simulated function DoSetLoc(Vector V)
{
    SetLocation(V);
}


simulated function bool CheckForFakeProj()
{
     local float ping;
     local Projectile FP;

     ping = FMax(0.0, Class'NewNet_PRI'.default.PredictedPing - 0.5*Class'NewNet_TimeStamp'.default.AverDT);

    if(FPM==None)
	{
        FindFPM();
		if(FPM==None)
			return false;
	}
		
     FP = FPM.GetFP(Class'NewNet_Fake_RocketProj', index);
     if(FP != none)
     {
         bInterpFake=true;
         DesiredDeltaFake = Location - FP.Location;
         DoSetLoc(FP.Location);
         FPM.RemoveProjectile(FP);
         bOwned=False;
         return true;
     }
     return false;
}



simulated function FindFPM()
{
    foreach DynamicActors(Class'NewNet_FakeProjectileManager', FPM)
        break;
}


simulated function Tick(float deltatime)
{
    super.Tick(deltatime);
    if(Level.NetMode != NM_Client)
        return;
    if(bInterpFake)
        FakeInterp(deltatime);
    else if(bOwned)
        CheckForFakeProj();
}

simulated function FakeInterp(float dt)
{
    local vector V;
    local float OldDeltaFakeTime;

    V=DesiredDeltaFake*dt/INTERP_TIME;

    OldDeltaFakeTime = CurrentDeltaFakeTime;
    CurrentDeltaFakeTime+=dt;

    if(CurrentDeltaFakeTime < INTERP_TIME)
        DoMove(V);
    else // (We overshot)
    {
        DoMove((INTERP_TIME - OldDeltaFakeTime)/dt*V);
        bInterpFake=False;
        //Turn off checking for fakes
    }
}

defaultproperties
{
}
