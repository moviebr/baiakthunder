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

#include "position.h"

std::ostream& operator<<(std::ostream& os, const Position& pos)
{
	os << "( " << std::setw(5) << std::setfill('0') << pos.x;
	os << " / " << std::setw(5) << std::setfill('0') << pos.y;
	os << " / " << std::setw(3) << std::setfill('0') << pos.getZ();
	os << " )";
	return os;
}

std::ostream& operator<<(std::ostream& os, const Direction& dir)
{
	switch (dir) {
		case DIRECTION_NORTH:
			os << "Norte";
			break;

		case DIRECTION_EAST:
			os << "Leste";
			break;

		case DIRECTION_WEST:
			os << "Oeste";
			break;

		case DIRECTION_SOUTH:
			os << "Sul";
			break;

		case DIRECTION_SOUTHWEST:
			os << "Sudoeste";
			break;

		case DIRECTION_SOUTHEAST:
			os << "Sudeste";
			break;

		case DIRECTION_NORTHWEST:
			os << "Noroeste";
			break;

		case DIRECTION_NORTHEAST:
			os << "Nordeste";
			break;

		default:
			break;
	}

	return os;
}
