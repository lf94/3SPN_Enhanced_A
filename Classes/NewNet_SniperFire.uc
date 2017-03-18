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
//   First weapon implimentation for the lag compensated firing.
//-----------------------------------------------------------
class NewNet_SniperFire extends WeaponFire_Lightning;

var bool bUseReplicatedInfo;
var rotator savedRot;
var vector savedVec;

var float PingDT;
var bool bSkipNextEffect;
//var bool bBelievesHit;
//var float Correct, Wrong;
//var bool bCount;
var bool bUseEnhancedNetCode;
//var vector BelievedHLDelta;

function PlayFiring()
{
   super.PlayFiring();

   if(Level.NetMode != NM_Client || !class'Misc_Player'.static.UseNewNet())
       return;
	
   if(!bSkipNextEffect)
       CheckFireEffect();
   else
   {
      bSkipNextEffect=false;
      Weapon.ClientStopFire(0);
   }
}

function DoClientTrace(Vector Start, Rotator Dir)
{
    local Vector X,Y,Z, End, HitLocation, HitNormal, RefNormal;
    local Actor Other, mainArcHitTarget;
    local int ReflectNum, arcsRemaining;
    local bool bDoReflect;
    local class<Actor> tmpHitEmitClass;
    local float tmpTraceRange;
    local vector arcEnd, mainArcHit;
	local vector EffectOffset;

	if ( class'PlayerController'.Default.bSmallWeapons )
		EffectOffset = Weapon.SmallEffectOffset;
	else
		EffectOffset = Weapon.EffectOffset;

    Weapon.GetViewAxes(X, Y, Z);
    if ( Weapon.WeaponCentered() || SniperRifle(Weapon).zoomed )
        arcEnd = (Instigator.Location +
			EffectOffset.Z * Z);
	else if ( Weapon.Hand == 0 )
	{
		if ( class'PlayerController'.Default.bSmallWeapons )
			arcEnd = (Instigator.Location +
				EffectOffset.X * X);
		else
			arcEnd = (Instigator.Location +
				EffectOffset.X * X
				- 0.5 * EffectOffset.Z * Z);
	}
	else
        arcEnd = (Instigator.Location +
			Instigator.CalcDrawOffset(Weapon) +
			EffectOffset.X * X +
			Weapon.Hand * EffectOffset.Y * Y +
			EffectOffset.Z * Z);

    arcsRemaining = NumArcs;

    tmpHitEmitClass = Class'NewNet_Client_LightningBolt';
    tmpTraceRange = TraceRange;

    ReflectNum = 0;
    while (true)
    {
        bDoReflect = false;
        X = Vector(Dir);
        End = Start + tmpTraceRange * X;
        Other = Weapon.Trace(HitLocation, HitNormal, End, Start, true);

        if ( Other != None && (Other != Instigator || ReflectNum > 0) )
        {
            if (bReflective && Other.IsA('xPawn') && xPawn(Other).CheckReflect(HitLocation, RefNormal, DamageMin*0.25))
            {
                bDoReflect = true;
            }
            else if ( Other != mainArcHitTarget )
            {
                if ( !Other.bWorldGeometry )
                {
                }
                else
					HitLocation = HitLocation + 2.0 * HitNormal;
            }
        }
        else
        {
            HitLocation = End;
            HitNormal = Normal(Start - End);
        }
        if ( Weapon == None )
			return;
        NewNet_SniperRifle(Weapon).SpawnLGEffect(tmpHitEmitClass, arcEnd, HitNormal, HitLocation);

		if ( HitScanBlockingVolume(Other) != None )
			return;

        if( arcsRemaining == NumArcs )
        {
            mainArcHit = HitLocation + (HitNormal * 2.0);
            if ( Other != None && !Other.bWorldGeometry )
                mainArcHitTarget = Other;
        }
        if (bDoReflect && ++ReflectNum < 4)
        {
            //Log("reflecting off"@Other@Start@HitLocation);
            Start = HitLocation;
            Dir = Rotator( X - 2.0*RefNormal*(X dot RefNormal) );
        }
        else if ( arcsRemaining > 0 )
        {
            arcsRemaining--;

            // done parent arc, now move trace point to arc trace hit location and try child arcs from there
            Start = mainArcHit;
            Dir = Rotator(VRand());
            tmpHitEmitClass = SecHitEmitterClass;
            tmpTraceRange = SecTraceDist;
            arcEnd = mainArcHit;
        }
        else
        {
            break;
        }
    }
}


function CheckFireEffect()
{
   if(Level.NetMode == NM_Client && Instigator.IsLocallyControlled())
   {
       DoFireEffect();
   }
}

