"""The formation pass's proposal as code (docs/formation_proposal.md, 9 November): every domain's
patrols and formations as grids, written to a factions.json for a scratch worktree's reads, the
reads' bands merged into the proposal's tables, and the bands counted by tier and size. It
retires with the proposal: once Ryan's marks land as content, the grids live in
content/factions.json alone and this file goes to git.

  python3 tools/formation_proposal.py write content/factions.json content/foes.json <worktree>/content/factions.json tables.md [--prune]
      the proposal's grids in place of today's patrols and formations (the elites and escorts kept),
      validated by the worktree's ContentDB (tests/test_content.gd runs the validator), and the grids
      as markdown tables; --prune leaves out the twelve the reads prune (the proposal's section 5), the
      set that would land on Ryan's go
  python3 tools/formation_proposal.py tables <worktree>/content/factions.json content/foes.json tables.md "Default four=curve.md" ...
      the tables with each read's bands, hull lost, rounds and stalls (tools/balance.gd --packs curve
      --out curve.md; several files may share a label)
  python3 tools/formation_proposal.py summary "Default four=curve.md" ...
      band counts at the rating, by tier and size

The reads behind it are docs/measurements.md, 9 November. A scratch worktree for the reads:
  git worktree add --detach .claude/worktrees/formation-read HEAD && cp -r .godot .claude/worktrees/formation-read/
"""
import json, sys, re, copy
from collections import defaultdict, OrderedDict


