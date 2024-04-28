# Expendable
You are a criminal. Maybe you were a desparate survivor, doing whatever you could to provide, or maybe an innocent man and a victim of circumstance, corruption, and unseen enemies. None of that matters, all that matters now is your fate. You were sentenced to death but there was a light at the end of the tunnel, a secondary deal: an experiment and final favor for the same government that put you in chains. Your job is to descend into the depths of a seemingly infinite anomalous underwater structure, known to researchers as the Womb of God, and reach its final floor. Each floor is filled with dangers and monsters beyond science and imagination and your only defense is a mysterious device capable of controlling the same monsters that hunger for your flesh. If you survive, you will be granted freedom and your past is expunged. If you fail, well, they don't exactly call you "indispensable".

<!-- vscode-markdown-toc -->
1. [About](#About)
2. [Combat](#Combat)
3. [Upgrading](#Upgrading)
4. [The Map](#TheMap)
5. [The Type System](#TheTypeSystem)<br/>
	5.1. [Damage Types](#DamageTypes)<br/>
	5.2. [Horror Types](#HorrorTypes)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

##  1. <a name='About'></a>About
Expendable is a turn-based roguelike game that combines aspects of Pokemon and various dungeon crawlers. The player will explore a number of floors that are composed of various rooms, containing horrors, secrets, and treasures. In combat the player will control a number of horrors that they've been able to capture as well as themselves to ensure survival.

##  2. <a name='Combat'></a>Combat
Combat is turn-based. The player controls 5 units: themselves, and up to 4 captured horrors. Both allies and enemies are positioned left-to-right with characters closest to the center being at the "front", similar to Darkest Dungeon.

<img src="https://images.gog-statics.com/01c122f165752c6d20ca0c13c8b2c3b8c02e3cb6f9f1b4b75a31926a082aa7c0_product_card_v2_mobile_slider_639.jpg">

Positioning is a pivotal part of Expendable. Moves have limited targetting, such as some moves only being able to target creatures in the back. For balancing, most moves will target creatures in the front, thus it is usually the most dangerous position to be in. However that may change depending on the exact type of moves being used. 

The player character is a pretty useless meat bag that does little to no damage, however, if they die, they lose, so keeping them alive is pivotal. To do that, the player character is capable of manipulating the position of their units to prevent the most amount of damage coming to them. For example, the player can swap positions with characters or command a creature to take a portion of the damage they would normally take. 

The player can also purchase items that are basically like one-use moves they have.

The player will also be able to see what moves the enemies are going to do while selecting their moves. This way the player can strategize about how to dodge attacks and minimize the damage they take. Kinda like how in Slay the Spire enemies project a hint at what they are going to do. For example, in the image the right-most enemy is planning on attacking for 12 damage.

<img src="https://cdn.vox-cdn.com/thumbor/8uCDajAh6RrUz7k1q8UeuIlaRpE=/1400x788/filters:format(jpeg)/cdn.vox-cdn.com/uploads/chorus_asset/file/13684451/ss_25ed2537de5d4fa71c6d6d5632f21ac21fe4b3bf.jpg">

Both enemy and controlled Horrors will have up to 4 moves. The turn order is based on speed as well as modifiers to speed, like for example a slower Horror can use a "fast" move that has increased priority. 

##  3. <a name='Upgrading'></a>Upgrading
Completing a combat will reward the player with a certain amount of EXP, which unlike in RPGs, is not immediately used but instead stored for later use. This "currency" can be traded in at certain locations to boost their creature's stats, or even mutating them entirely into new forms. Think Pokemon Evolution and EVs.

##  4. <a name='TheMap'></a>The Map
I'm not sure how many floors the Womb of God is gonna have yet. I think it would make sense for there to be a post-game mode with infinite procedurally generated floors but maybe for the main story there's only like 4-5? Maybe even fewer,

Floors are composed of rooms, along with a final room that leads to the next floor. Maybe the final room can be a legendary Pokemon encounter. I currently have the following ideas for rooms:
- Encounters: Obviously we have to be able to go into a room and encounter enemies that may kill us.
- Rest sites: Places to heal up the player and horrors. Could also be where the player can spend some of their hard earned EXP
- Merchant: A mysterious entity can be found in certain rooms on the map, from whom rare captured horrors can be traded for, as well as in-battle items. 
- Events: In the role play sense, these are misc events that happen as the player explores. Maybe they encountered a wall that they can break down if one of their Horrors knows a Physical move and breaking it down allows them to access an unexplored area of the map. They can also be a way to slowly reveal the lore and story of the Womb of God. 

If this sounds familiar, it's because it's based off of Slay the Spire's map.

<img src="https://steamuserimages-a.akamaihd.net/ugc/1833543457082604474/E418CF4AC7E64627DADA5B048743C21B2CFAF558/">

Different rooms not only hold different things but also control how you move across the map. You can only move to rooms that are connected to your current room. The player can see what type of rooms are on the floor but not the exact occurrence in those rooms. Like you can see there's an encounter room coming up but not what enemies are in that encounter. This creates a bit of strategy for how the player wants to traverse the map.

##  5. <a name='TheTypeSystem'></a>The Type System

###  5.1. <a name='DamageTypes'></a>Damage Types
Pokemon has a rock-paper-scissors-esque battle system where certain types are super effective against others. I want to create a system that also makes certain moves stronger than others depending on the situation but a bit more complex.

Like in Pokemon moves deal certain types of damage but unlike Pokemon, their effectiveness is determined by the last damage type the creature took as well as the creature's type (more on that later).

So for example you may have something like this:

```
Burn -> Freeze -> Shock -> Corrosive -> Burn
```

A creature hit by `burn` damage will then take extra damage from `freeze` damage then by `shock`, then by `corrosive` then by `burn` once more. 

I want the damage types to be based off actual damage you may experience in a laboratory setting. Here's what I got so far:

```
Burn -> Freeze -> Shock -> Corrosive -> Burn

Radioactive -> Radioactive

Psychic

Physical
```

The most common moves will be Physical and the "Elemental" types. 

Radioactive being effective against itself is obviously very strong and will thus be a rare type of damage.

Psychic can't deal extra combo damage but is also resisted by none of the Creature types. Speaking of...

###  5.2. <a name='HorrorTypes'></a>Horror Types
The scientific community has classified all the horrors in the Womb into one of the following categories:

```
Biological: Corrupted animal/plant-like creatures
Sapient: Intelligent creatures, like humans
Construct: Creatures of artificial origin
Monstrosity: Otherworldy creatures of unknown origin
Ethereals: Ghost-like creatures
```

These creatures have their own type weaknesses, kind of like Pokemon types.

For example, `Biological` creatures normally take extra `burn` damage. So if you hit a `Biological` horror with `corrosive` then `burn`
they'd take a ton of damage, kind of like a 4x super effective hit in Pokemon.