/**
 * The Forgotten Server - a free and open-source MMORPG server emulator
 * Copyright (C) 2019  Mark Samman <mark.samman@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#include "otpch.h"

#include "iomap.h"
#include "iomapserialize.h"
#include "combat.h"
#include "creature.h"
#include "game.h"

extern Game g_game;

bool Map::loadMap(const std::string& identifier, bool loadHouses)
{
	IOMap loader;
	if (!loader.loadMap(this, identifier)) {
		std::cout << "[Fatal - Map::loadMap] " << loader.getLastErrorString() << std::endl;
		return false;
	}

	if (!IOMap::loadSpawns(this)) {
		std::cout << "[Warning - Map::loadMap] Failed to load spawn data." << std::endl;
	}

	if (loadHouses) {
		if (!IOMap::loadHouses(this)) {
			std::cout << "[Warning - Map::loadMap] Failed to load house data." << std::endl;
		}

		IOMapSerialize::loadHouseInfo();
		IOMapSerialize::loadHouseItems(this);
	}
	return true;
}

bool Map::save()
{
	bool saved = false;
	for (uint32_t tries = 0; tries < 3; tries++) {
		if (IOMapSerialize::saveHouseInfo()) {
			saved = true;
			break;
		}
	}

	if (!saved) {
		return false;
	}

	saved = false;
	for (uint32_t tries = 0; tries < 3; tries++) {
		if (IOMapSerialize::saveHouseItems()) {
			saved = true;
			break;
		}
	}
	return saved;
}

Tile* Map::getTile(uint16_t x, uint16_t y, uint8_t z) const
{
	if (z >= MAP_MAX_LAYERS) {
		return nullptr;
	}

	const QTreeLeafNode* leaf = QTreeNode::getLeafStatic<const QTreeLeafNode*, const QTreeNode*>(&root, x, y);
	if (!leaf) {
		return nullptr;
	}

	const Floor* floor = leaf->getFloor(z);
	if (!floor) {
		return nullptr;
	}
	return floor->tiles[x & FLOOR_MASK][y & FLOOR_MASK];
}

void Map::setTile(uint16_t x, uint16_t y, uint8_t z, Tile* newTile)
{
	if (z >= MAP_MAX_LAYERS) {
		std::cout << "ERROR: Attempt to set tile on invalid coordinate " << Position(x, y, z) << "!" << std::endl;
		return;
	}

	QTreeLeafNode::newLeaf = false;
	QTreeLeafNode* leaf = root.createLeaf(x, y, 15);

	if (QTreeLeafNode::newLeaf) {
		//update north
		QTreeLeafNode* northLeaf = root.getLeaf(x, y - FLOOR_SIZE);
		if (northLeaf) {
			northLeaf->leafS = leaf;
		}

		//update west leaf
		QTreeLeafNode* westLeaf = root.getLeaf(x - FLOOR_SIZE, y);
		if (westLeaf) {
			westLeaf->leafE = leaf;
		}

		//update south
		QTreeLeafNode* southLeaf = root.getLeaf(x, y + FLOOR_SIZE);
		if (southLeaf) {
			leaf->leafS = southLeaf;
		}

		//update east
		QTreeLeafNode* eastLeaf = root.getLeaf(x + FLOOR_SIZE, y);
		if (eastLeaf) {
			leaf->leafE = eastLeaf;
		}
	}

	Floor* floor = leaf->createFloor(z);
	uint32_t offsetX = x & FLOOR_MASK;
	uint32_t offsetY = y & FLOOR_MASK;

	Tile*& tile = floor->tiles[offsetX][offsetY];
	if (tile) {
		TileItemVector* items = newTile->getItemList();
		if (items) {
			for (auto it = items->rbegin(), end = items->rend(); it != end; ++it) {
				tile->addThing(*it);
			}
			items->clear();
		}

		Item* ground = newTile->getGround();
		if (ground) {
			tile->addThing(ground);
			newTile->setGround(nullptr);
		}
		delete newTile;
	} else {
		tile = newTile;
	}
}

bool Map::placeCreature(const Position& centerPos, Creature* creature, bool extendedPos/* = false*/, bool forceLogin/* = false*/)
{
	bool foundTile;
	bool placeInPZ;

	Tile* tile = getTile(centerPos.x, centerPos.y, centerPos.z);
	if (tile) {
		placeInPZ = tile->hasFlag(TILESTATE_PROTECTIONZONE);
		ReturnValue ret = tile->queryAdd(0, *creature, 1, FLAG_IGNOREBLOCKITEM);
		foundTile = forceLogin || ret == RETURNVALUE_NOERROR || ret == RETURNVALUE_PLAYERISNOTINVITED;
	} else {
		placeInPZ = false;
		foundTile = false;
	}

	if (!foundTile) {
		static std::vector<std::pair<int32_t, int32_t>> extendedRelList {
			                   {0, -2},
			         {-1, -1}, {0, -1}, {1, -1},
			{-2, 0}, {-1,  0},          {1,  0}, {2, 0},
			         {-1,  1}, {0,  1}, {1,  1},
			                   {0,  2}
		};

		static std::vector<std::pair<int32_t, int32_t>> normalRelList {
			{-1, -1}, {0, -1}, {1, -1},
			{-1,  0},          {1,  0},
			{-1,  1}, {0,  1}, {1,  1}
		};

		std::vector<std::pair<int32_t, int32_t>>& relList = (extendedPos ? extendedRelList : normalRelList);

		if (extendedPos) {
			std::shuffle(relList.begin(), relList.begin() + 4, getRandomGenerator());
			std::shuffle(relList.begin() + 4, relList.end(), getRandomGenerator());
		} else {
			std::shuffle(relList.begin(), relList.end(), getRandomGenerator());
		}

		for (const auto& it : relList) {
			Position tryPos(centerPos.x + it.first, centerPos.y + it.second, centerPos.z);

			tile = getTile(tryPos.x, tryPos.y, tryPos.z);
			if (!tile || (placeInPZ && !tile->hasFlag(TILESTATE_PROTECTIONZONE))) {
				continue;
			}

			if (tile->queryAdd(0, *creature, 1, 0) == RETURNVALUE_NOERROR) {
				if (!extendedPos || isSightClear(centerPos, tryPos, false)) {
					foundTile = true;
					break;
				}
			}
		}

		if (!foundTile) {
			return false;
		}
	}

	int32_t index = 0;
	uint32_t flags = 0;
	Item* toItem = nullptr;

	Cylinder* toCylinder = tile->queryDestination(index, *creature, &toItem, flags);
	toCylinder->internalAddThing(creature);

	const Position& dest = toCylinder->getPosition();
	getQTNode(dest.x, dest.y)->addCreature(creature);
	return true;
}