def write(args):

    src, foes_path, out_json, out_md = [a for a in args if not a.startswith("--")][0:4]
    data = json.load(open(src))
    foes = {f['id']: f for f in json.load(open(foes_path))['entries']}

    N = None

    def C(id, size, tiers, front, back, question, note="", squad=None, hunts=None, lead=None, ramp=None):
        assert len(front) == 4 and len(back) == 4, id
        for cell in front:
            if cell: assert foes[cell].get('rank', 'front') != 'back', (id, cell, 'back-rank foe in front')
        for i, cell in enumerate(back):
            if cell:
                assert foes[cell].get('rank', 'front') == 'back', (id, cell, 'front foe in back')
                assert not (front[i] and foes[front[i]].get('size', 1) == 2), (id, 'cell behind a massive')
        c = {"id": id, "size": size, "tiers": tiers}
        if squad is not None: c["squad"] = squad
        if hunts: c["hunts"] = hunts
        if lead: c["lead"] = lead
        if ramp: c["ramp"] = ramp
        c["front"] = front
        c["back"] = back
        c["design"] = {"question": question}
        if note: c["design"]["note"] = note
        return c

    P = {}  # domain -> list of proposed patrol/formation compositions

    # ------------------------------------------------------------------ the Meadow
    P['meadow'] = [
        # tier one: goblin, wolf, gel, mandragora, treant
        C("goblin_warband", "formation", [1], ["goblin"]*4, ["mandragora", "mandragora", N, N],
          "The screamers cost a reroll each round they stand and every knife adds up with every goblin standing: kill count, or reach the two at the back first (they stand behind the knives).",
          "today's, kept as the foot variant"),
        C("goblin_horde", "formation", [1], ["goblin"]*4, ["mandragora"]*4,
          "Eight: four knives that add up and four screamers behind them, every column walled. Area on the front, then the back; the rerolls go a point a round while the screamers stand.",
          "new, the eight-slot variant for the ramp's middle and top"),
        C("treant_grove", "formation", [1], ["treant", "goblin", "goblin", "goblin"], [N, "mandragora", "mandragora", "mandragora"],
          "The treant fills its column and regrows what you cut; the three screamers stand behind the goblins: open a hole to reach one, and decide whether the tree or the back goes first.",
          "today's with a third mandragora"),
        C("gel_wall", "formation", [1], ["gel"]*4, ["mandragora", "mandragora", "mandragora", N],
          "Four gels split into eight halves and hold the line; the screamers behind drain the rerolls while they do. Area clears the halves, Indirect reaches past them.",
          "new; today's gel_cluster was four gels as a patrol for one, a twenty-round slog"),
        C("goblin_raiders", "patrol", [1], ["goblin", "goblin", "goblin", N], [N]*4,
          "Three knives that add up: kill one and the other two hit softer.",
          "new, a true one"),
        C("screamer_picket", "patrol", [1], ["goblin", "goblin", N, N], [N, N, "mandragora", N],
          "A screamer behind two knives, its column open: reach it or lose a reroll a round.",
          "new, a true one"),
        C("gel_pair", "patrol", [1], ["gel", "gel", N, N], [N]*4,
          "Two gels, four halves: a wall for one machine; area or patience.",
          "new; the gel_cluster's patrol half"),
        C("wolf_pack", "patrol", [1], ["wolf"]*4, [N]*4,
          "Four wolves pounce on the slowest machine and howl each other on: keep the slow one in company, or kill two before the howls stack.",
          "today's three made four and rated two: the Meadow's hunter", squad=2, hunts="slowest"),
        # tier two: goblin_guard, warg, bubble_gel, mandrake, dusk_treant, rotbloom
        C("guard_warband", "formation", [2], ["goblin_guard"]*4, ["mandrake", "mandrake", "mandrake", N],
          "Guards brace a point of plate between stabs; the mandrakes behind drain rerolls. Flak or one big blow for the plate, reach for the back.",
          "today's two goblins made guards"),
        C("guard_horde", "formation", [2], ["goblin_guard"]*4, ["mandrake"]*4,
          "Eight, every column walled: four braced knives and four screamers.",
          "new, the eight-slot variant"),
        C("treant_march", "formation", [2], ["dusk_treant", "goblin_guard", "goblin_guard", "goblin_guard"], [N, "mandrake", "mandrake", "mandrake"],
          "The dusk treant regrows four and below half its roots come up under every machine: shield the storm, burst past the regen, while the guards' plate and the mandrakes' screams cost the time you need.",
          "today's with a third mandrake"),
        C("rotblooms_bed", "formation", [2, 3], ["rotbloom", "goblin_guard", "goblin_guard", N], [N, "mandrake", N, N],
          "Bad Breath lays burning, heat, a disable and a corruption on every machine at once (a Cleanse, or a Ward); below half it seeds two mandragoras into the open ground behind. Kill it before it seeds, or kill what it seeds.",
          "today's with one mandrake, so the seedfall has two cells to land in"),
        C("gel_drift", "formation", [2], ["bubble_gel", "bubble_gel", "gel", "gel"], ["mandrake", "mandrake", N, N],
          "Skinned gels shrug a point off every blow and still split; the mandrakes behind the plate drain the rerolls while you work. Flak and area.",
          "today's patrol for one (a sixteen-round slog) made a formation with a back"),
        C("grove_and_bloom", "formation", [2], ["dusk_treant", "rotbloom", "goblin_guard", "goblin_guard"], [N, N, "mandrake", "mandrake"],
          "Two anchors: the bloom's breath and the treant's root storm, each a telegraph, behind two braced guards, with the mandrakes draining the rerolls the burst needs. Which anchor first is the fight.",
          "new, the two-anchor variant for the ramp's top (the tier-two team read every other tier-two formation free at three)"),
        C("guard_raiders", "patrol", [2], ["goblin_guard", "goblin_guard", "goblin_guard", N], [N]*4,
          "Three guards: a point of plate when they brace, knives that add up when they do not.",
          "new"),
        C("mandrake_picket", "patrol", [2], ["goblin_guard", "goblin_guard", N, N], [N, N, "mandrake", N],
          "A mandrake behind two braced knives, its column open.",
          "new"),
        C("bubble_pair", "patrol", [2], ["bubble_gel", "bubble_gel", N, N], [N]*4,
          "Two skinned gels, four halves behind a point of plate.",
          "new"),
        C("warg_pack", "patrol", [2], ["warg"]*4, [N]*4,
          "Wargs run down the weakest machine on the field: the hurt one is the prey, so it fights in company or alone to the death.",
          "today's, rated two: the Meadow's hunter", squad=2, hunts="weakest"),
        # tier three: goblin_captain (the front rank since 10 November, Ryan: "Put the captain in
        # front, yeah"; each grid below moved him into a front cell, a free one or a Guard's, and
        # waits on the pass's re-cut; the proposal's reads were taken with him in the back),
        # alpha_warg, metal_gel, alraune (back), frost_treant
        C("captains_warband", "formation", [3], ["goblin_captain", "goblin_captain", "goblin_guard", "goblin_guard"], [N, N, "alraune", "alraune"],
          "Two captains in the line shout the warband harder each round and two alraunes behind the guards turn the die's shown entry to wood: silence the shouting or reach the back, past braced knives.",
          "today's, the captains in front", lead="goblin_captain"),
        C("wolfrider_warband", "formation", [3], ["alpha_warg", "alpha_warg", "goblin_captain", "goblin_guard"], [N, N, "alraune", "alraune"],
          "Alphas howl for two and the captain shouts: the rallies stack on every blow. Kill the voices first, or every knife is a club.",
          "today's alpha_hunt as a pusher: a hunting formation rated three catches a lone machine in a fight it cannot win"),
        C("metal_drift", "formation", [3], ["metal_gel", "metal_gel", "bubble_gel", "goblin_captain"], ["mandrake", "mandrake", "alraune", N],
          "Three points of plate on the metal gels: Flak, Empowered or one big blow, while the captain rallies and the alraunes disable.",
          "today's"),
        C("treant_wilds", "formation", [3], ["frost_treant", "goblin_guard", "goblin_guard", "goblin_guard"], [N, "alraune", "alraune", N],
          "The frost treant regrows five and its roots come up under everyone below half; the alraunes behind the guards disable what you show.",
          "today's"),
        C("frost_and_bloom", "formation", [3], ["frost_treant", "rotbloom", "goblin_guard", "goblin_captain"], [N, N, "alraune", N],
          "The frost treant and the bloom side by side, a captain shouting in the line and an alraune disabling behind it: two telegraphs, a rally and a disable, the Meadow at its densest.",
          "new, the two-anchor variant for the ramp's top"),
        C("alpha_pack", "patrol", [3], ["alpha_warg", "alpha_warg", "alpha_warg", N], [N]*4,
          "Three alphas, each howling for two, run down the weakest machine.",
          "today's four made three and rated two: the Meadow's hunter", squad=2, hunts="weakest"),
        C("captains_raiders", "patrol", [3], ["goblin_guard", "goblin_guard", "goblin_guard", "goblin_captain"], [N]*4,
          "A captain among three guards shouts them harder: kill it first.",
          "new; a cut-down pusher, to be rewritten as a flanker with the roles"),
        C("metal_pair", "patrol", [3], ["metal_gel", "metal_gel", N, N], [N]*4,
          "Two gels of living metal, three plate each: nothing small lands. Flak, Empowered or a big blow.",
          "new, a heavy patrol", squad=2),
    ]

    # ------------------------------------------------------------------ the Waste
    P['waste'] = [
        # tier one: needler, antlion, cockatrice (back), sandworm
        C("needler_swarm", "formation", [1], ["needler"]*4, ["cockatrice", "cockatrice", N, N],
          "Ten needles each, through the shield: this fight is paid in hull, so it is a race. The cockatrices turn the shown entry to stone, so a second weapon on the die matters.",
          "today's, pushing now (the needlers are fodder: nobody has seen one move)"),
        C("needler_thicket", "formation", [1], ["needler"]*4, ["cockatrice"]*4,
          "Eight: four needlers and four stares, every column walled.",
          "new, the eight-slot variant"),
        C("sandworm_ambush", "formation", [1], ["sandworm", "needler", "needler", "needler"], [N, "cockatrice", "cockatrice", N],
          "The worm bites through the shield and digs in when hurt, three plate until it acts again: hit it when it is not dug in, while the needlers cost hull.",
          "today's with a second cockatrice"),
        C("antlion_pit", "formation", [1], ["antlion", "antlion", "needler", "needler"], ["cockatrice", "cockatrice", N, N],
          "Antlions dig in below half: finish one or leave it whole, never leave it half.",
          "new; led by a needler, since a hunting line never leads a pusher (Ryan, 9 November)", lead="needler"),
        C("needler_scouts", "patrol", [1, 2], ["needler", "needler", "needler", N], [N]*4,
          "Three needlers: nine through the shield a round, two HP each.",
          "today's, pushing now"),
        C("needler_pair", "patrol", [1], ["needler", "needler", N, N], [N]*4,
          "Two needlers: six through the shield a round, and two dice kill them.",
          "new, a true one"),
        C("cockatrice_roost", "patrol", [1], ["needler", N, N, N], [N, "cockatrice", "cockatrice", N],
          "Two stares turn your die to stone, one needler in front: the birds are open, kill them.",
          "new"),
        C("antlion_pair", "patrol", [1], ["antlion", "antlion", N, N], [N]*4,
          "Two antlions wait under the sand for the slowest machine; hurt, they dig in.",
          "today's, rated two: the Waste's hunter", squad=2, hunts="slowest"),
        C("antlion_trio", "patrol", [1], ["antlion", "antlion", "antlion", N], [N]*4,
          "Three antlions on the slowest machine.",
          "new, the heavier hunter candidate", squad=2, hunts="slowest"),
        # tier two: barbed_needler, pit_antlion, basilisk (back), djinn (back), night_sandworm
        C("barbed_swarm", "formation", [2], ["barbed_needler", "barbed_needler", "needler", "needler"], ["basilisk", "djinn", "basilisk", N],
          "Barbs through the shield that corrupt the entry you show, basilisks that stone your guns, and a djinn that unmakes your buffs: the Waste's whole hand, every piece behind a needler.",
          "today's, pushing now; the djinn moved to the middle"),
        C("pit_ambush", "formation", [2], ["pit_antlion", "pit_antlion", "barbed_needler", "barbed_needler"], ["basilisk", "basilisk", N, N],
          "Pit antlions bite through the shield and, hurt, sink behind a barrier that eats the next weapon blow: pop it with a cheap blow, then hit.",
          "today's needlers made barbed, pushing now, led by a barbed needler (a hunting line never leads a pusher)", lead="barbed_needler"),
        C("sandworm_pit", "formation", [2], ["night_sandworm", "barbed_needler", "barbed_needler", "barbed_needler"], [N, "basilisk", "basilisk", N],
          "The night worm bites through the shield, digs in when hurt and heaves the ground under everyone below half.",
          "today's"),
        C("djinns_mirage", "formation", [2], ["barbed_needler", "barbed_needler", "needler", "needler"], ["djinn", "djinn", "basilisk", N],
          "Two djinns unmake the buffs on the machine that carries the most, and hide in a mirage when hurt: buff late, or kill them first.",
          "new, the Waste's purge formation"),
        C("pit_wall", "formation", [2], ["pit_antlion"]*4, ["basilisk", "djinn", "basilisk", N],
          "Four pits: breaching jaws, and a barrier each when hurt that eats the next weapon blow. Pop them cheap one at a time, under the basilisks' stone and the djinn's unmaking.",
          "new, the anchor-heavy variant for the ramp's top (the barbed swarm and the mirage read as decisions for one); led by a basilisk (a hunting line never leads a pusher)", lead="basilisk"),
        C("barbed_scouts", "patrol", [2], ["barbed_needler", "barbed_needler", "barbed_needler", N], [N]*4,
          "Three barbs: through the shield, and the entry you show bites when spent.",
          "new, rated two by the reads (a decision for the Badger alone, a wall for the Skua)", squad=2),
        C("basilisk_nest", "patrol", [2], ["barbed_needler", N, N, N], [N, "basilisk", "basilisk", N],
          "Two basilisks aim at a machine showing a gun and stone it; one barb in front. The birds are open.",
          "new"),
        C("pit_pair", "patrol", [2], ["pit_antlion", "pit_antlion", N, N], [N]*4,
          "Two pit antlions wait for the slowest machine: breaching jaws and a barrier when hurt.",
          "today's four made two and rated two: the Waste's hunter", squad=2, hunts="slowest"),
        # tier three: great_needler, antlion_queen, gorgon (back), salt_sandworm, djinn
        C("great_swarm", "formation", [3], ["great_needler", "great_needler", "barbed_needler", "barbed_needler"], ["gorgon", "gorgon", "basilisk", "basilisk"],
          "Two great needlers gather for two rounds and put every needle through the shield at once: kill them, suppress them or shield their picks; the gorgons corrupt what you show.",
          "today's, pushing now"),
        C("queens_court", "formation", [3], ["antlion_queen", "pit_antlion", "pit_antlion", "barbed_needler"], ["gorgon", "gorgon", "basilisk", "basilisk"],
          "The queen's Devour is called a round ahead and comes through the shield; hurt, she digs in behind three plate. Shield the pick, pop the pits' barriers cheaply.",
          "today's, pushing now, led by a gorgon (a hunting line never leads a pusher)", lead="gorgon"),
        C("mirage_court", "formation", [3], ["great_needler", "barbed_needler", "barbed_needler", "barbed_needler"], ["djinn", "djinn", "gorgon", "gorgon"],
          "Two djinns and two gorgons behind the barbs: your buffs unmade and your shown entry corrupted or stoned every round. Play unbuffed with a second weapon, or reach the back.",
          "new, in gorgon_glare's place, which read as the great swarm", lead="gorgon"),
        C("sandworm_flats", "formation", [3], ["salt_sandworm", "great_needler", "great_needler", "great_needler"], [N, "gorgon", "gorgon", N],
          "The salt worm, oldest of its line, with three gatherers beside it and two gorgons behind them.",
          "today's"),
        C("great_scouts", "patrol", [3], ["great_needler", "barbed_needler", "barbed_needler", N], [N]*4,
          "One gatherer among the barbs: kill it inside two rounds or shield its pick.",
          "today's four made three, pushing now"),
        C("gorgon_pair", "patrol", [3], ["barbed_needler", N, N, N], [N, "gorgon", "gorgon", N],
          "Two gorgons corrupt and stone what you show, one barb in front; the gorgons are open.",
          "new, rated two by the reads (the stares wall a lone machine with few entries)", squad=2),
        C("queens_hunt", "patrol", [3], ["antlion_queen", "pit_antlion", "pit_antlion", N], [N]*4,
          "The queen and two pits wait for the slowest machine: Devour called a round ahead, barriers when hurt.",
          "new: the Waste's hunter at tier three, the antlion line", squad=2, hunts="slowest"),
    ]

    # ------------------------------------------------------------------ the Marsh
    P['marsh'] = [
        # tier one: revenant, ghost (back), zombie_knight, barrow_giant
        C("grave_host", "formation", [1], ["revenant"]*4, ["ghost", "ghost", "ghost", N],
          "Three ghosts raise a revenant into every gap you open: kill the ghosts or the host never thins; the claws add up while it stands.",
          "today's, pushing now (fodder by the goblin's codex, nearly word for word)"),
        C("grave_throng", "formation", [1], ["revenant"]*4, ["ghost"]*4,
          "Eight: four claws and four raisers, every column walled.",
          "new, the eight-slot variant"),
        C("barrow_mound", "formation", [1], ["barrow_giant", "revenant", "revenant", "revenant"], [N, "ghost", "ghost", N],
          "The giant knits three a round for three rounds once hurt: burst it or purge the mending; the ghosts refill the line.",
          "today's with a second ghost"),
        C("knights_vigil", "formation", [1], ["zombie_knight", "zombie_knight", "revenant", "revenant"], ["ghost", "ghost", N, N],
          "Knights ready themselves once hurt and get back up whole: take one from full to dead in a round, or kill the ghosts that raise the rest.",
          "new"),
        C("revenant_shamblers", "patrol", [1], ["revenant", "revenant", "revenant", N], [N]*4,
          "Three claws that add up.",
          "today's, pushing now"),
        C("ghost_light", "patrol", [1], ["revenant", "revenant", N, N], [N, N, "ghost", N],
          "A ghost behind two revenants, its column open: kill it before the line fills.",
          "new, a true one"),
        C("knights_retinue", "patrol", [1], ["zombie_knight", "zombie_knight", "revenant", N], [N]*4,
          "Two knights in armour with breaching cleavers, each getting up once: a fight for two.",
          "today's, rated two (a wall for one in the promise read)", squad=2),
        # tier two: wight, spectre (back), death_knight, grave_giant
        C("wight_host", "formation", [2], ["wight"]*4, ["spectre", "spectre", "spectre", N],
          "Wights knit when hurt and spectres strip the marks you lay and raise the dead: kill a wight whole, cash a mark before the spectre acts, and reach the back.",
          "today's, pushing now"),
        C("grave_field", "formation", [2], ["grave_giant", "wight", "wight", "wight"], [N, "spectre", "spectre", N],
          "The grave giant knits and, once hurt, readies itself to get back up whole: a wall of regeneration that wants burst.",
          "today's"),
        C("death_knights_retinue", "formation", [2], ["death_knight", "death_knight", "wight", "wight"], ["spectre", "spectre", N, N],
          "The knights' grave guard plates every foe through the next round: time your blows outside it; each knight gets up once.",
          "today's revenant made a wight"),
        C("wight_shamblers", "patrol", [2, 3], ["wight", "wight", "wight", N], [N]*4,
          "Three wights that knit when hurt: finish what you start.",
          "today's four made three, pushing now"),
        C("spectres_wake", "patrol", [2], ["wight", "wight", N, N], [N, N, "spectre", N],
          "A spectre behind two wights, its column open: it raises and it cleanses; kill it first.",
          "new"),
        C("knight_and_wights", "patrol", [2], ["death_knight", "wight", "wight", N], [N]*4,
          "A death knight plating two wights: a fight for two.",
          "today's three wights made two, rated two", squad=2),
        # tier three: dread_knight, lich (back), wraith (back), charnel_giant
        C("lichs_court", "formation", [3], ["wight", "wight", "dread_knight", "dread_knight"], ["lich", "spectre", "spectre", "wraith"],
          "The lich readies its own to rise once and the dread knights strike as they fall: kill order is the fight, the lich first, a shield up before each knight dies.",
          "today's", lead="lich"),
        C("charnel_pit", "formation", [3], ["charnel_giant", "wight", "wight", "wight"], [N, "wraith", "wraith", N],
          "The charnel giant knits four and gets back up once; the wraiths corrupt, raise and cleanse behind the wights.",
          "today's"),
        C("dread_host", "formation", [3], ["dread_knight", "dread_knight", "death_knight", "wight"], ["wraith", "wraith", "spectre", "spectre"],
          "Two death throes, a grave guard and four raisers that cleanse: the Marsh at its densest.",
          "today's"),
        C("wraith_host", "formation", [3], ["death_knight", "wight", "wight", "wight"], ["wraith", "wraith", "spectre", N],
          "One grave guard plating the line by turns, two corrupting raisers and a cleanser behind it, a column open: the choir thinned to a three.",
          "new, written after the tier-three read found every Marsh tier-three formation a wall for three on the tier's own team"),
        C("wraith_choir", "formation", [3], ["wight", "wight", "death_knight", "death_knight"], ["wraith", "wraith", "spectre", "spectre"],
          "Two grave guards plating the line by turns and four raisers behind it, two of them corrupting: time the blows between the guards, kill the choir before the line refills.",
          "today's, read again after the tier-three read left the Marsh no formation that is a decision for three", lead="wraith"),
        C("wraiths_wake", "patrol", [3], ["wight", "wight", N, N], [N, N, "wraith", N],
          "A wraith behind two wights, open: corrupting bolts, a raise and a cleanse.",
          "new, rated two by the reads (a decision for the Badger and the Boar alone, a wall for the Swallowtail)", squad=2),
        C("dread_vigil", "patrol", [3], ["dread_knight", "wight", "wight", N], [N]*4,
          "A dread knight that strikes as it falls, with two wights: a fight for two, shield up before the kill.",
          "new, a heavy patrol", squad=2),
    ]

    # ------------------------------------------------------------------ the Peak
    P['peak'] = [
        # tier one: bomb, salamander, drake (back), magma_elemental
        C("ember_pit", "formation", [1], ["salamander", "salamander", "bomb", "bomb"], ["drake", "drake", N, N],
          "Drakes behind the lizards breathe scorch and set a machine burning; the bombs burst through the shield once hurt. Kill a bomb whole or not at all, and cool what the drakes pick.",
          "today's"),
        C("ember_pyre", "formation", [1], ["salamander", "salamander", "bomb", "bomb"], ["drake"]*4,
          "Eight: four drakes behind the pit.",
          "new, the eight-slot variant"),
        C("magma_vent", "formation", [1], ["magma_elemental", "salamander", "salamander", "bomb"], [N, "drake", N, N],
          "The elemental's fist comes through the shield every round and, hurt, its cracks vent on everyone: plate answers the fist, cooling the vent; a drake behind the lizards stokes.",
          "today's with a drake"),
        C("ember_pair", "patrol", [1], ["salamander", "bomb", N, N], [N]*4,
          "One burning bite and one bomb: kill the bomb whole with a blow of four, then the lizard; half-kill the bomb and it bursts through the shield.",
          "new, the Peak's true-one candidate: the light read found the salamander pair walling a lone Skua"),
        C("salamander_pair", "patrol", [1], ["salamander", "salamander", N, N], [N]*4,
          "Two burning bites: heat you carry into the next round.",
          "new, a true one"),
        C("salamander_trio", "patrol", [1], ["salamander", "salamander", "salamander", N], [N]*4,
          "Three burning bites.",
          "today's, rated two by the reads (free for the Badger, a wall for the Skua)", squad=2),
        C("drakes_perch", "patrol", [1], ["salamander", N, N, N], [N, "drake", "drake", N],
          "Two drakes behind one lizard, open: the stoke sets you burning; kill them first.",
          "new, rated two by the reads (free for the Badger, a wall for the Skua)", squad=2),
        C("bomb_flight", "patrol", [1], ["bomb"]*4, [N]*4,
          "Four bombs that burst through the shield when hurt: kill each whole, or let a shield eat the burst.",
          "today's, pushing now (Ryan, 9 November: a bomb's counterplay is binary, so the bombs never hunt); rated one by the reads"),
        # tier two: grenade, fire_lizard, wyvern (back), basalt_elemental
        C("wyvern_roost", "formation", [2], ["fire_lizard", "fire_lizard", "bomb", "grenade"], ["wyvern", "wyvern", N, N],
          "The wyverns dive through the shield for half again their bite, the spike a Barrier or a shield is sized for; the lizards scorch three a bite.",
          "today's"),
        C("grenade_volley", "formation", [2], ["grenade", "grenade", "bomb", "fire_lizard"], ["wyvern", "wyvern", N, N],
          "Grenades burst on every machine through the shield once hurt: kill them whole, suppress them, or shield everyone.",
          "today's, pushing now"),
        C("magma_forge", "formation", [2], ["basalt_elemental", "fire_lizard", "fire_lizard", "grenade"], [N, "wyvern", N, N],
          "The basalt stokes every other foe harder and its fist breaches; below half it vents on everyone; a wyvern dives from behind the lizards.",
          "today's with a wyvern"),
        C("fire_lizards", "patrol", [2], ["fire_lizard", "fire_lizard", N, N], [N]*4,
          "Two lizards that scorch three a bite.",
          "today's four made two (a wall for one)"),
        C("lizard_trio", "patrol", [2], ["fire_lizard", "fire_lizard", "fire_lizard", N], [N]*4,
          "Three lizards: a fight for two.",
          "new, a heavy patrol", squad=2),
        C("wyverns_perch", "patrol", [2], ["fire_lizard", N, N, N], [N, "wyvern", "wyvern", N],
          "Two wyverns behind one lizard, open: the dive through the shield, or the stoke.",
          "new, rated two by every read", squad=2),
        C("grenade_flight", "patrol", [2], ["grenade", "grenade", "bomb", "bomb"], [N]*4,
          "Grenades and bombs: bursts on everyone and bursts through the shield once hurt; kill each whole.",
          "today's, pushing now (the bombs never hunt), rated two by the reads", squad=2),
        # tier three: balloon, magma_lizard, red_dragon (back), sulphur_elemental
        C("dragons_roost", "formation", [3], ["magma_lizard", "fire_lizard", "balloon", "grenade"], ["red_dragon", "red_dragon", "wyvern", "wyvern"],
          "Two dragons go for the hottest machine, crush a round ahead and scorch everyone; the lizard primes the pack to burn. Cool, shield the crush, kill the balloon whole.",
          "today's", lead="red_dragon"),
        C("magma_pit", "formation", [3], ["magma_lizard", "magma_lizard", "fire_lizard", "grenade"], ["red_dragon", "red_dragon", N, N],
          "Two primers in front of two dragons: every blow leaves you burning while they stand.",
          "today's"),
        C("balloon_storm", "formation", [3], ["balloon", "balloon", "grenade", "magma_lizard"], ["wyvern", "wyvern", "red_dragon", N],
          "Balloons swell a round and burst on everyone through the shield, scorching: one round to kill each whole, suppress it, or shield everyone.",
          "today's, pushing now"),
        C("magma_caldera", "formation", [3], ["sulphur_elemental", "magma_lizard", "magma_lizard", "balloon"], [N, "wyvern", N, N],
          "The sulphur elemental, hottest of its line, stokes the others by three and vents by five; a wyvern dives behind the primers.",
          "today's with a wyvern"),
        C("magma_lizards", "patrol", [3], ["magma_lizard", "magma_lizard", N, N], [N]*4,
          "Two primers: each lights the other's next blow.",
          "new"),
        C("dragons_perch", "patrol", [3], ["magma_lizard", N, N, N], [N, "red_dragon", N, N],
          "One dragon behind one lizard, open: the crush a round ahead, the breath on everyone.",
          "new, a heavy patrol", squad=2),
        C("balloon_flight", "patrol", [3], ["balloon", "balloon", "grenade", "grenade"], [N]*4,
          "Balloons that swell a round and grenades that burst on everyone: a round to kill each whole or shield everyone.",
          "today's, pushing now (the bombs never hunt), rated two by the reads", squad=2),
    ]

    # The pruning the reads name (docs/formation_proposal.md, section 5): each the same bands as
    # another of its domain, size and tier with the same question. `write --prune` leaves them out.
    PRUNED = {"goblin_warband", "guard_warband", "bubble_pair", "wolfrider_warband",
              "needler_swarm", "needler_pair", "antlion_pair", "djinns_mirage",
              "grave_host", "dread_host", "ember_pit", "salamander_pair"}
    prune = "--prune" in args
    if prune:
        for k in P:
            P[k] = [c for c in P[k] if c["id"] not in PRUNED]
    # The ramp gates the reads place (section 5's gate rule): a tier-one or tier-two formation that
    # reads free for three takes the foot, to Convergence 7; a tier-three formation that walls three
    # and is a decision for four takes the last two battles. The heaviest of a tier carries none.
    GATES = {"goblin_horde": [0, 7], "gel_wall": [0, 7], "needler_thicket": [0, 7], "antlion_pit": [0, 7],
             "grave_throng": [0, 7], "barrow_mound": [0, 7], "ember_pyre": [0, 7],
             "guard_horde": [4, 7], "treant_march": [4, 7], "gel_drift": [4, 7], "barbed_swarm": [4, 7],
             "pit_ambush": [4, 7], "wight_host": [4, 7], "wyvern_roost": [4, 7], "grenade_volley": [4, 7],
             "lichs_court": [11, 12]}
    for k in P:
        for c in P[k]:
            if c["id"] in GATES:
                c["ramp"] = GATES[c["id"]]
    out = copy.deepcopy(data)
    tables = []
    NAMES = {f: foes[f].get('name', f) for f in foes}
    def short(cell):
        return NAMES[cell] if cell else "·"

    for dom in out['entries']:
        did = dom['id']
        kept = [c for c in dom['compositions'] if c['size'] in ('elite', 'escort')]
        proposed = P[did]
        dom['compositions'] = proposed + kept
        tables.append(f"\n### {dom['name']}\n")
        for t in (1, 2, 3):
            rows = [c for c in proposed if t in c['tiers']]
            tables.append(f"\n**Tier {t}**\n")
            tables.append("| Composition | Size | For | Hunts | Front, left to right | Back | The question | Note |")
            tables.append("|---|---|---|---|---|---|---|---|")
            for c in rows:
                squad = c.get('squad') or {'patrol': 1, 'formation': 3}[c['size']]
                tiers = "" if c['tiers'] == [t] else f" (tiers {', '.join(map(str, c['tiers']))})"
                tables.append("| `%s`%s | %s | %d | %s | %s | %s | %s | %s |" % (
                    c['id'], tiers, c['size'], squad, c.get('hunts', '—'),
                    ", ".join(short(x) for x in c['front']), ", ".join(short(x) for x in c['back']),
                    c['design']['question'], c['design'].get('note', '')))
    json.dump(out, open(out_json, 'w'), indent=2, ensure_ascii=False)
    open(out_json, 'a').write("\n")
    open(out_md, 'w').write("\n".join(tables) + "\n")
    n_pf = sum(len(v) for v in P.values())
    print("proposed patrols and formations:", n_pf, {k: len(v) for k, v in P.items()})
    print("hunters:", [c['id'] for v in P.values() for c in v if c.get('hunts')])
    print("rated two:", [c['id'] for v in P.values() for c in v if c.get('squad') == 2])


