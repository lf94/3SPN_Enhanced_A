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
class NewNet_BioRifle extends BioRifle
	HideDropDown
	CacheExempt;

const MAX_PROJECTILE_FUDGE = 0.075;

var NewNet_TimeStamp T;
var TAM_Mutator M;

var int CurIndex;
var int ClientCurIndex;

replication
{
    reliable if( Role<ROLE_Authority )
        NewNet_ServerStartFire;
    unreliable if(Role == Role_Authority && bNetOwner)
        CurIndex;
}

function DisableNet()
{
    NewNet_BioFire(FireMode[0]).bUseEnhancedNetCode = false;
    NewNet_BioFire(FireMode[0]).PingDT = 0.00;
    NewNet_BioChargedFire(FireMode[1]).bUseEnhancedNetCode = false;
    NewNet_BioChargedFire(FireMode[1]).PingDT = 0.00;
}

simulated function float RateSelf()
{
	if(Instigator==None)
		return -2;
	return Super.RateSelf();
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	if(Instigator==None)
		return;
	Super.BringUp(PrevWeapon);
}

simulated function bool PutDown()
{
	if(Instigator==None)
		return false;
	return Super.PutDown();
}

//// client only ////
simulated event ClientStartFire(int Mode)
{
    if(Level.NetMode!=NM_Client || !class'Misc_Player'.static.UseNewNet())
        super.ClientStartFire(mode);
    else
        NewNet_ClientStartFire(mode);
}

simulated event NewNet_ClientStartFire(int Mode)
{
    if ( Pawn(Owner).Controller.IsInState('GameEnded') || Pawn(Owner).Controller.IsInState('RoundEnded') )
        return;
    if (Role < ROLE_Authority)
    {
        if (StartFire(Mode))
        {
            if(T==None)
                foreach DynamicActors(Class'NewNet_TimeStamp', T)
                     break;

            NewNet_ServerStartFire(mode, T.ClientTimeStamp);
        }
    }
    else
    {
        StartFire(Mode);
    }
}

function NewNet_ServerStartFire(byte Mode, float ClientTimeStamp)
{
    if(M==None)
        foreach DynamicActors(class'TAM_Mutator', M)
	        break;

    if(Team_GameBase(Level.Game)!=None && Misc_Player(Instigator.Controller)!=None)
      Misc_Player(Instigator.Controller).NotifyServerStartFire(ClientTimeStamp, M.ClientTimeStamp, M.AverDT);
          
    if(NewNet_BioFire(FireMode[Mode])!=None)
    {
        NewNet_BioFire(FireMode[Mode]).PingDT = FMin(M.ClientTimeStamp - ClientTimeStamp + 1.75*M.AverDT, MAX_PROJECTILE_FUDGE);
        NewNet_BioFire(FireMode[Mode]).bUseEnhancedNetCode = true;
    }
    else if(NewNet_BioChargedFire(FireMode[Mode])!=None)
    {
        NewNet_BioChargedFire(FireMode[Mode]).PingDT = FMin(M.ClientTimeStamp - ClientTimeStamp + 1.75*M.AverDT, MAX_PROJECTILE_FUDGE);
        NewNet_BioChargedFire(FireMode[Mode]).bUseEnhancedNetCode = true;
    }

    ServerStartFire(Mode);
}

defaultproperties
{
    FireModeClass(0)=Class'NewNet_BioFire'
    FireModeClass(1)=Class'NewNet_BioChargedFire'
}
