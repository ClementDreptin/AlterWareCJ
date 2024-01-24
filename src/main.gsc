init()
{
    level thread OnPlayerConnected();
}

RegisterCommands()
{
    self.commands = [];

    self.commands[0] = spawnStruct();
    self.commands[0].action = "+smoke";
    self.commands[0].func = scripts\saveload::LoadPosition;

    self.commands[1] = spawnStruct();
    self.commands[1].action = "+frag";
    self.commands[1].func = scripts\saveload::SavePosition;

    self.commands[2] = spawnStruct();
    self.commands[2].action = "+talk";
    self.commands[2].func = scripts\carepackage::SpawnCarePackage;

    self.commands[3] = spawnStruct();
    self.commands[3].action = "chatmodeteam";
    self.commands[3].func = scripts\bots::TeleportBot;
}

OnPlayerConnected()
{
    level endon("game_ended");

    for (;;)
    {
        level waittill("connected", player);

        if (scripts\utils::_IsBot(player))
        {
            level.bot = player;
            return;
        }

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

        foreach (command in self.commands)
            self thread MonitorAction(command.action);
    }
}

MonitorAction(action)
{
    self endon("disconnect");
    self endon("death");

    self notifyOnPlayerCommand(action, action);

    for (;;)
    {
        self waittill(action);

        foreach (command in self.commands)
            if (command.action == action)
                self [[command.func]]();
    }
}
