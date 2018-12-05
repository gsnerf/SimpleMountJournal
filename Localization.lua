local AddOnName, AddOnTable = ...

if ( GetLocale() == "deDE" ) then
    AddOnTable["Localization"] = {
        ["Gron"] = "Gron",
        ["Mechanostrider"] = "Roboschreiter",
        ["FastMechanostrider"] = "Schneller Roboschreiter"
    }
else
    AddOnTable["Localization"] = {
        ["Gron"] = "Gron",
        ["Mechanostrider"] = "Mechanistrider",
        ["FastMechanostrider"] = "Fast Mechanostrider"
    }
end