def tables(args):

    fj, foes_path, out_md = args[0:3]
    reads = []
    by_label = {}
    for arg in args[3:]:
        label, path = arg.split("=", 1)
        if label in by_label:
            rows = by_label[label]
        else:
            rows = {}
            by_label[label] = rows
            reads.append((label, rows))
        for line in open(path):
            if not line.startswith("| ") or line.startswith("| Domain") or line.startswith("|---"):
                continue
            cells = [c.strip() for c in line.strip().strip("|").split("|")]
            if len(cells) < 14:
                continue
            domain, size, tier, cid, members, menace, ramp, rating, read_for = cells[:9]
            bands = cells[9:13]
            same = cells[13]
            rows[(cid, int(tier))] = {"bands": bands, "read_for": read_for, "same": same, "menace": menace, "rating": rating}

    data = json.load(open(fj))
    foes = {f['id']: f for f in json.load(open(foes_path))['entries']}
    NAMES = {f: foes[f].get('name', f) for f in foes}
    def short(cell): return NAMES[cell] if cell else "·"
    def band(s):
        # "decision · 33%" -> "D 33%"; "free · 0%" -> "F 0%"; "wall · 100%" -> "W 100%"
        if not s: return ""
        # A cell is a band and greedy's hull lost; since 9 November its rounds and stalled fights too.
        m = re.match(r"(free|decision|wall) · (\d+%)(?: · ([\d.]+) r)?(?: · (\d+) stalled)?", s)
        if not m:
            return s
        out = {"free": "F", "decision": "D", "wall": "W"}[m.group(1)] + " " + m.group(2)
        if m.group(3):
            out += " " + m.group(3) + "r"
        if m.group(4):
            out += " (" + m.group(4) + " stalled)"
        return out

    out = []
    for dom in data['entries']:
        proposed = [c for c in dom['compositions'] if c['size'] in ('patrol', 'formation')]
        out.append(f"\n### {dom['name']}\n")
        for t in (1, 2, 3):
            rows = [c for c in proposed if t in c['tiers']]
            out.append(f"\n**Tier {t}**: the grids\n")
            out.append("| Composition | Size | For | Hunts | Front, left to right | Back | The question | Note |")
            out.append("|---|---|---|---|---|---|---|---|")
            for c in rows:
                squad = c.get('squad') or {'patrol': 1, 'formation': 3}[c['size']]
                tiers = "" if c['tiers'] == [t] else f" (tiers {', '.join(map(str, c['tiers']))})"
                out.append("| `%s`%s | %s | %d | %s | %s | %s | %s | %s |" % (
                    c['id'], tiers, c['size'], squad, c.get('hunts', '—'),
                    ", ".join(short(x) for x in c['front']), ", ".join(short(x) for x in c['back']),
                    c['design']['question'], c['design'].get('note', '')))
            labels = [l for l, r in reads if any((c['id'], t) in r for c in rows)]
            if not labels:
                continue
            out.append(f"\nTier {t}: the reads (F free, D a decision, W a wall; greedy's hull lost beside each; one to four machines)\n")
            head = "| Composition | For | Menace |" + "".join(f" {l}: 1 | 2 | 3 | 4 |" for l in labels) + " Same as |"
            out.append(head)
            out.append("|---|---|---|" + "---|" * (4 * len(labels)) + "---|")
            for c in rows:
                squad = c.get('squad') or {'patrol': 1, 'formation': 3}[c['size']]
                cells = []
                menace = ""
                same = set()
                for l, r in reads:
                    if l not in labels: continue
                    e = r.get((c['id'], t))
                    if e is None:
                        cells += ["", "", "", ""]
                    else:
                        cells += [band(b) for b in e['bands']]
                        menace = e['menace']
                        if e['same']:
                            same.update(s.strip() for s in e['same'].split(",") if s.strip())
                out.append("| `%s` | %d | %s | %s | %s |" % (c['id'], squad, menace, " | ".join(cells), ", ".join(sorted(same))))
    open(out_md, 'w').write("\n".join(out) + "\n")
    print("wrote", out_md, "reads:", [l for l, _ in reads], "rows:", [len(r) for _, r in reads])


