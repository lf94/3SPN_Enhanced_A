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
class NewNet_Fake_FlakChunk extends FlakChunk;

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
    if ( (FlakChunk(Other) == None) && ((Physics == PHYS_Falling) || (Other != Instigator)) )
    {
        speed = VSize(Velocity);
        if ( speed > 200 )
        {
            if ( Role == ROLE_Authority )
			{
				if ( Instigator == None || Instigator.Controller == None )
					Other.SetDelayedDamageInstigatorController( InstigatorController );
			}
        }
        Destroy();
    }
}

defaultproperties
{
    bNetTemporary=False
}
