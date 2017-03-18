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
class NewNet_TimeStamp extends ReplicationInfo;

var float ClientTimeStamp;
var float AverDT;

replication
{
   unreliable if(Role == Role_Authority)
       ClientTimeStamp, AverDT;
}

simulated function Tick(float DeltaTime)
{
    ClientTimeStamp+=deltatime;
    default.AverDT = Averdt;
}

function ReplicatetimeStamp(float f)
{
    ClientTimeStamp=f;
}

function ReplicatedAverDT(float f)
{
    AverDT = f;
}

defaultproperties
{
    NetUpdateFrequency=100.00
    NetPriority=5.00
}