void Map::moveCreature(Creature& creature, Tile& newTile, bool forceTeleport/* = false*/)
{
	Tile& oldTile = *creature.getTile();

	Position oldPos = oldTile.getPosition();
	Position newPos = newTile.getPosition();

	bool teleport = forceTeleport || !newTile.getGround() || !Position::areInRange<1, 1, 1>(oldPos, newPos);

	SpectatorVector spectators;
	if (!teleport) {
		int32_t minRangeX = maxViewportX;
		int32_t maxRangeX = maxViewportX;
		int32_t minRangeY = maxViewportY;
		int32_t maxRangeY = maxViewportY;
		if (oldPos.y > newPos.y) {
			++minRangeY;
		} else if (oldPos.y < newPos.y) {
			++maxRangeY;
		}

		if (oldPos.x < newPos.x) {
			++maxRangeX;
		} else if (oldPos.x > newPos.x) {
			++minRangeX;
		}
		getSpectators(spectators, oldPos, true, false, minRangeX, maxRangeX, minRangeY, maxRangeY);
	} else {
		SpectatorVector newspectators;
		getSpectators(spectators, oldPos, true);
		getSpectators(newspectators, newPos, true);
		spectators.mergeSpectators(newspectators);
	}

	std::vector<int32_t> oldStackPosVector;
	for (Creature* spectator : spectators) {
		if (Player* tmpPlayer = spectator->getPlayer()) {
			if (tmpPlayer->canSeeCreature(&creature)) {
				oldStackPosVector.push_back(oldTile.getClientIndexOfCreature(tmpPlayer, &creature));
			} else {
				oldStackPosVector.push_back(-1);
			}
		}
	}

	//remove the creature
	oldTile.removeThing(&creature, 0);

	QTreeLeafNode* leaf = getQTNode(oldPos.x, oldPos.y);
	QTreeLeafNode* new_leaf = getQTNode(newPos.x, newPos.y);

	// Switch the node ownership
	if (leaf != new_leaf) {
		leaf->removeCreature(&creature);
		new_leaf->addCreature(&creature);
	}

	//add the creature
	newTile.addThing(&creature);

	if (!teleport) {
		if (oldPos.y > newPos.y) {
			creature.setDirection(DIRECTION_NORTH);
		} else if (oldPos.y < newPos.y) {
			creature.setDirection(DIRECTION_SOUTH);
		}

		if (oldPos.x < newPos.x) {
			creature.setDirection(DIRECTION_EAST);
		} else if (oldPos.x > newPos.x) {
			creature.setDirection(DIRECTION_WEST);
		}
	}

	//send to client
	size_t i = 0;
	for (Creature* spectator : spectators) {
		if (Player* tmpPlayer = spectator->getPlayer()) {
			//Use the correct stackpos
			int32_t stackpos = oldStackPosVector[i++];
			if (stackpos != -1) {
				tmpPlayer->sendCreatureMove(&creature, newPos, newTile.getStackposOfCreature(tmpPlayer, &creature), oldPos, stackpos, teleport);
			}
		}
	}

	//event method
	for (Creature* spectator : spectators) {
		spectator->onCreatureMove(&creature, &newTile, newPos, &oldTile, oldPos, teleport);
	}

	oldTile.postRemoveNotification(&creature, &newTile, 0);
	newTile.postAddNotification(&creature, &oldTile, 0);

	clearSpectatorCache(creature.getPlayer());
}

