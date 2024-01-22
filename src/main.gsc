init()
{
    level thread OnPlayerConnected();
}

RegisterCommands()
{
    self.commands = [];

    self.commands[0] = spawnStruct();
    self.commands[0].command = "+smoke";
    self.commands[0].func = scripts\saveload::LoadPosition;

    self.commands[1] = spawnStruct();
    self.commands[1].command = "+frag";
    self.commands[1].func = scripts\saveload::SavePosition;

    self.commands[2] = spawnStruct();
    self.commands[2].command = "+talk";
    self.commands[2].func = scripts\carepackage::SpawnCarePackage;
}

OnPlayerConnected()
{
    level endon("game_ended");

    for (;;)
    {
        level waittill("connected", player);

        player RegisterCommands();
        player thread OnPlayerSpawned();
    }
}

OnPlayerSpawned()
{
    self endon("disconnect");

    for (;;)
    {
        self waittill("spawned_player");

        foreach (c in self.commands)
            self thread MonitorCommand(c.command);
    }
}

MonitorCommand(command)
{
    self endon("disconnect");
    self endon("death");

    self notifyOnPlayerCommand(command, command);

    for (;;)
    {
        self waittill(command);

        foreach (c in self.commands)
            if (c.command == command)
                self [[c.func]]();
    }
}