function DoInstantFireEffect()
{
   if(Level.NetMode == NM_Client && Instigator.IsLocallyControlled())
   {
       DoFireEffect();
       bSkipNextEffect=true;
   }
}


function DoFireEffect()
{
    local Vector StartTrace;
    local Rotator R, Aim;

    if(!bUseEnhancedNetCode && Level.NetMode != NM_Client)
    {
        super.DoFireEffect();
        return;
    }
	
    Instigator.MakeNoise(1.0);

    if(bUseReplicatedInfo)
    {
        StartTrace=savedVec;
        R=SavedRot;
        bUseReplicatedInfo=false;
	}
    else
    {
        // the to-hit trace always starts right in front of the eye
        StartTrace = Instigator.Location + Instigator.EyePosition();
        Aim = AdjustAim(StartTrace, AimError);
	    R = rotator(vector(Aim) + VRand()*FRand()*Spread);
    }
    if(Level.NetMode == NM_Client)
        DoClientTrace(StartTrace, R);
    else
        DoTrace(StartTrace, R);
}

function DoTrace(Vector Start, Rotator Dir)
{
    local Vector X,Y,Z, End, HitLocation, HitNormal, RefNormal;
    local Actor Other, mainArcHitTarget;
    local int Damage, ReflectNum, arcsRemaining;
    local bool bDoReflect;
    local xEmitter hitEmitter;
    local class<Actor> tmpHitEmitClass;
    local float tmpTraceRange;
    local vector arcEnd, mainArcHit;
    local Pawn HeadShotPawn;
	local vector EffectOffset;
	local vector PawnHitLocation;
//	local float f;

	if(!bUseEnhancedNetCode)
	{
        super.DoTrace(Start,Dir);
        return;
    }
	
    if ( class'PlayerController'.Default.bSmallWeapons )
		EffectOffset = Weapon.SmallEffectOffset;
	else
		EffectOffset = Weapon.EffectOffset;

    Weapon.GetViewAxes(X, Y, Z);
    if ( Weapon.WeaponCentered() || SniperRifle(Weapon).zoomed )
        arcEnd = (Instigator.Location +
			EffectOffset.Z * Z);
	else if ( Weapon.Hand == 0 )
	{
		if ( class'PlayerController'.Default.bSmallWeapons )
			arcEnd = (Instigator.Location +
				EffectOffset.X * X);
		else
			arcEnd = (Instigator.Location +
				EffectOffset.X * X
				- 0.5 * EffectOffset.Z * Z);
	}
	else
        arcEnd = (Instigator.Location +
			Instigator.CalcDrawOffset(Weapon) +
			EffectOffset.X * X +
			Weapon.Hand * EffectOffset.Y * Y +
			EffectOffset.Z * Z);

    arcsRemaining = NumArcs;

    tmpHitEmitClass = Class'NewNet_NewLightningBolt';//HitEmitterClass;
    tmpTraceRange = TraceRange;

    ReflectNum = 0;

    TimeTravel(pingDT);

    while (true)
    {
        bDoReflect = false;
        X = Vector(Dir);
        End = Start + tmpTraceRange * X;

        if(PingDT <=0.0)
            Other = Weapon.Trace(HitLocation,HitNormal,End,Start,true);
        else
            Other = DoTimeTravelTrace(HitLocation, HitNormal, End, Start);

        if(Other!=None && Other.IsA('NewNet_PawnCollisionCopy'))
        {
            //Maintain the same ray, but move to the real pawn
            //ToDo: handle crouching differences
            PawnHitLocation = HitLocation + NewNet_PawnCollisionCopy(Other).CopiedPawn.Location - Other.Location;
    /*        if(ArcsRemaining == NumArcs && bCount && bBelievesHit)
            {
                 PlayerController(Pawn(Weapon.Owner).Controller).ClientMessage(BelievedHLDelta - Other.Location);
                 bCount=false;
            }    */
            Other=NewNet_PawnCollisionCopy(Other).CopiedPawn;

        }
        else
        {
            PawnHitLocation = HitLocation;
        }
       /* if(bCount && ArcsRemaining == NumArcs && Other.IsA('ShockProjectile'))
            bCount=false;

        if(ArcsRemaining == NumArcs && bCount)
        {
           if((bBelievesHit && Other.IsA('Xpawn'))
              Log(HitLocation -
            if((bBelievesHit && Other.IsA('Xpawn')) || (!bBelievesHit && (Other==None || !Other.IsA('xPawn'))) )
               default.Correct+=1.0;
            else
            {
               default.Wrong+=1.0;
               for(f=PingDT+0.13; f>=PingDt-0.13; f-=0.01)
               {
                  TimeTravel(f);
                  Other = DoTimeTravelTrace(HitLocation, HitNormal, End, Start);
                  if(Other!=None && Other.IsA('NewNet_PawnCollisionCopy'))
                  {
                        //Maintain the same ray, but move to the real pawn
                        //ToDo: handle crouching differences
                         PawnHitLocation = HitLocation + NewNet_PawnCollisionCopy(Other).CopiedPawn.Location - Other.Location;
                         Other=NewNet_PawnCollisionCopy(Other).CopiedPawn;
                  }
                  if((bBelievesHit && Other.IsA('Xpawn')) || (!bBelievesHit && (Other==None || !Other.IsA('xPawn'))) )
                  {
                      PlayerController(Pawn(Weapon.Owner).Controller).ClientMessage("Corrected error at"@f-Pingdt@"delta");
                  }
                  else
                  {
                      PlayerController(Pawn(Weapon.Owner).Controller).ClientMessage("couldn't fix at"@f-Pingdt@"delta"@Other);
                  }
               }
            }
            PlayerController(Pawn(Weapon.Owner).Controller).ClientMessage("Correct:"@default.Correct@"Wrong:"@default.Wrong);
            bCount=false;
        }      */

        if ( Other != None && (Other != Instigator || ReflectNum > 0) )
        {
            if (bReflective && Other.IsA('xPawn') && xPawn(Other).CheckReflect(PawnHitLocation, RefNormal, DamageMin*0.25))
            {
                bDoReflect = true;
            }
            else if ( Other != mainArcHitTarget )
            {
                if ( !Other.bWorldGeometry )
                {
                    Damage = (DamageMin + Rand(DamageMax - DamageMin)) * DamageAtten;

                    if (Vehicle(Other) != None)
                        HeadShotPawn = Vehicle(Other).CheckForHeadShot(PawnHitLocation, X, 1.0);

                    if (HeadShotPawn != None)
                        HeadShotPawn.TakeDamage(Damage * HeadShotDamageMult, Instigator, PawnHitLocation, Momentum*X, DamageTypeHeadShot);
					else if ( (Pawn(Other) != None) && (arcsRemaining == NumArcs)
						&& Pawn(Other).IsHeadShot(PawnHitLocation, X, 1.0) )
                        Other.TakeDamage(Damage * HeadShotDamageMult, Instigator, PawnHitLocation, Momentum*X, DamageTypeHeadShot);
                    else
                    {
						if ( arcsRemaining < NumArcs )
							Damage *= SecDamageMult;
                        Other.TakeDamage(Damage, Instigator, PawnHitLocation, Momentum*X, DamageType);
					}
                }
                else
					HitLocation = HitLocation + 2.0 * HitNormal;
            }
        }
        else
        {
            HitLocation = End;
            HitNormal = Normal(Start - End);
        }
        if ( Weapon == None )
			return;
        hitEmitter = xEmitter(Weapon.Spawn(tmpHitEmitClass,,, arcEnd, Rotator(HitNormal)));
        if ( hitEmitter != None )
			hitEmitter.mSpawnVecA = HitLocation;
		if ( HitScanBlockingVolume(Other) != None )
		{
        	UnTimeTravel();
            return;
        }

        if( arcsRemaining == NumArcs )
        {
            mainArcHit = HitLocation + (HitNormal * 2.0);
            if ( Other != None && !Other.bWorldGeometry )
                mainArcHitTarget = Other;
        }

        if (bDoReflect && ++ReflectNum < 4)
        {
            //Log("reflecting off"@Other@Start@HitLocation);
            Start = HitLocation;
            Dir = Rotator( X - 2.0*RefNormal*(X dot RefNormal) );
        }
        else if ( arcsRemaining > 0 )
        {
            arcsRemaining--;

            // done parent arc, now move trace point to arc trace hit location and try child arcs from there
            Start = mainArcHit;
            Dir = Rotator(VRand());
            tmpHitEmitClass = Class'NewNet_ChildLightningBolt';//SecHitEmitterClass;
            tmpTraceRange = SecTraceDist;
            arcEnd = mainArcHit;
        }
        else
        {
            break;
        }
    }
    UnTimeTravel();
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

    if(NewNet_SniperRifle(Weapon).M == none)
        foreach Weapon.DynamicActors(class'TAM_Mutator',NewNet_SniperRifle(Weapon).M)
            break;

    for(PCC = NewNet_SniperRifle(Weapon).M.PCC; PCC!=None; PCC=PCC.Next)
        PCC.TimeTravelPawn(Delta);
}

function UnTimeTravel()
{
    local NewNet_PawnCollisionCopy PCC;
    //Now, lets turn off the old hits
    for(PCC = NewNet_SniperRifle(Weapon).M.PCC; PCC!=None; PCC=PCC.Next)
        PCC.TurnOffCollision();
}

defaultproperties
{
}
