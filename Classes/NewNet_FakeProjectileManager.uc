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
class NewNet_FakeProjectileManager extends Actor;

struct FPindex
{
    var Projectile FP;
    var int index;
};

var array<FPIndex> FP;

simulated function RegisterFakeProjectile(Projectile P, optional int index)
{
    local int i;
    i= FP.Length+1;
    FP.Length =i;
    FP[i-1].FP=P;
    FP[i-1].index = index;
}

simulated function bool AllowFakeProjectile(class<projectile> pClass, optional int index)
{
   local int i;
   CleanUpProjectiles();
   for(i=0; i<FP.Length; i++)
      if(FP[i].FP!=None && FP[i].FP.class == pClass && FP[i].index == index)
          return false;
   return true;
}

simulated function CleanUpProjectiles()
{
   local int i;

   for(i=FP.Length-1; i>=0; i--)
      if(FP[i].FP==None)
          FP.Remove(i,1);
}

simulated function RemoveProjectile(Projectile P)
{
    local int i;
    for(i=FP.Length-1; i>=0; i--)
    {
        if(FP[i].FP==None || FP[i].FP==P)
            FP.Remove(i,1);
    }
    P.Destroy();
}

simulated function Projectile GetFP(class<Projectile> CP, optional int index)
{
   local int i;
   for(i=0; i<FP.Length; i++)
      if(FP[i].FP!=None && FP[i].FP.class == CP && FP[i].index == index)
         return FP[i].FP;
   return none;
}

defaultproperties
{
    bHidden=True
}
