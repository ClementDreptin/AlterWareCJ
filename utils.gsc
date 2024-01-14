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
