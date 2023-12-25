## Changelog
V0.1.0
 Första version
 
V0.2.0
* Fixade resolution så att det såg bra ut på TV
* Skapade ett enklare end game med hjälp av flutter BloC
* Programmerade om health bar så att den är med dynamisk och funktionell
* Små bugfixar

V0.3.0
* Programmerade om alla komponenter och deras lifecycle, så att allt utgår nu från Player. Först skapas en Player som sen skapar upp resterande komponenter som childs.
* Programmerade om spelets lifecycle och event så att dem använer BloC istället så att allt är event baserat.
* Diverse bugfixar.

## Version todos
V0.3.0
[x] - Programmera om komponenter så att dem är child av Player
	[x] - Unicorn
	[x] - Waste Pile
	[x] - Stock Pile
	[x] - Foundations
	[x] - Health bar
[x] - Spelets lifecycle och BloC baserat
[x] - Under en turn så kan knappen bli "grå markerad"
[ ] - Add obisdian documentation to github
[ ] - Clean up
[ ] - Release

v.0.3.1
[ ] - Flytta position render logiken till respektive komponent istället för Player komponenten
[ ] - För health/damage kort rendrera flera digit position
[ ] - Gör en clean up på alla const width/height i StarshipShooter klassen
[ ] - Justera positionerna på Health komponenten
[ ] - Lägg in regions och kommentarer i koder