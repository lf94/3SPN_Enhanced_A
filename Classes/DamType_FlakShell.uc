class DamType_FlakShell extends DamTypeFlakShell;

static function IncrementKills(Controller Killer)
{
  //call the primary damage type for this weapon
  class'DamType_FlakChunk'.static.IncrementKills(Killer);
}

defaultproperties
{
}