void Map::getSpectatorsInternal(SpectatorVector& spectators, const Position& centerPos, int32_t minRangeX, int32_t maxRangeX, int32_t minRangeY, int32_t maxRangeY, int32_t minRangeZ, int32_t maxRangeZ, bool onlyPlayers) const
{
	int32_t min_y = centerPos.y - minRangeY;
	int32_t min_x = centerPos.x - minRangeX;
	int32_t max_y = centerPos.y + maxRangeY;
	int32_t max_x = centerPos.x + maxRangeX;

	uint32_t width = static_cast<uint32_t>(max_x - min_x);
	uint32_t height = static_cast<uint32_t>(max_y - min_y);
	uint32_t depth = static_cast<uint32_t>(maxRangeZ - minRangeZ);

	int32_t minoffset = centerPos.getZ() - maxRangeZ;
	int32_t x1 = std::min<int32_t>(0xFFFF, std::max<int32_t>(0, (min_x + minoffset)));
	int32_t y1 = std::min<int32_t>(0xFFFF, std::max<int32_t>(0, (min_y + minoffset)));

	int32_t maxoffset = centerPos.getZ() - minRangeZ;
	int32_t x2 = std::min<int32_t>(0xFFFF, std::max<int32_t>(0, (max_x + maxoffset)));
	int32_t y2 = std::min<int32_t>(0xFFFF, std::max<int32_t>(0, (max_y + maxoffset)));

	int32_t startx1 = x1 - (x1 & FLOOR_MASK);
	int32_t starty1 = y1 - (y1 & FLOOR_MASK);
	int32_t endx2 = x2 - (x2 & FLOOR_MASK);
	int32_t endy2 = y2 - (y2 & FLOOR_MASK);

	const QTreeLeafNode* startLeaf = QTreeNode::getLeafStatic<const QTreeLeafNode*, const QTreeNode*>(&root, startx1, starty1);
	const QTreeLeafNode* leafS = startLeaf;
	const QTreeLeafNode* leafE;

	for (int_fast32_t ny = starty1; ny <= endy2; ny += FLOOR_SIZE) {
		leafE = leafS;
		for (int_fast32_t nx = startx1; nx <= endx2; nx += FLOOR_SIZE) {
			if (leafE) {
				const CreatureVector& node_list = (onlyPlayers ? leafE->player_list : leafE->creature_list);
				for (auto it = node_list.begin(), end = node_list.end(); it != end; ++it) {
					Creature* creature = (*it);

					const Position& cpos = creature->getPosition();
					if (static_cast<uint32_t>(static_cast<int32_t>(cpos.z) - minRangeZ) <= depth) {
						int_fast16_t offsetZ = Position::getOffsetZ(centerPos, cpos);
						if (static_cast<uint32_t>(static_cast<int32_t>(cpos.x - offsetZ) - min_x) <= width && static_cast<uint32_t>(static_cast<int32_t>(cpos.y - offsetZ) - min_y) <= height) {
							spectators.emplace_back(creature);
						}
					}
				}
				leafE = leafE->leafE;
			} else {
				leafE = QTreeNode::getLeafStatic<const QTreeLeafNode*, const QTreeNode*>(&root, nx + FLOOR_SIZE, ny);
			}
		}

		if (leafS) {
			leafS = leafS->leafS;
		} else {
			leafS = QTreeNode::getLeafStatic<const QTreeLeafNode*, const QTreeNode*>(&root, startx1, ny + FLOOR_SIZE);
		}
	}
	spectators.shrink_to_fit();
}

void Map::getSpectators(SpectatorVector& spectators, const Position& centerPos, bool multifloor /*= false*/, bool onlyPlayers /*= false*/, int32_t minRangeX /*= 0*/, int32_t maxRangeX /*= 0*/, int32_t minRangeY /*= 0*/, int32_t maxRangeY /*= 0*/)
{
	if (centerPos.z >= MAP_MAX_LAYERS) {
		return;
	}

	bool foundCache = false;
	bool cacheResult = false;

	minRangeX = (minRangeX == 0 ? maxViewportX : minRangeX);
	maxRangeX = (maxRangeX == 0 ? maxViewportX : maxRangeX);
	minRangeY = (minRangeY == 0 ? maxViewportY : minRangeY);
	maxRangeY = (maxRangeY == 0 ? maxViewportY : maxRangeY);

	if (minRangeX == maxViewportX && maxRangeX == maxViewportX && minRangeY == maxViewportY && maxRangeY == maxViewportY && multifloor) {
		if (onlyPlayers) {
			auto it = playersSpectatorCache.find(centerPos);
			if (it != playersSpectatorCache.end()) {
				if (!spectators.empty()) {
					const SpectatorVector& cachedSpectators = it->second;
					spectators.insert(spectators.end(), cachedSpectators.begin(), cachedSpectators.end());
				} else {
					spectators = it->second;
				}

				foundCache = true;
			}
		}

		if (!foundCache) {
			auto it = spectatorCache.find(centerPos);
			if (it != spectatorCache.end()) {
				if (!onlyPlayers) {
					if (!spectators.empty()) {
						const SpectatorVector& cachedSpectators = it->second;
						spectators.insert(spectators.end(), cachedSpectators.begin(), cachedSpectators.end());
					} else {
						spectators = it->second;
					}
				} else {
					const SpectatorVector& cachedSpectators = it->second;
					for (Creature* spectator : cachedSpectators) {
						if (spectator->getPlayer()) {
							spectators.emplace_back(spectator);
						}
					}
				}

				foundCache = true;
			} else {
				cacheResult = true;
			}
		}
	}

	if (!foundCache) {
		int32_t minRangeZ;
		int32_t maxRangeZ;

		if (multifloor) {
			if (centerPos.z > 7) {
				//underground

				//8->15
				minRangeZ = std::max<int32_t>(centerPos.getZ() - 2, 0);
				maxRangeZ = std::min<int32_t>(centerPos.getZ() + 2, MAP_MAX_LAYERS - 1);
			} else if (centerPos.z == 6) {
				minRangeZ = 0;
				maxRangeZ = 8;
			} else if (centerPos.z == 7) {
				minRangeZ = 0;
				maxRangeZ = 9;
			} else {
				minRangeZ = 0;
				maxRangeZ = 7;
			}
		} else {
			minRangeZ = centerPos.z;
			maxRangeZ = centerPos.z;
		}

		if (spectators.capacity() < 32) {
			spectators.reserve(32);
		}

		getSpectatorsInternal(spectators, centerPos, minRangeX, maxRangeX, minRangeY, maxRangeY, minRangeZ, maxRangeZ, onlyPlayers);

		if (cacheResult) {
			if (onlyPlayers) {
				playersSpectatorCache[centerPos] = spectators;
			} else {
				spectatorCache[centerPos] = spectators;
			}
		}
	}
}

