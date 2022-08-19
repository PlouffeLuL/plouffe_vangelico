Server = {
  ready = false,
}

Vr = {}

Vr.Guards = {}

Vr.hackSucces = false

Vr.Utils = {
	ped = 0,
	pedCoords = vector3(0,0,0)
}

Vr.Zones = {
  vangelico_inside = {
    name = "vangelico_inside",
    coords = {
      vector3(-611.12976074219, -237.34690856934, 37.037055969238),
      vector3(-621.92614746094, -218.05816650391, 38.257083892822),
      vector3(-637.623046875, -229.27177429199, 37.794689178467),
      vector3(-625.42840576172, -246.0647277832, 37.794689178467)
    },
    isZone = true,
    zoneMap = {
      inEvent = "plouffe_vangelico:inside",
      outEvent = "plouffe_vangelico:exit"
    }
  }
}

Vr.RobberyZones = {
  vangelico_hacking = {
    name = "vangelico_hacking",
    params = {fnc = "Tryhack"},
    coords = vector3(-631.35778808594, -230.1261138916, 38.057083129883),
    distance = 1.0,
    isZone = true,
    label = "Hacker",
    keyMap = {
        key = "E",
        event = "plouffe_vangelico:onZone"
    }
  },

  vangelico_loot_1 = {
    name = "vangelico_loot_1",
    params = {fnc = "Tryloot", index = "vangelico_loot_1"},
    coords = vector3(-626.78143310547, -238.59994506836, 38.057056427002),
    distance = 0.5,
    isZone = true,
    label = "Ramasser",
    keyMap = {
        key = "E",
        event = "plouffe_vangelico:onZone"
    }
  },

  vangelico_loot_2 = {
    name = "vangelico_loot_2",
    params = {fnc = "Tryloot", index = "vangelico_loot_2"},
    coords = vector3(-625.59967041016, -237.81352233887, 38.057056427002),
    distance = 0.5,
    isZone = true,
    label = "Ramasser",
    keyMap = {
        key = "E",
        event = "plouffe_vangelico:onZone"
    }
  },

  vangelico_loot_3 = {
    name = "vangelico_loot_3",
    params = {fnc = "Tryloot", index = "vangelico_loot_3"},
    coords = vector3(-626.87579345703, -235.48271179199, 38.057056427002),
    distance = 0.5,
    isZone = true,
    label = "Ramasser",
    keyMap = {
        key = "E",
        event = "plouffe_vangelico:onZone"
    }
  },

  vangelico_loot_4 = {
    name = "vangelico_loot_4",
    params = {fnc = "Tryloot", index = "vangelico_loot_4"},
    coords = vector3(-625.83093261719, -234.60339355469, 38.057056427002),
    distance = 0.5,
    isZone = true,
    label = "Ramasser",
    keyMap = {
        key = "E",
        event = "plouffe_vangelico:onZone"
    }
  },

  vangelico_loot_5 = {
    name = "vangelico_loot_5",
    params = {fnc = "Tryloot", index = "vangelico_loot_5"},
    coords = vector3(-627.92584228516, -233.90086364746, 38.057056427002),
    distance = 0.5,
    isZone = true,
    label = "Ramasser",
    keyMap = {
        key = "E",
        event = "plouffe_vangelico:onZone"
    }
  },

  vangelico_loot_6 = {
    name = "vangelico_loot_6",
    params = {fnc = "Tryloot", index = "vangelico_loot_6"},
    coords = vector3(-626.95135498047, -233.07081604004, 38.057056427002),
    distance = 0.5,
    isZone = true,
    label = "Ramasser",
    keyMap = {
        key = "E",
        event = "plouffe_vangelico:onZone"
    }
  },

  vangelico_loot_7 = {
    name = "vangelico_loot_7",
    params = {fnc = "Tryloot", index = "vangelico_loot_7"},
    coords = vector3(-624.40313720703, -231.08076477051, 38.057056427002),
    distance = 0.5,
    isZone = true,
    label = "Ramasser",
    keyMap = {
        key = "E",
        event = "plouffe_vangelico:onZone"
    }
  },

  vangelico_loot_8 = {
    name = "vangelico_loot_8",
    params = {fnc = "Tryloot", index = "vangelico_loot_8"},
    coords = vector3(-625.07104492188, -228.00001525879, 38.057056427002),
    distance = 0.5,
    isZone = true,
    label = "Ramasser",
    keyMap = {
        key = "E",
        event = "plouffe_vangelico:onZone"
    }
  },

  vangelico_loot_9 = {
    name = "vangelico_loot_9",
    params = {fnc = "Tryloot", index = "vangelico_loot_9"},
    coords = vector3(-623.90167236328, -227.04306030273, 38.057056427002),
    distance = 0.5,
    isZone = true,
    label = "Ramasser",
    keyMap = {
        key = "E",
        event = "plouffe_vangelico:onZone"
    }
  },

  vangelico_loot_10 = {
    name = "vangelico_loot_10",
    params = {fnc = "Tryloot", index = "vangelico_loot_10"},
    coords = vector3(-624.02813720703, -228.18792724609, 38.057056427002),
    distance = 0.5,
    isZone = true,
    label = "Ramasser",
    keyMap = {
        key = "E",
        event = "plouffe_vangelico:onZone"
    }
  },

  vangelico_loot_11 = {
    name = "vangelico_loot_11",
    params = {fnc = "Tryloot", index = "vangelico_loot_11"},
    coords = vector3(-620.99102783203, -228.53881835938, 38.057048797607),
    distance = 0.5,
    isZone = true,
    label = "Ramasser",
    keyMap = {
        key = "E",
        event = "plouffe_vangelico:onZone"
    }
  },

  vangelico_loot_12 = {
    name = "vangelico_loot_12",
    params = {fnc = "Tryloot", index = "vangelico_loot_12"},
    coords = vector3(-620.44329833984, -226.59907531738, 38.056949615479),
    distance = 0.5,
    isZone = true,
    label = "Ramasser",
    keyMap = {
        key = "E",
        event = "plouffe_vangelico:onZone"
    }
  },

  vangelico_loot_13 = {
    name = "vangelico_loot_13",
    params = {fnc = "Tryloot", index = "vangelico_loot_13"},
    coords = vector3(-619.68572998047, -227.56176757813, 38.056995391846),
    distance = 0.5,
    isZone = true,
    label = "Ramasser",
    keyMap = {
        key = "E",
        event = "plouffe_vangelico:onZone"
    }
  },

  vangelico_loot_14 = {
    name = "vangelico_loot_14",
    params = {fnc = "Tryloot", index = "vangelico_loot_14"},
    coords = vector3(-618.29876708984, -229.47409057617, 38.057029724121),
    distance = 0.5,
    isZone = true,
    label = "Ramasser",
    keyMap = {
        key = "E",
        event = "plouffe_vangelico:onZone"
    }
  },

  vangelico_loot_15 = {
    name = "vangelico_loot_15",
    params = {fnc = "Tryloot", index = "vangelico_loot_15"},
    coords = vector3(-617.57623291016, -230.64025878906, 38.057029724121),
    distance = 0.5,
    isZone = true,
    label = "Ramasser",
    keyMap = {
        key = "E",
        event = "plouffe_vangelico:onZone"
    }
  },

  vangelico_loot_16 = {
    name = "vangelico_loot_16",
    params = {fnc = "Tryloot", index = "vangelico_loot_16"},
    coords = vector3(-619.69366455078, -230.47230529785, 38.057029724121),
    distance = 0.5,
    isZone = true,
    label = "Ramasser",
    keyMap = {
        key = "E",
        event = "plouffe_vangelico:onZone"
    }
  },

  vangelico_loot_17 = {
    name = "vangelico_loot_17",
    params = {fnc = "Tryloot", index = "vangelico_loot_17"},
    coords = vector3(-620.05847167969, -233.38896179199, 38.057029724121),
    distance = 0.5,
    isZone = true,
    label = "Ramasser",
    keyMap = {
        key = "E",
        event = "plouffe_vangelico:onZone"
    }
  },

  vangelico_loot_18 = {
    name = "vangelico_loot_18",
    params = {fnc = "Tryloot", index = "vangelico_loot_18"},
    coords = vector3(-619.08941650391, -233.65045166016, 38.057029724121),
    distance = 0.5,
    isZone = true,
    label = "Ramasser",
    keyMap = {
        key = "E",
        event = "plouffe_vangelico:onZone"
    }
  },

  vangelico_loot_19 = {
    name = "vangelico_loot_19",
    params = {fnc = "Tryloot", index = "vangelico_loot_19"},
    coords = vector3(-620.20123291016, -234.44323730469, 38.057029724121),
    distance = 0.5,
    isZone = true,
    label = "Ramasser",
    keyMap = {
        key = "E",
        event = "plouffe_vangelico:onZone"
    }
  },

  vangelico_loot_20 = {
    name = "vangelico_loot_20",
    params = {fnc = "Tryloot", index = "vangelico_loot_20"},
    coords = vector3(-623.22448730469, -232.87338256836, 38.057029724121),
    distance = 0.5,
    isZone = true,
    label = "Ramasser",
    keyMap = {
        key = "E",
        event = "plouffe_vangelico:onZone"
    }
  },
}