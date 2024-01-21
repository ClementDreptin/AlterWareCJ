_GetAngles()
{
#ifdef S1
    return self getAngles();
#else
    return self getPlayerAngles();
#endif
}

_SetAngles(angles)
{
#ifdef S1
    return self setAngles(angles);
#else
    return self setPlayerAngles(angles);
#endif
}

ProjectForward(distance)
{
    if (!isPlayer(self))
    {
        PrintError("self is not a player");
        return;
    }

    origin = self getOrigin();
    angles = self _GetAngles();
    forwardVec = anglesToForward(angles) * distance;

    return origin + (forwardVec[0], forwardVec[1], 0);
}

PrintError(message)
{
    printLn("*********** Error ***********\n" + message);
}
