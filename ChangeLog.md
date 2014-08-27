0.0.1:
First release!

0.0.2:
- Fixed talent gain from digestion.
- Fixed generic, category, and prodigy point gain on levelup.
- Made Inhale's range "official".
- Fixed directory structure.

0.0.3:
– Hunger no longer affects global speed.
– Starvation threshold is higher. This means you start getting penalties from Hunger at higher Hunger levels.
– Base, object, inscription, racial, undead, and prodigy talents are now excluded from talents you can learn from Digestion.
– Decreased stat point gain from Digestion.
– Added temporary icons for all Gluttony talents.
– Fixed a bug where Inhale would throw an error on use.
– Fixed a bug where Catabolize would throw an error on an empty stomach.
– Catabolize is now instant.
– Lowered cooldown of Catabolize from 75 to 60.
– Halved the global speed bonus from Anabolism.
– Salivate's daze power now scales with mindpower in addition to CON.
– Devour now does damage. You will Devour an enemy if the damage is enough to kill it.
– Digest and Catabolize can now be activated only if your stomach is not empty.

0.0.4:
– Devour now ignores instakill resistance. >:)
– You can now learn talents from Digesting any creature.
– Decreased effect of Hunger on life regen so that at max Hunger, your life regen will stay above 0.00 at the start of the game.
– Decreased stat bonuses from Digestion (again). You no longer gain stat points from Digesting elites.
– You are now granted 10 stat points on birth.
– Fixed Devour targeting message.
– You no longer start with the Combat Techniques category.
– You can no longer Devour self-resurrecting creatures.
– Digest, Catabolize, and Regurgitate now each display the next creature to be used.
– Catabolize now displays the Catabolize results for the next creature to be used.

0.0.5:
– Talents learned from Digestion are now capped at both the effective level of Gastric Acid and the level at which the digested creature knew the talent.
– If you already know a talent at or above maximum learnable level, then that talent will not be selected for a learning attempt.
– Fixed learning object talents like Block, Command Staff, Shoot, and Reload.
– Telekinetic Grasp is now unlearnable directly from Digestion.
– Increased stat gain from bosses from 2 to 3.
– Now works with Classic UI.

0.0.6:
– You can now unlearn a Digested talent from the right-click menu in the use-talent menu ('m').
– Added a new talent, Excrete, which is learned automatically with Digestion and is used to immediately remove a creature from your stomach.
– Added effect icons.
– Ward is now excluded from Digestable talents.
– Gorge now correctly Devours enemies even if it applies enough extra physical damage to kill them.
– Inhale's use range is now correctly 0.
– Removed Catabolize's Hunger increase.
– Decreased cooldown on Catabolize.
– Digestion is now uncancellable.

0.0.6a:
Fixed a bug that caused talents to be learnable past the cap restrictions if the digested creature had more than one talent.

0.0.6b:
– Digesting no longer stops you from entering the world map.
– Learnable talents are now limited to the level of Digest instead of the level of Gastric Acid.
– Regurgitate and Catabolize are now disabled if your stomach is empty.
– Decreased Gorge's damage scaling with talent level.

0.0.7:
– You now gain stat points normally (per level) instead of from Digesting creatures.
– Learned talents are now capped to the raw level of Digest instead of the effective level.
– The total level of learned talents is now capped to your total Constitution.
– The number of talents learned from Digestion is now capped based on your Constitution. You can forget talents to learn new ones.
– There is now a new category, Pica. The skill “Pica” has been renamed to “Eat Walls” and moved to the Pica category, which contains Eat Walls and three new skills: Consume Item, Swallow Gem, and Consume Artifact.
– A new talent, Predation, has replaced Pica in the Feast category.
– Catabolize has replaced Gastric Acid in the Digestion category. A new talent, Voracity, has taken its place in Famine.
– Rares can no longer be Gluttons.
– Endless Hunt, Predator, and Cursed Form categories now start unlocked.
– Unlearning a talent now unlearns only those levels learned from Digestion.
– The option to unlearn a talent now appears only when that talent has levels learned from Digestion.
– Eat Walls (previously Pica) now correctly satiates Hunger.
– Regurgitate now displays its radius while targeting.
– You can no longer Devour Regurgitated creatures.
– You can no longer Devour yourself.
– You can no longer learn golemancy talents.
– You can no longer learn the golem talents Armour Configuration and Self-Destruct.
– You can no longer learn the enemy-only talents Summon, Shriek, Howl, Multiply, Shadow Phase Door, and Shadow Blindside.
– Devour now has decreased power as well as diminishing returns.
– Gorge's damage has been decreased.
– Digest now has diminishing returns on its cooldown.

0.0.7a:
Mousing over CON in the levelup dialog now displays your current and maximum number and total levels of Digested talents.

0.0.7b:
– Passive talents can now be unlearned. As a side effect, they can also be bound or automated, which does nothing.
– Fixed a typo bug related to the radius of Regurgitate.
– Fixed a bug where killing enemies with Devour wouldn't devour them.

0.0.7c:
– Voracity now works.
– You can no longer learn Dredge Frenzy, Frenzied Leap, or Frenzied Bite.
– You can now eat trees with Eat Walls. (thanks to Zonk)
– Devour messages now display in the correct order.
– Digest no longer falsely claims to grant you stat points.

0.0.7d:
– You can no longer learn innate or hidden talents.
