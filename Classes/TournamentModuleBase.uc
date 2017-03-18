class TournamentModuleBase extends Info;

function InitGame(string Options, out string Error)
{
}

function PreLogin
(
    out string Options,
    string Address,
    string PlayerID,
    out string Error,
    out string FailCode
)
{
}

function string ModifyLogin(string Options)
{
  return Options;
}

function bool AllowChangeTeam(Controller C, int Team)
{
  return true;
}

function bool AllowBecomeSpectator(Controller C)
{
  return true;
}

function bool AllowBecomeActivePlayer(Controller C)
{
  return true;
}
