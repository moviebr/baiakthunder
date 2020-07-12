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

#include "guild.h"

#include "game.h"

extern Game g_game;

void Guild::addMember(Player* player)
{
	membersOnline.push_back(player);
}

void Guild::removeMember(Player* player)
{
	membersOnline.remove(player);

	if (membersOnline.empty()) {
		g_game.removeGuild(id);
		delete this;
	}
}

GuildRank* Guild::getRankById(uint32_t rankId)
{
	for (auto& rank : ranks) {
		if (rank.id == rankId) {
			return &rank;
		}
	}
	return nullptr;
}

const GuildRank* Guild::getRankByName(const std::string& name) const
{
	for (const auto& rank : ranks) {
		if (rank.name == name) {
			return &rank;
		}
	}
	return nullptr;
}

const GuildRank* Guild::getRankByLevel(uint8_t level) const
{
	for (const auto& rank : ranks) {
		if (rank.level == level) {
			return &rank;
		}
	}
	return nullptr;
}

void Guild::addRank(uint32_t rankId, const std::string& rankName, uint8_t level)
{
	ranks.emplace_front(rankId, rankName, level);
}

void Guild::addExperience(int64_t points)
{
	uint64_t currLevelExp = Guild::getExpForLevel(level);
	uint64_t nextLevelExp = Guild::getExpForLevel(level + 1);

	if (currLevelExp >= nextLevelExp) {
		return;
	}

	experience += points;

	uint32_t prevLevel = level;

	if (experience < currLevelExp) {
		while (level > 1 && experience < currLevelExp) {
			--level;
			currLevelExp = Guild::getExpForLevel(level);
		}
	} else {
		while (experience >= nextLevelExp) {
			++level;
			currLevelExp = nextLevelExp;
			nextLevelExp = Guild::getExpForLevel(level + 1);
			if (currLevelExp >= nextLevelExp) {
				break;
			}
		}
	}

	if (prevLevel != level) {
		IOGuild::saveGuild(this);
	}
}
