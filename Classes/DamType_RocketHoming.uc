class DamType_RocketHoming extends DamTypeRocketHoming;

static function IncrementKills(Controller Killer)
{
  //call the primary damage type for this weapon
  class'DamType_Rocket'.static.IncrementKills(Killer);
}

