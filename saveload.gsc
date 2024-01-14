SavePosition()
{
    self.savedOrigin = self getOrigin();
    self.savedAngles = self scripts\utils::_GetAngles();
    self iPrintLn("Position ^2Saved");
}

LoadPosition()
{
    if (!isDefined(self.savedOrigin) || !isDefined(self.savedAngles))
    {
        self iPrintLn("^1Save a position first!");
        return;
    }

    self scripts\utils::_SetAngles(self.savedAngles);
    self setOrigin(self.savedOrigin);
}
