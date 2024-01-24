// gsc-tool doesn't support IW4 so we preprocess scripts for IW5 instead,
// available functions are similar enough to run fine on iw4x
#ifdef IW5
#define IW4
#endif

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

_IsBot(player)
{
#ifdef IW4
    return player isTestClient();
#else
    return isBot(player);
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
