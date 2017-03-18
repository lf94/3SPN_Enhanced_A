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
//   This class acts simulated collision for the copied
//   pawn, for use in lag compensated firing.
//   This is used mostly so we don't have to worry about screwing
//   with the physics of the actual pawn when moving about.
//
//
//  *    IF YOU AREN'T DOING A TRACE ON THIS COPY,
//   MAKE ABSOLUTELY SURE ITS COLLISION IS TURNED OFF */
//-----------------------------------------------------------
class NewNet_PawnCollisionCopy extends Actor;

var NewNet_PawnCollisionCopy Next;

var float CrouchHeight;
var float CrouchRadius;

var TAM_Mutator M;

var Pawn CopiedPawn;
var bool bNormalDestroy;

var PawnHistoryElement PawnHistoryFirst;
var PawnHistoryElement PawnHistoryLast;
var PawnHistoryElement PawnHistoryFree;

//Furthest we will allow backtracking
const MAX_HISTORY_LENGTH = 0.350;

var bool bCrouched;

/* Set up the collision properties of our copy */
function SetPawn(Pawn Other)
{
    if(Level.NetMode == NM_Client)
        Warn("Client should never have a collision copy");

    if(Other == none)
    {
        Warn("PawnCopy spawned without proper Other");
        //  Destroy();
        return;
    }
 //   if(CopiedPawn==None)
    CopiedPawn=Other;

    if(M==None)
        foreach DynamicActors(class'TAM_Mutator', M)
            break;
    CrouchHeight=CopiedPawn.CrouchHeight;
    CrouchRadius=CopiedPawn.CrouchRadius;
    bUseCylinderCollision = CopiedPawn.bUseCylinderCollision;
    bCrouched=CopiedPawn.bIsCrouched;

    //If we cant use simple collisions, set up the mesh
    if(!bUseCylinderCollision)
        LinkMesh(CopiedPawn.Mesh);
    else
        SetCollisionSize(CopiedPawn.CollisionRadius, CopiedPawn.CollisionHeight);
}

/*
What happens if its not an xpawn and its changing shapes?
*/
function GoToPawn()
{
    if(CopiedPawn == none)
        return;

    SetLocation(CopiedPawn.Location);
    SetCollisionSize(CopiedPawn.CollisionRadius,CopiedPawn.CollisionHeight);

    if(bUseCylinderCollision)
    {
        if(!bCrouched && CopiedPawn.bIsCrouched)
        {
             SetCollisionSize(CrouchRadius, CrouchHeight);
             bCrouched=True;
        }
        else if(bCrouched && !CopiedPawn.bIsCrouched)
        {
            SetCollisionSize(default.CollisionRadius, default.CollisionHeight);
            bCrouched=false;
        }
    }

    SetCollision(true);
}

/*
What happens if its not an xpawn and its changing shapes?
*/
function TimeTravelPawn(float dt)
{
    local PawnHistoryElement current, Floor, Ceiling;
    local vector V;
    local float StampDT, Alpha;
    local float Interpdt;

    if(CopiedPawn == none || CopiedPawn.DrivenVehicle!=None)
       return;
    StampDT = M.ClientTimeStamp - dt;
    SetCollision(false);

    //We cant backtrack, too recent, just go straight to the pawn
    if(PawnHistoryLast==None || PawnHistoryLast.TimeStamp < StampDT )
    {
        GoToPawn();
        return;
    }

    //Sandwich between 2 history parts Ceiling and Floor
    for(current=PawnHistoryLast;current!=None;current=current.Prev)
    {
        //This will set the more recent part
        if(current.TimeStamp >= StampDT)
        {
            Floor = current;
        }
        // we either ran into, or got under the stamp
        // this is the older stamp
        // Now we should have a ceiling and floor both
        else
        {
            Ceiling = current;
            break;
        }
    }

    if(Ceiling!=None)
    {
         /* interpolate between the 2 locations based on stampDT*/
         Alpha = (Floor.TimeStamp - StampDT) / (Floor.TimeStamp - Ceiling.TimeStamp);
         V.X = lerp(Alpha, Floor.Location.X, Ceiling.Location.X);
         V.Y = lerp(Alpha, Floor.Location.Y, Ceiling.Location.Y);
         V.Z = lerp(Alpha, Floor.Location.Z, Ceiling.Location.Z);

         /* Highest gravity error at center of the 2 samples, 0 at ends
         This doesn't amount to a pinch of shit on any realistic tickrate
         but might as well keep it for now, can always remove it later*/
         if(Floor.Physics == PHYS_FALLING && Ceiling.Physics == PHYS_FALLING)
         {
             if(alpha > 0.50)
                InterpDT = (1.0-Alpha)*(Floor.TimeStamp - Ceiling.TimeStamp);
             else
                InterpDT = (Alpha)*(Floor.TimeStamp - Ceiling.TimeStamp);
             V = V - 0.5*CopiedPawn.PhysicsVolume.Gravity*Square(InterpDT);   //close enough??
         }

         if(bUseCylinderCollision)
         {
             if(!bCrouched && Floor.bCrouched && Ceiling.bCrouched)
             {
                 SetCollisionSize(CrouchRadius, CrouchHeight);
                 bCrouched=True;
             }
             else if(bCrouched && (!Floor.bCrouched || !Ceiling.bCrouched))
             {
                 SetCollisionSize(default.CollisionRadius, default.CollisionHeight);
                 bCrouched=false;
             }
         }

         SetLocation(V);
         /* Maybe interpolate rotation? */
         SetRotation(Floor.Rotation);
    }
    else
    {
          /* FixMe:  This shouldn't need to be set unless it changes, but for now
         lets just be safe and set it every time for now*/
         if(Floor.bCrouched)
             SetCollisionSize(CrouchRadius, CrouchHeight);
         else if(CopiedPawn.IsA('xPawn'))
             SetCollisionSize(default.CollisionRadius, default.CollisionHeight);
         else if(bUseCylinderCollision)
             SetCollisionSize(CopiedPawn.CollisionRadius, CopiedPawn.CollisionHeight);

         SetLocation(Floor.Location);
         SetRotation(Floor.Rotation);
    }
    SetCollision(true);
}

