/* UTComp - UT2004 Mutator
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
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA. */

//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Message_PlayerName extends PlayerNameMessage;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    if(class'Misc_Player'.default.bEnableColoredNamesOnEnemies)
    {
		if(Misc_PRI(RelatedPRI_1)!=None && Misc_PRI(RelatedPRI_1).GetColoredName()!="")
			return Misc_PRI(RelatedPRI_1).GetColoredName();
    }
    return RelatedPRI_1.PlayerName;
}

defaultproperties
{
}