void Map::clearSpectatorCache(bool clearPlayer)
{
	spectatorCache.clear();
	if (clearPlayer) {
		playersSpectatorCache.clear();
	}
}

void Map::clearPlayersSpectatorCache()
{
	playersSpectatorCache.clear();
}

bool Map::canThrowObjectTo(const Position& fromPos, const Position& toPos, bool checkLineOfSight /*= true*/,
                           int32_t rangex /*= Map::maxClientViewportX*/, int32_t rangey /*= Map::maxClientViewportY*/) const
{
	//z checks
	//underground 8->15
	//ground level and above 7->0
	if ((fromPos.z >= 8 && toPos.z < 8) || (toPos.z >= 8 && fromPos.z < 8)) {
		return false;
	}

	int32_t deltaz = Position::getDistanceZ(fromPos, toPos);
	if (deltaz > 2) {
		return false;
	}

	if ((Position::getDistanceX(fromPos, toPos) - deltaz) > rangex) {
		return false;
	}

	//distance checks
	if ((Position::getDistanceY(fromPos, toPos) - deltaz) > rangey) {
		return false;
	}

	if (!checkLineOfSight) {
		return true;
	}
	return isSightClear(fromPos, toPos, false);
}

bool Map::checkSightLine(const Position& fromPos, const Position& toPos) const
{
	if (fromPos == toPos) {
		return true;
	}

	Position start(fromPos.z > toPos.z ? toPos : fromPos);
	Position destination(fromPos.z > toPos.z ? fromPos : toPos);

	const int8_t mx = start.x < destination.x ? 1 : start.x == destination.x ? 0 : -1;
	const int8_t my = start.y < destination.y ? 1 : start.y == destination.y ? 0 : -1;

	int32_t A = Position::getOffsetY(destination, start);
	int32_t B = Position::getOffsetX(start, destination);
	int32_t C = -(A * destination.x + B * destination.y);

	while (start.x != destination.x || start.y != destination.y) {
		int32_t move_hor = std::abs(A * (start.x + mx) + B * (start.y) + C);
		int32_t move_ver = std::abs(A * (start.x) + B * (start.y + my) + C);
		int32_t move_cross = std::abs(A * (start.x + mx) + B * (start.y + my) + C);

		if (start.y != destination.y && (start.x == destination.x || move_hor > move_ver || move_hor > move_cross)) {
			start.y += my;
		}

		if (start.x != destination.x && (start.y == destination.y || move_ver > move_hor || move_ver > move_cross)) {
			start.x += mx;
		}

		const Tile* tile = getTile(start.x, start.y, start.z);
		if (tile && tile->hasProperty(CONST_PROP_BLOCKPROJECTILE)) {
			return false;
		}
	}

	// now we need to perform a jump between floors to see if everything is clear (literally)
	while (start.z != destination.z) {
		const Tile* tile = getTile(start.x, start.y, start.z);
		if (tile && tile->getThingCount() > 0) {
			return false;
		}

		start.z++;
	}

	return true;
}

bool Map::isSightClear(const Position& fromPos, const Position& toPos, bool floorCheck) const
{
	if (floorCheck && fromPos.z != toPos.z) {
		return false;
	}

	// Cast two converging rays and see if either yields a result.
	return checkSightLine(fromPos, toPos) || checkSightLine(toPos, fromPos);
}

const Tile* Map::canWalkTo(const Creature& creature, const Position& pos) const
{
	int32_t walkCache = creature.getWalkCache(pos);
	if (walkCache == 0) {
		return nullptr;
	} else if (walkCache == 1) {
		return getTile(pos.x, pos.y, pos.z);
	}

	//used for non-cached tiles
	Tile* tile = getTile(pos.x, pos.y, pos.z);
	if (!tile || tile->queryAdd(0, creature, 1, FLAG_PATHFINDING | FLAG_IGNOREFIELDDAMAGE) != RETURNVALUE_NOERROR) {
		return nullptr;
	}
	return tile;
}

