SpawnCarePackage()
{
    carePackageOrigin = self scripts\utils::ProjectForward(150);

    carePackage = spawn("script_model", carePackageOrigin);
    if (!isDefined(carePackage))
    {
        self iPrintLn("^1Could not spawn care package");
        return;
    }

    carePackage rotateYaw(self scripts\utils::_GetAngles()[1], 0.01);

    // TODO: use macros once https://github.com/xensik/gsc-tool/issues/184 is fixed
    carePackageModel = undefined;
    gameName = getDvar("gamename");

    switch (gameName)
    {
    case "S1":
        carePackageModel = "orbital_carepackage_pod_01_ai";
        break;
    case "IW6":
        carePackageModel = "carepackage_friendly_iw6";
        break;
    default:
        carePackageModel = "com_plasticcase_friendly";
    }

    carePackage setModel(carePackageModel);

    carePackage MakeSolid();
}

MakeSolid()
{
    // TODO: find the name of level.airDropCrateCollision on S1 instead of doing this

#ifdef S1
    collisions = [];
    collisions["mp_refraction"] = 164;
    collisions["mp_lab2"] = 215;
    collisions["mp_comeback"] = 123;
    collisions["mp_laser2"] = 183;
    collisions["mp_detroit"] = 126;
    collisions["mp_greenband"] = 119;
    collisions["mp_levity"] = 122;
    collisions["mp_instinct"] = 146;
    collisions["mp_recovery"] = 288;
    collisions["mp_venus"] = 144;
    collisions["mp_prison"] = 129;
    collisions["mp_solar"] = 129;
    collisions["mp_terrace"] = 117;
    collisions["mp_dam"] = 127;
    collisions["mp_torqued"] = 218;
    collisions["mp_clowntown3"] = 133;
    collisions["mp_lost"] = 175;
    collisions["mp_urban"] = 121;
    collisions["mp_blackbox"] = 158;
    collisions["mp_climate_3"] = 121;
    collisions["mp_perplex_1"] = 235;
    collisions["mp_spark"] = 125;
    collisions["mp_highrise2"] = 298;
    collisions["mp_kremlin"] = 203;
    collisions["mp_bigben2"] = 132;
    collisions["mp_sector17"] = 126;
    collisions["mp_fracture"] = 243;
    collisions["mp_lair"] = 142;
    collisions["mp_liberty"] = 267;
    collisions["mp_seoul2"] = 151;

    mapName = getDvar("ui_mapname");

    if (!isDefined(collisions[mapName]))
    {
        scripts\utils::PrintError("Could not get the collision for " + mapName);
        return;
    }

    collision = getEntByNum(collisions[mapName]);
#else
    collision = level.airDropCrateCollision;
#endif

    self cloneBrushModelToScriptModel(collision);
}
