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
//-----------------------------------------------------------
//
//-----------------------------------------------------------
class NewNet_ClassicSniperFire extends ClassicSniperFire;

var float PingDT;
var bool bUseEnhancedNetCode;


function DoTrace(Vector Start, Rotator Dir)
{
    local Vector X,Y,Z, End, HitLocation, HitNormal, ArcEnd;
    local Actor Other;
    local SniperWallHitEffect S;
    local Pawn HeadShotPawn;
    local vector PawnHitLocation;

    if(!bUseEnhancedNetCode)
    {
        super.DoTrace(Start,Dir);
        return;
    }

    Weapon.GetViewAxes(X, Y, Z);
    if ( Weapon.WeaponCentered() )
        ArcEnd = (Instigator.Location +
			Weapon.EffectOffset.X * X +
			1.5 * Weapon.EffectOffset.Z * Z);
	else
        ArcEnd = (Instigator.Location +
			Instigator.CalcDrawOffset(Weapon) +
			Weapon.EffectOffset.X * X +
			Weapon.Hand * Weapon.EffectOffset.Y * Y +
			Weapon.EffectOffset.Z * Z);

    X = Vector(Dir);
    End = Start + TraceRange * X;
    TimeTravel(PingDT);
    if(PingDT <=0.0)
        Other = Weapon.Trace(HitLocation,HitNormal,End,Start,true);
    else
        Other = DoTimeTravelTrace(HitLocation, HitNormal, End, Start);

    if(Other!=None && Other.IsA('NewNet_PawnCollisionCopy'))
    {
         PawnHitLocation = HitLocation + NewNet_PawnCollisionCopy(Other).CopiedPawn.Location - Other.Location;
         Other=NewNet_PawnCollisionCopy(Other).CopiedPawn;
    }
    else
    {
        PawnHitLocation = HitLocation;
    }
    UnTimeTravel();

    if ( (Level.NetMode != NM_Standalone) || (PlayerController(Instigator.Controller) == None) )
		Weapon.Spawn(class'TracerProjectile',Instigator.Controller,,Start,Dir);
    if ( Other != None && (Other != Instigator) )
    {
        if ( !Other.bWorldGeometry )
        {
            if (Vehicle(Other) != None)
                HeadShotPawn = Vehicle(Other).CheckForHeadShot(PawnHitLocation, X, 1.0);

            if (HeadShotPawn != None)
                HeadShotPawn.TakeDamage(DamageMax * HeadShotDamageMult, Instigator, PawnHitLocation, Momentum*X, DamageTypeHeadShot);
 			else if ( (Pawn(Other) != None) && Pawn(Other).IsHeadShot(HitLocation, X, 1.0))
                Other.TakeDamage(DamageMax * HeadShotDamageMult, Instigator, PawnHitLocation, Momentum*X, DamageTypeHeadShot);
            else
                Other.TakeDamage(DamageMax, Instigator, PawnHitLocation, Momentum*X, DamageType);
        }
        else
				HitLocation = HitLocation + 2.0 * HitNormal;
    }
    else
    {
        HitLocation = End;
        HitNormal = Normal(Start - End);
    }

    if ( (HitNormal != Vect(0,0,0)) && (HitScanBlockingVolume(Other) == None) )
    {
		S = Weapon.Spawn(class'SniperWallHitEffect',,, HitLocation, rotator(-1 * HitNormal));
		if ( S != None )
			S.FireStart = Start;
	}
}

// We need to do 2 traces. First, one that ignores the things which have already been copied
// and a second one that looks only for things that are copied
function Actor DoTimeTravelTrace(Out vector Hitlocation, out vector HitNormal, vector End, vector Start)
{
    local Actor Other;
    local bool bFoundPCC;
    local vector NewEnd, WorldHitNormal,WorldHitLocation;
    local vector PCCHitNormal,PCCHitLocation;
    local NewNet_PawnCollisionCopy PCC, returnPCC;

    //First, lets set the extent of our trace.  End once we hit an actor which won't
    //be checked by an unlagged copy.
    foreach Weapon.TraceActors(class'Actor', Other,WorldHitLocation,WorldHitNormal,End,Start)
    {
       if((Other.bBlockActors || Other.bProjTarget || Other.bWorldGeometry) && !class'TAM_Mutator'.static.IsPredicted(Other))
       {
           break;
       }
       Other=None;
    }
    if(Other!=None)
        NewEnd=WorldHitlocation;
    else
        NewEnd=End;

    //Now, lets see if we run into any copies, we stop at the location
    //determined by the previous trace.
    foreach Weapon.TraceActors(Class'NewNet_PawnCollisionCopy', PCC, PCCHitLocation, PCCHitNormal, NewEnd,Start)
    {
        if(PCC!=None && PCC.CopiedPawn!=None && PCC.CopiedPawn!=Instigator)
        {
            bFoundPCC=True;
            returnPCC=PCC;
            break;
        }
    }

    // Give back the corresponding info depending on whether or not
    // we found a copy

    if(bFoundPCC)
    {
        HitLocation = PCCHitLocation;
        HitNormal = PCCHitNormal;
        return returnPCC;
    }
    else
    {
        HitLocation = WorldHitLocation;
        HitNormal = WorldHitNormal;
        return Other;
    }
}

function TimeTravel(float delta)
{
    local NewNet_PawnCollisionCopy PCC;

    if(NewNet_ClassicSniperRifle(Weapon).M == none)
        foreach Weapon.DynamicActors(class'TAM_Mutator',NewNet_ClassicSniperRifle(Weapon).M)
            break;

    for(PCC = NewNet_ClassicSniperRifle(Weapon).M.PCC; PCC!=None; PCC=PCC.Next)
        PCC.TimeTravelPawn(Delta);
}

function UnTimeTravel()
{
    local NewNet_PawnCollisionCopy PCC;
    //Now, lets turn off the old hits
    for(PCC = NewNet_ClassicSniperRifle(Weapon).M.PCC; PCC!=None; PCC=PCC.Next)
        PCC.TurnOffCollision();
}

defaultproperties
{
}