bool Map::getPathMatching(const Creature& creature, const Position& targetPos, std::vector<Direction>& dirList, const FrozenPathingConditionCall& pathCondition, const FindPathParams& fpp) const
{
	Position pos = creature.getPosition();
	Position endPos;

	AStarNodes nodes(pos.x, pos.y, AStarNodes::getTileWalkCost(creature, getTile(pos.x, pos.y, pos.z)));

	int32_t bestMatch = 0;

	static int_fast32_t dirNeighbors[8][5][2] = {
		{{-1, 0}, {0, 1}, {1, 0}, {1, 1}, {-1, 1}},
		{{-1, 0}, {0, 1}, {0, -1}, {-1, -1}, {-1, 1}},
		{{-1, 0}, {1, 0}, {0, -1}, {-1, -1}, {1, -1}},
		{{0, 1}, {1, 0}, {0, -1}, {1, -1}, {1, 1}},
		{{1, 0}, {0, -1}, {-1, -1}, {1, -1}, {1, 1}},
		{{-1, 0}, {0, -1}, {-1, -1}, {1, -1}, {-1, 1}},
		{{0, 1}, {1, 0}, {1, -1}, {1, 1}, {-1, 1}},
		{{-1, 0}, {0, 1}, {-1, -1}, {1, 1}, {-1, 1}}
	};
	static int_fast32_t allNeighbors[8][2] = {
		{-1, 0}, {0, 1}, {1, 0}, {0, -1}, {-1, -1}, {1, -1}, {1, 1}, {-1, 1}
	};

	const Position startPos = pos;

	const int_fast32_t sX = std::abs(targetPos.getX() - pos.getX());
	const int_fast32_t sY = std::abs(targetPos.getY() - pos.getY());

	AStarNode* found = nullptr;
	while (fpp.maxSearchDist != 0 || nodes.getClosedNodes() < 100) {
		AStarNode* n = nodes.getBestNode();
		if (!n) {
			if (found) {
				break;
			}
			return false;
		}

		const int_fast32_t x = n->x;
		const int_fast32_t y = n->y;
		pos.x = x;
		pos.y = y;
		if (pathCondition(startPos, pos, fpp, bestMatch)) {
			found = n;
			endPos = pos;
			if (bestMatch == 0) {
				break;
			}
		}

		uint_fast32_t dirCount;
		int_fast32_t* neighbors;
		if (n->parent) {
			const int_fast32_t offset_x = n->parent->x - x;
			const int_fast32_t offset_y = n->parent->y - y;
			if (offset_y == 0) {
				if (offset_x == -1) {
					neighbors = *dirNeighbors[DIRECTION_WEST];
				} else {
					neighbors = *dirNeighbors[DIRECTION_EAST];
				}
			} else if (offset_x == 0) {
				if (offset_y == -1) {
					neighbors = *dirNeighbors[DIRECTION_NORTH];
				} else {
					neighbors = *dirNeighbors[DIRECTION_SOUTH];
				}
			} else if (offset_y == -1) {
				if (offset_x == -1) {
					neighbors = *dirNeighbors[DIRECTION_NORTHWEST];
				} else {
					neighbors = *dirNeighbors[DIRECTION_NORTHEAST];
				}
			} else if (offset_x == -1) {
				neighbors = *dirNeighbors[DIRECTION_SOUTHWEST];
			} else {
				neighbors = *dirNeighbors[DIRECTION_SOUTHEAST];
			}
			dirCount = 5;
		} else {
			dirCount = 8;
			neighbors = *allNeighbors;
		}

		const int_fast32_t f = n->f;
		for (uint_fast32_t i = 0; i < dirCount; ++i) {
			pos.x = x + *neighbors++;
			pos.y = y + *neighbors++;

			const Tile* tile;
			int_fast32_t extraCost;
			AStarNode* neighborNode = nodes.getNodeByPosition(pos.x, pos.y);
			if (neighborNode) {
				tile = getTile(pos.x, pos.y, pos.z);
				extraCost = neighborNode->c;
			} else {
				tile = Map::canWalkTo(creature, pos);
				if (!tile) {
					continue;
				}
				extraCost = AStarNodes::getTileWalkCost(creature, tile);
			}

			//The cost (g) for this neighbor
			const int_fast32_t cost = AStarNodes::getMapWalkCost(n, pos);
			const int_fast32_t newf = f + cost + extraCost;
			if (neighborNode) {
				if (neighborNode->f <= newf) {
					//The node on the closed/open list is cheaper than this one
					continue;
				}
				neighborNode->f = newf;
				neighborNode->parent = n;
				nodes.openNode(neighborNode);
			} else {
				//Does not exist in the open/closed list, create a new node
				const int_fast32_t dX = std::abs(targetPos.getX() - pos.getX());
				const int_fast32_t dY = std::abs(targetPos.getY() - pos.getY());
				if (!nodes.createOpenNode(n, pos.x, pos.y, newf, ((dX - sX) << 3) + ((dY - sY) << 3) + (std::max(dX, dY) << 3), extraCost)) {
					if (found) {
						break;
					}
					return false;
				}
			}
		}
		nodes.closeNode(n);
	}
	if (!found) {
		return false;
	}

	int_fast32_t prevx = endPos.x;
	int_fast32_t prevy = endPos.y;

	found = found->parent;
	while (found) {
		pos.x = found->x;
		pos.y = found->y;

		int_fast32_t dx = pos.getX() - prevx;
		int_fast32_t dy = pos.getY() - prevy;

		prevx = pos.x;
		prevy = pos.y;
		if (dx == 1) {
			if (dy == 1) {
				dirList.emplace_back(DIRECTION_NORTHWEST);
			} else if (dy == -1) {
				dirList.emplace_back(DIRECTION_SOUTHWEST);
			} else {
				dirList.emplace_back(DIRECTION_WEST);
			}
		} else if (dx == -1) {
			if (dy == 1) {
				dirList.emplace_back(DIRECTION_NORTHEAST);
			} else if (dy == -1) {
				dirList.emplace_back(DIRECTION_SOUTHEAST);
			} else {
				dirList.emplace_back(DIRECTION_EAST);
			}
		} else if (dy == 1) {
			dirList.emplace_back(DIRECTION_NORTH);
		} else if (dy == -1) {
			dirList.emplace_back(DIRECTION_SOUTH);
		}
		found = found->parent;
	}
	return true;
}

