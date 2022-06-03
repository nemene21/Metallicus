import json, sys

def calc(path):

    file = open(path, "r")

    items = json.loads(file.read())

    for i in items:

        try:

            dpsMax = items[i]["stats"]["dmg"] / items[i]["stats"]["attackTime"]

            if "burst" in items[i]["stats"]:

                dpsMax *= items[i]["stats"]["burst"]

            dps = dpsMax

            if "explosion" in items[i]:

                dps += items[i]["explosion"]["dmg"] / items[i]["stats"]["attackTime"]
                dpsMax += items[i]["explosion"]["dmg"] / items[i]["stats"]["attackTime"] * 3

            if "amount" in items[i]["stats"]:
                dpsMax *= items[i]["stats"]["amount"]

            if "pirice" in items[i]["projectile"]:
                dpsMax *= min(items[i]["projectile"]["pirice"], 3)

            print(items[i]["name"] + "'s")
            print("    DPS = " + str(round(dps, 2)))
            print("    DPS_MAX = " + str(round(dpsMax, 2)))
            print()

        except:

            pass

if sys.argv[1] != 0 and __name__ == "__main__":

    calc(sys.argv[1])

input()