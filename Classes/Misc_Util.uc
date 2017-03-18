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

class Misc_Util extends xUtil;

static function string GetStatsID(Controller C)
{
	if(C.Level==None || C.Level.Game==None || C.Level.Game.GameStats==None)
		return "";
	
	return C.Level.Game.GameStats.GetStatsIdentifier(C);
}

static function string GetMapName(LevelInfo Level)
{
	return Left(string(Level), InStr(string(Level), "."));
}

static function int GetTimeStampHours(LevelInfo Level)
{
	return Level.Hour + (Level.Day-1)*24 + (Level.Month-1)*24*31 + (Level.Year-2000)*24*31*12;	
}

static function string GetTimeStringFromLevel(LevelInfo Level)
{
	local string HourStr, MinuteStr, SecondStr;
	
	if(Level == None)
		return "";
		
	if(Level.Hour<10)
		HourStr = "0"$Level.Hour;
	else
		HourStr = string(Level.Hour);
		
	if(Level.Minute<10)
		MinuteStr = "0"$Level.Minute;
	else
		MinuteStr = string(Level.Minute);
		
	if(Level.Second<10)
		SecondStr = "0"$Level.Second;
	else
		SecondStr = string(Level.Second);
		
	return Level.Year$"-"$Level.Month$"-"$Level.Day$"-"$HourStr$":"$MinuteStr$":"$SecondStr;
}

static function string GetTimeString(int TimeStampHours)
{
	local int Hour,Day,Month,Year;
	
	Year = TimeStampHours/(24*31*12)+2000;
	TimeStampHours -= (Year-2000)*24*31*12;
	
	Month = TimeStampHours/(24*31)+1;
	TimeStampHours -= (Month-1)*24*31;
	
	Day = TimeStampHours/24+1;
	TimeStampHours -= (Day-1)*24;
	
	Hour = TimeStampHours;
		
	return Hour$":00 "$Month$"/"$Day$" "$Year;
}

static function int GetBit(int theInt, int bitNum)
{
    return ((theInt & 1<<bitNum));
}

static function bool GetBitBool(int theInt, int bitNum)
{
   return ((theInt & 1<<bitNum)!=0);
}

static function string MakeColorCode(color NewColor)
{
    // Text colours use 1 as 0.
    if(NewColor.R == 0)
        NewColor.R = 1;
    else if(NewColor.R == 10)
        NewColor.R = 9;
    else
        NewColor.R = Min(250, NewColor.R);

    if(NewColor.G == 0)
        NewColor.G = 1;
    else if(NewColor.G == 10)
        NewColor.G = 9;
    else
        NewColor.G = Min(250, NewColor.G);

    if(NewColor.B == 0)
        NewColor.B = 1;
    else if(NewColor.B == 10)
        NewColor.B = 9;
    else
        NewColor.B = Min(250, NewColor.B);

    return Chr(0x1B)$Chr(NewColor.R)$Chr(NewColor.G)$Chr(NewColor.B);
}

static function string ColorReplace(int k)   //makes the 8 primary colors
{
   local color theColor;

   theColor.R=GetBit(k,0)*250;
   theColor.G=GetBit(k,1)*250;
   theColor.B=GetBit(k,2)*250;  //cant be 255 because of the chat window
   return MakeColorCode(theColor);
}

static function string RandomColor()
{
   local color theColor;
   theColor.R=Rand(250);
   theColor.G=Rand(250);
   theColor.B=Rand(250);
   return MakeColorCode(theColor);
}

simulated static function string StripColorCodes(String S)
{
   local array<string> StringParts;
   local int i;
   local string S2;

   Split(S, chr(27), stringParts);
   if(StringParts.Length>=1)
      S2=StringParts[0];
   for(i=1; i<stringParts.Length; i++)
   {
      StringParts[i]=Right(StringParts[i], Len(stringParts[i])-3);
      S2=S2$stringParts[i];
   }
   if(Right(s2,1)==chr(27))
       S2=Left(S2, Len(S2)-1);
   return S2;
}

static function string StripColor(string s)
{
	local int p;

    p = InStr(s,chr(27));
	while ( p>=0 )
	{
		s = left(s,p)$mid(S,p+4);
		p = InStr(s,Chr(27));
	}

	return s;
}

simulated static function DrawTextClipped(Canvas C, string S, float MaxWidth)
{
	local float oldClipX;
	
    oldClipX=C.ClipX;
    C.ClipX=C.CurX+MaxWidth;

	C.DrawTextClipped(S);
	
    C.ClipX=OldClipX;
}

simulated static function bool InStrNonCaseSensitive(String S, string S2)
{                                //S2 in S
    local int i;
    for(i=0; i<=(Len(S)-Len(S2)); i++)
    {
        if(Mid(S, i, Len(s2))~=S2)
            return true;
    }
    return false;
}
/*
simulated static function UTComp_PRI GetUTCompPRIFor(Controller C)
{
    if(C.PlayerReplicationInfo!=None)
        return GetUTCompPRI(C.PlayerReplicationInfo);
    return none;
}

simulated static function UTComp_PRI GetUTCompPRIForPawn(Pawn P)
{
    if(P.PlayerReplicationInfo!=None)
        return GetUTCompPRI(P.PlayerReplicationInfo);
    else if(P.Controller!=None)
        return GetUTCompPRIFor(P.Controller);
    return none;
}
*/

static function string FixUnicodeString(string S)
{
  local int i, code;
  local string result;
  
  for(i=0; i<Len(S); ++i)
  {
    code = Asc(Mid(S,i));

    // Unicode conversion hack (convert from fullwidth UTF-16 to Extended ASCII)
    // This is for Linux Server / Windows Client compatibility
    if(code >= 65280) {
      code -= 65280;
    }
    
    result = result $ Chr(code);
  }
  
  return result;
}

static function string SanitizeLoginOptions(string Options)
{
    local string Pair, Key, Value, Result, OrigOptions;
    OrigOptions = Options;
    while( class'GameInfo'.static.GrabOption( Options, Pair ) )
    {
        class'GameInfo'.static.GetKeyValue( Pair, Key, Value );
        if(Len(Key)==0)
          continue;
        if(Key=="Load")
          continue;
        Result = Result $ "?" $ Key $ "=" $ Value;
    }
    log("Sanitized options string '" $ OrigOptions $ "' to '" $ Result $ "'");
    return Result;
}

defaultproperties
{
}