bool Map::getPathMatchingCond(const Creature& creature, const Position& targetPos, std::vector<Direction>& dirList, const FrozenPathingConditionCall& pathCondition, const FindPathParams& fpp) const
{
	Position pos = creature.getPosition();
	Position endPos;

	AStarNodes nodes(pos.x, pos.y, AStarNodes::getTileWalkCost(creature, getTile(pos.x, pos.y, pos.z)));

	int32_t bestMatch = 0;

	static int_fast32_t dirNeighbors[8][5][2] = {
		{{-1, 0}, {0, 1}, {1, 0}, {1, 1}, {-1, 1}},
		{{-1, 0}, {0, 1}, {0, -1}, {-1, -1}, {-1, 1}},
		{{-1, 0}, {1, 0}, {0, -1}, {-1, -1}, {1, -1}},
		{{0, 1}, {1, 0}, {0, -1}, {1, -1}, {1, 1}},
		{{1, 0}, {0, -1}, {-1, -1}, {1, -1}, {1, 1}},
		{{-1, 0}, {0, -1}, {-1, -1}, {1, -1}, {-1, 1}},
		{{0, 1}, {1, 0}, {1, -1}, {1, 1}, {-1, 1}},
		{{-1, 0}, {0, 1}, {-1, -1}, {1, 1}, {-1, 1}}
	};
	static int_fast32_t allNeighbors[8][2] = {
		{-1, 0}, {0, 1}, {1, 0}, {0, -1}, {-1, -1}, {1, -1}, {1, 1}, {-1, 1}
	};

	const Position startPos = pos;

	const int_fast32_t sX = std::abs(targetPos.getX() - pos.getX());
	const int_fast32_t sY = std::abs(targetPos.getY() - pos.getY());

	AStarNode* found = nullptr;
	while (fpp.maxSearchDist != 0 || nodes.getClosedNodes() < 100) {
		AStarNode* n = nodes.getBestNode();
		if (!n) {
			if (found) {
				break;
			}
			return false;
		}

		const int_fast32_t x = n->x;
		const int_fast32_t y = n->y;
		pos.x = x;
		pos.y = y;
		if (pathCondition(startPos, pos, fpp, bestMatch)) {
			found = n;
			endPos = pos;
			if (bestMatch == 0) {
				break;
			}
		}

		uint_fast32_t dirCount;
		int_fast32_t* neighbors;
		if (n->parent) {
			const int_fast32_t offset_x = n->parent->x - x;
			const int_fast32_t offset_y = n->parent->y - y;
			if (offset_y == 0) {
				if (offset_x == -1) {
					neighbors = *dirNeighbors[DIRECTION_WEST];
				} else {
					neighbors = *dirNeighbors[DIRECTION_EAST];
				}
			} else if (offset_x == 0) {
				if (offset_y == -1) {
					neighbors = *dirNeighbors[DIRECTION_NORTH];
				} else {
					neighbors = *dirNeighbors[DIRECTION_SOUTH];
				}
			} else if (offset_y == -1) {
				if (offset_x == -1) {
					neighbors = *dirNeighbors[DIRECTION_NORTHWEST];
				} else {
					neighbors = *dirNeighbors[DIRECTION_NORTHEAST];
				}
			} else if (offset_x == -1) {
				neighbors = *dirNeighbors[DIRECTION_SOUTHWEST];
			} else {
				neighbors = *dirNeighbors[DIRECTION_SOUTHEAST];
			}
			dirCount = 5;
		} else {
			dirCount = 8;
			neighbors = *allNeighbors;
		}

		const int_fast32_t f = n->f;
		for (uint_fast32_t i = 0; i < dirCount; ++i) {
			pos.x = x + *neighbors++;
			pos.y = y + *neighbors++;

			if (fpp.maxSearchDist != 0 && (Position::getDistanceX(startPos, pos) > fpp.maxSearchDist || Position::getDistanceY(startPos, pos) > fpp.maxSearchDist)) {
				continue;
			}

			if (fpp.keepDistance && !pathCondition.isInRange(startPos, pos, fpp)) {
				continue;
			}

			const Tile* tile;
			int_fast32_t extraCost;
			AStarNode* neighborNode = nodes.getNodeByPosition(pos.x, pos.y);
			if (neighborNode) {
				tile = getTile(pos.x, pos.y, pos.z);
				extraCost = neighborNode->c;
			} else {
				tile = canWalkTo(creature, pos);
				if (!tile) {
					continue;
				}
				extraCost = AStarNodes::getTileWalkCost(creature, tile);
			}

			//The cost (g) for this neighbor
			const int_fast32_t cost = AStarNodes::getMapWalkCost(n, pos);
			const int_fast32_t newf = f + cost + extraCost;

			if (neighborNode) {
				if (neighborNode->f <= newf) {
					//The node on the closed/open list is cheaper than this one
					continue;
				}

				neighborNode->f = newf;
				neighborNode->parent = n;
				nodes.openNode(neighborNode);
			} else {
				//Does not exist in the open/closed list, create a new node
				const int_fast32_t dX = std::abs(targetPos.getX() - pos.getX());
				const int_fast32_t dY = std::abs(targetPos.getY() - pos.getY());
				if (!nodes.createOpenNode(n, pos.x, pos.y, newf, ((dX - sX) << 3) + ((dY - sY) << 3) + (std::max(dX, dY) << 3), extraCost)) {
					if (found) {
						break;
					}
					return false;
				}
			}
		}

		nodes.closeNode(n);
	}

	if (!found) {
		return false;
	}

	int_fast32_t prevx = endPos.x;
	int_fast32_t prevy = endPos.y;

	found = found->parent;
	while (found) {
		pos.x = found->x;
		pos.y = found->y;

		int_fast32_t dx = pos.getX() - prevx;
		int_fast32_t dy = pos.getY() - prevy;

		prevx = pos.x;
		prevy = pos.y;

		if (dx == 1) {
			if (dy == 1) {
				dirList.emplace_back(DIRECTION_NORTHWEST);
			} else if (dy == -1) {
				dirList.emplace_back(DIRECTION_SOUTHWEST);
			} else {
				dirList.emplace_back(DIRECTION_WEST);
			}
		} else if (dx == -1) {
			if (dy == 1) {
				dirList.emplace_back(DIRECTION_NORTHEAST);
			} else if (dy == -1) {
				dirList.emplace_back(DIRECTION_SOUTHEAST);
			} else {
				dirList.emplace_back(DIRECTION_EAST);
			}
		} else if (dy == 1) {
			dirList.emplace_back(DIRECTION_NORTH);
		} else if (dy == -1) {
			dirList.emplace_back(DIRECTION_SOUTH);
		}

		found = found->parent;
	}
	return true;
}

