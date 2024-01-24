TeleportBot()
{
    if (!isDefined(level.bot))
    {
        self iPrintLn("^1There is no bot in the game!");
        return;
    }

    newBotOrigin = self scripts\utils::ProjectForward(150);

    level.bot setOrigin(newBotOrigin);

    level.bot freezeControls(true);
}