def summary(args):

    def load(path):
        rows = []
        for line in open(path):
            if not line.startswith("| The"):
                continue
            c = [x.strip() for x in line.strip().strip("|").split("|")]
            domain, size, tier, cid, members, menace, ramp, rating, read_for = c[:9]
            bands = []
            for b in c[9:13]:
                m = re.match(r"(free|decision|wall) · (\d+)%", b)
                bands.append((m.group(1), int(m.group(2))) if m else None)
            rows.append(dict(domain=domain, size=size, tier=int(tier), id=cid, rating=int(rating), bands=bands))
        return rows

    reads = OrderedDict()
    for arg in args:
        label, path = arg.split("=", 1)
        reads.setdefault(label, []).extend(load(path))

    for label, rows in reads.items():
        print(f"\n**{label}**: at its rating, by tier and size (free / decision / wall; mean hull lost by greedy)\n")
        print("| Tier | Size, rating | Cells | Free | Decision | Wall | Hull lost at the rating |")
        print("|---|---|---|---|---|---|---|")
        groups = defaultdict(list)
        for r in rows:
            if r['size'] == 'elite':
                continue
            groups[(r['tier'], r['size'], r['rating'])].append(r)
        for key in sorted(groups):
            t, size, rating = key
            rs = groups[key]
            counts = {'free': 0, 'decision': 0, 'wall': 0}
            hull = []
            for r in rs:
                b = r['bands'][rating - 1]
                if b:
                    counts[b[0]] += 1
                    hull.append(b[1])
            print(f"| {t} | {size}, {rating} | {len(rs)} | {counts['free']} | {counts['decision']} | {counts['wall']} | {sum(hull)/max(1,len(hull)):.0f}% |")


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    if cmd == "write":
        write(sys.argv[2:])
    elif cmd == "tables":
        tables(sys.argv[2:])
    elif cmd == "summary":
        summary(sys.argv[2:])
    else:
        print(__doc__)
        sys.exit(1)