// AStarNodes

AStarNodes::AStarNodes(uint32_t x, uint32_t y, int_fast32_t extraCost): nodes(), openNodes()
{
	curNode = 1;
	closedNodes = 0;
	openNodes[0] = true;

	AStarNode& startNode = nodes[0];
	startNode.parent = nullptr;
	startNode.x = x;
	startNode.y = y;
	startNode.f = 0;
	startNode.g = 0;
	startNode.c = extraCost;
	nodesTable[0] = (x << 16) | y;
	#if defined(__SSE2__)
	calculatedNodes[0] = 0;
	#endif
}

bool AStarNodes::createOpenNode(AStarNode* parent, uint32_t x, uint32_t y, int_fast32_t f, int_fast32_t heuristic, int_fast32_t extraCost)
{
	if (curNode >= MAX_NODES) {
		return false;
	}

	int32_t retNode = curNode++;
	openNodes[retNode] = true;

	AStarNode& node = nodes[retNode];
	node.parent = parent;
	node.x = x;
	node.y = y;
	node.f = f;
	node.g = heuristic;
	node.c = extraCost;
	nodesTable[retNode] = (x << 16) | y;
	#if defined(__SSE2__)
	calculatedNodes[retNode] = f + node.g;
	#endif
	return true;
}

AStarNode* AStarNodes::getBestNode()
{
	#if defined(__SSE2__)

	int32_t best_node_f = std::numeric_limits<int32_t>::max();
	int32_t best_node = -1;

	int32_t curRound = ((curNode >> 3) << 3);
	for (int32_t i = 0; i < curRound; i += 8) {
		__m128i v1 = _mm_load_si128(reinterpret_cast<const __m128i*>(&calculatedNodes[i]));
		__m128i v2 = _mm_load_si128(reinterpret_cast<const __m128i*>(&calculatedNodes[i + 4]));
		#if defined(__SSE4_1__)
		__m128i res = _mm_min_epi32(v1, v2);
		res = _mm_min_epi32(res, _mm_shuffle_epi32(res, _MM_SHUFFLE(2, 3, 0, 1)));
		res = _mm_min_epi32(res, _mm_shuffle_epi32(res, _MM_SHUFFLE(0, 1, 2, 3)));
		#else
		auto _mm_sse2_min_epi32 = [](const __m128i a, const __m128i b) {
			__m128i mask = _mm_cmpgt_epi32(a, b);
			return _mm_or_si128(_mm_and_si128(mask, b), _mm_andnot_si128(mask, a));
		};
		__m128i res = _mm_sse2_min_epi32(v1, v2);
		res = _mm_sse2_min_epi32(res, _mm_shuffle_epi32(res, _MM_SHUFFLE(2, 3, 0, 1)));
		res = _mm_sse2_min_epi32(res, _mm_shuffle_epi32(res, _MM_SHUFFLE(0, 1, 2, 3)));
		#endif
		int32_t index = i + (_mm_ctz(_mm_movemask_epi8(_mm_packs_epi32(_mm_cmpeq_epi32(v1, res), _mm_cmpeq_epi32(v2, res)))) >> 1);
		if (calculatedNodes[index] < best_node_f) {
			best_node_f = calculatedNodes[index];
			best_node = index;
		}
	}
	for (int32_t i = curRound; i < curNode; ++i) {
		if (!openNodes[i]) {
			continue;
		}

		if (calculatedNodes[i] < best_node_f) {
			best_node_f = calculatedNodes[i];
			best_node = i;
		}
	}

	return (best_node != -1 ? &nodes[best_node] : nullptr);
	#else
	int_fast32_t best_node_f = std::numeric_limits<int32_t>::max();
	int32_t best_node = -1;
	for (int32_t i = 0; i < curNode; ++i) {
		if (!openNodes[i]) {
			continue;
		}

	int_fast32_t diffNode = nodes[i].f + nodes[i].g;
		if (diffNode < best_node_f) {
			best_node_f = diffNode;
			best_node = i;
		}
	}
	return (best_node != -1 ? &nodes[best_node] : nullptr);
	#endif
}

void AStarNodes::closeNode(AStarNode* node)
{
	size_t index = node - nodes;
	assert(index < MAX_NODES);
	#if defined(__SSE2__)
	calculatedNodes[index] = std::numeric_limits<int32_t>::max();
	#endif
	openNodes[index] = false;
	++closedNodes;
}

void AStarNodes::openNode(AStarNode* node)
{
	size_t index = node - nodes;
	assert(index < MAX_NODES);
	#if defined(__SSE2__)
	calculatedNodes[index] = nodes[index].f + nodes[index].g;
	#endif
	closedNodes -= (openNodes[index] ? 0 : 1);
	openNodes[index] = true;
}

int32_t AStarNodes::getClosedNodes() const
{
	return closedNodes;
}

AStarNode* AStarNodes::getNodeByPosition(uint32_t x, uint32_t y)
{
	uint32_t xy = (x << 16) | y;
	#if defined(__SSE2__)
	const __m128i key = _mm_set1_epi32(xy);

	int32_t curRound = ((curNode >> 3) << 3);
	for (int32_t i = 0; i < curRound; i += 8) {
		const uint32_t mask = _mm_movemask_epi8(_mm_packs_epi32(_mm_cmpeq_epi32(_mm_load_si128(reinterpret_cast<const __m128i*>(&nodesTable[i])), key), _mm_cmpeq_epi32(_mm_load_si128(reinterpret_cast<const __m128i*>(&nodesTable[i + 4])), key)));
		if (mask != 0) {
			return &nodes[i + (_mm_ctz(mask) >> 1)];
		}
	}
	for (int32_t i = curRound; i < curNode; ++i) {
		if (nodesTable[i] == xy) {
			return &nodes[i];
		}
	}
	return nullptr;
	#else
	for (int32_t i = 1; i < curNode; ++i) {
		if (nodesTable[i] == xy) {
			return &nodes[i];
		}
	}
	return (nodesTable[0] == xy ? &nodes[0] : nullptr); // The first node is very unlikely to be the "neighbor" so leave it for end
	#endif
}

