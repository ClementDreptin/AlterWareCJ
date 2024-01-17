init()
{
    level.buttonCommands = [];
    level.buttonCommands[0] = "+smoke";
    level.buttonCommands[1] = "+frag";
    level.buttonCommands[2] = "+talk";

    level thread OnPlayerConnected();
}

OnPlayerConnected()
{
    level endon("game_ended");

    for (;;)
    {
        level waittill("connected", player);
        player thread OnPlayerSpawned();
    }
}

OnPlayerSpawned()
{
    self endon("disconnect");

    for (;;)
    {
        self waittill("spawned_player");

        foreach (buttonCommand in level.buttonCommands)
            self thread MonitorButton(buttonCommand);
    }
}

MonitorButton(buttonCommand)
{
    self endon("disconnect");
    self endon("death");

    self notifyOnPlayerCommand(buttonCommand, buttonCommand);

    for (;;)
    {
        self waittill(buttonCommand);

        if (buttonCommand == "+smoke")
            self scripts\saveload::LoadPosition();
        else if (buttonCommand == "+frag")
            self scripts\saveload::SavePosition();
        else if (buttonCommand == "+talk")
            self scripts\carepackage::SpawnCarePackage();
    }
}