function TurnOffCollision()
{
    SetCollision(false);
}

function AddPawnToList(Pawn Other)
{
    // Already got it, dont bother.
  /*  if(Other == CopiedPawn)
        return;         */

    if(Next==None)
    {
        Next = Spawn(Class'NewNet_PawnCollisionCopy');
        Next.SetPawn(Other);
    }
    else
       Next.AddPawnToList(Other);
}

//Remove old pawns, returns what Next should be for the caller
//PawnCollisionCopies
function NewNet_PawnCollisionCopy RemoveOldPawns()
{
    if(CopiedPawn == none)
    {
        bNormalDestroy=True;
        Destroy();
        if(Next!=None)
            return Next.RemoveOldPawns();
        return none;
    }
    else if(Next!=None)
        Next = Next.RemoveOldPawns();
    return self;
}

/* damage the copied pawn, NOT THIS */
event TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
    Warn("Pawn collision copy should never take damage");
}

event destroyed()
{
   if(!bNormalDestroy)
      Warn("DESTROYED WITHOUT SETTING UP LIST");
   super.Destroyed();
}

function Identify()
{
   if(CopiedPawn==None)
      Log("PCC: No pawn");
   else
   {
      if(CopiedPawn.PlayerReplicationInfo!=None)
          Log("PCC: Pawn"@CopiedPawn.PlayerReplicationInfo.PlayerName);
      else
          Log("PCC: Unnamed Pawn");
   }
}

function Tick(float DeltaTime)
{
    if(Level.NetMode == NM_Client)
        Warn("Client should never have a collision copy");
    if(CopiedPawn==None)
        return;
    if(bCollideActors || bCollideWorld || bBlockActors)
       Warn("COLLISION COPY SHOULD NEVER HAVE COLLISION EXCEPT DURING A TRACE");
    RemoveOutdatedHistory();
    AddHistory();
}

function AddHistory()
{
    local PawnHistoryElement current;

    if(PawnHistoryFree!=None)
    {
        current = PawnHistoryFree;
        PawnHistoryFree = PawnHistoryFree.Next;
    }
    else
    {
        current = new class'PawnHistoryElement';
    }

    current.Location = CopiedPawn.Location;
    current.Rotation = CopiedPawn.Rotation;
    current.bCrouched = CopiedPawn.bIsCrouched;
    current.TimeStamp = M.ClientTimeStamp;
    current.Physics = CopiedPawn.Physics;
    
    if(PawnHistoryLast==None)
    {
        PawnHistoryFirst = current;
        PawnHistoryLast = current;
        current.Prev = None;
        current.Next = None;
    }
    else
    {
        PawnHistoryLast.Next = current;
        current.Prev = PawnHistoryLast;
        current.Next = None;
        PawnHistoryLast = current;
    }
}

function RemoveOutdatedHistory()
{
	local PawnHistoryElement current, end, n;
    for(end=PawnHistoryFirst; end!=None; end=end.Next)
	{
		if(end.TimeStamp+MAX_HISTORY_LENGTH >= M.ClientTimeStamp)
			break;
	}
    current = PawnHistoryFirst;
    while(current!=end)
	{
        n = current.Next;
        current.Next = PawnHistoryFree;
        PawnHistoryFree = current;
        current = n;
	}
    PawnHistoryFirst = end;
    if(PawnHistoryFirst == None)
        PawnHistoryLast = None;
    else
        PawnHistoryFirst.Prev = None;
}

defaultproperties
{
    CrouchHeight=29.00
    CrouchRadius=25.00
    bHidden=True
    bAcceptsProjectors=False
    bSkipActorPropertyReplication=True
    bOnlyDirtyReplication=True
    RemoteRole=ROLE_None
    CollisionRadius=25.00
    CollisionHeight=44.00
}