inline int_fast32_t AStarNodes::getMapWalkCost(AStarNode* node, const Position& neighborPos)
{
	//diagonal movement extra cost
	return (((std::abs(node->x - neighborPos.x) + std::abs(node->y - neighborPos.y)) - 1) * MAP_DIAGONALWALKCOST) + MAP_NORMALWALKCOST;
}

inline int_fast32_t AStarNodes::getTileWalkCost(const Creature& creature, const Tile* tile)
{
	int_fast32_t cost = 0;
	if (tile->getTopVisibleCreature(&creature) != nullptr) {
		//destroy creature cost
		cost += MAP_NORMALWALKCOST * 4;
	}

	if (const MagicField* field = tile->getFieldItem()) {
		CombatType_t combatType = field->getCombatType();
		if (!creature.isImmune(combatType) && !creature.hasCondition(Combat::DamageToConditionType(combatType))) {
			cost += MAP_NORMALWALKCOST * 18;
		}
	}
	return cost;
}

// Floor
Floor::~Floor()
{
	for (auto& row : tiles) {
		for (auto tile : row) {
			delete tile;
		}
	}
}

// QTreeNode
QTreeNode::~QTreeNode()
{
	for (auto* ptr : child) {
		delete ptr;
	}
}

QTreeLeafNode* QTreeNode::getLeaf(uint32_t x, uint32_t y)
{
	if (leaf) {
		return static_cast<QTreeLeafNode*>(this);
	}

	QTreeNode* node = child[((x & 0x8000) >> 15) | ((y & 0x8000) >> 14)];
	if (!node) {
		return nullptr;
	}
	return node->getLeaf(x << 1, y << 1);
}

QTreeLeafNode* QTreeNode::createLeaf(uint32_t x, uint32_t y, uint32_t level)
{
	if (!isLeaf()) {
		uint32_t index = ((x & 0x8000) >> 15) | ((y & 0x8000) >> 14);
		if (!child[index]) {
			if (level != FLOOR_BITS) {
				child[index] = new QTreeNode();
			} else {
				child[index] = new QTreeLeafNode();
				QTreeLeafNode::newLeaf = true;
			}
		}
		return child[index]->createLeaf(x << 1, y << 1, level - 1);
	}
	return static_cast<QTreeLeafNode*>(this);
}

// QTreeLeafNode
bool QTreeLeafNode::newLeaf = false;

QTreeLeafNode::~QTreeLeafNode()
{
	for (auto* ptr : array) {
		delete ptr;
	}
}

Floor* QTreeLeafNode::createFloor(uint32_t z)
{
	if (!array[z]) {
		array[z] = new Floor();
	}
	return array[z];
}

void QTreeLeafNode::addCreature(Creature* c)
{
	creature_list.push_back(c);

	if (c->getPlayer()) {
		player_list.push_back(c);
	}
}

void QTreeLeafNode::removeCreature(Creature* c)
{
	auto iter = std::find(creature_list.begin(), creature_list.end(), c);
	assert(iter != creature_list.end());
	*iter = creature_list.back();
	creature_list.pop_back();

	if (c->getPlayer()) {
		iter = std::find(player_list.begin(), player_list.end(), c);
		assert(iter != player_list.end());
		*iter = player_list.back();
		player_list.pop_back();
	}
}

uint32_t Map::clean() const
{
	uint64_t start = OTSYS_TIME();
	size_t count = 0, tiles = 0;

	if (g_game.getGameState() == GAME_STATE_NORMAL) {
		g_game.setGameState(GAME_STATE_MAINTAIN);
	}

	std::vector<const QTreeNode*> nodes {
		&root
	};
	std::vector<Item*> toRemove;
	do {
		const QTreeNode* node = nodes.back();
		nodes.pop_back();
		if (node->isLeaf()) {
			const QTreeLeafNode* leafNode = static_cast<const QTreeLeafNode*>(node);
			for (uint8_t z = 0; z < MAP_MAX_LAYERS; ++z) {
				Floor* floor = leafNode->getFloor(z);
				if (!floor) {
					continue;
				}

				for (auto& row : floor->tiles) {
					for (auto tile : row) {
						if (!tile || tile->hasFlag(TILESTATE_PROTECTIONZONE)) {
							continue;
						}

						TileItemVector* itemList = tile->getItemList();
						if (!itemList) {
							continue;
						}

						++tiles;
						for (Item* item : *itemList) {
							if (item->isCleanable()) {
								toRemove.push_back(item);
							}
						}

						for (Item* item : toRemove) {
							g_game.internalRemoveItem(item, -1);
						}
						count += toRemove.size();
						toRemove.clear();
					}
				}
			}
		} else {
			for (auto childNode : node->child) {
				if (childNode) {
					nodes.push_back(childNode);
				}
			}
		}
	} while (!nodes.empty());

	if (g_game.getGameState() == GAME_STATE_MAINTAIN) {
		g_game.setGameState(GAME_STATE_NORMAL);
	}

	std::cout << "> CLEAN: Removed " << count << " item" << (count != 1 ? "s" : "")
	          << " from " << tiles << " tile" << (tiles != 1 ? "s" : "") << " in "
	          << (OTSYS_TIME() - start) / (1000.) << " seconds." << std::endl;
	return count;
}
