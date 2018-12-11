local AddOnName, AddOnTable = ...

if ( GetLocale() == "deDE" ) then
    AddOnTable["Localization"] = {
        ["ClassMounts"] = "Klassenreittiere",
        ["CloudSerpents"] = "Wolkenschlangen",
        ["DragonTurtle"] = "Drachenschildkröte",
        ["FastMechanostrider"] = "Schneller Roboschreiter",
        ["GreatDragonTurtle"] = "Große Drachenschildkröte",
        ["Gron"] = "Gron",
        ["HeavenlyCloudSerpents"] = "Himmlische Wolkenschlangen",
        ["Mechanostrider"] = "Roboschreiter",
        ["NetherwingDrakes"] = "Drachen der Netherschwingen",
        ["Panther"] = "Panther",
        ["ProtoDrakes"] = "Protodrachen",
        ["ThunderingCloudSerpents"] = "Donnernde Wolkenschlangen",
    }
else
    AddOnTable["Localization"] = {
        ["ClassMounts"] = "Class Mounts",
        ["CloudSerpents"] = "Cloud Serpents",
        ["DragonTurtle"] = "Dragon Turtle",
        ["FastMechanostrider"] = "Fast Mechanostrider",
        ["GreatDragonTurtle"] = "Great Dragon Turtle",
        ["Gron"] = "Gron",
        ["HeavenlyCloudSerpents"] = "Heavenly Cloud Serpents",
        ["Mechanostrider"] = "Mechanostrider",
        ["NetherwingDrakes"] = "Netherwing Drakes",
        ["Panther"] = "Panther",
        ["ProtoDrakes"] = "Proto-Drakes",
        ["ThunderingCloudSerpents"] = "Thundering Cloud Serpents",
    }
end