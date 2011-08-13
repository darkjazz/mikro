/*
 *  mikro.h
 *  mikro
 *
 *  Created by alo on 21/04/2011.
 *  
 *	This file is part of mikro.
 *
 *	mikro is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 
 *	mikro is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 
 *	You should have received a copy of the GNU General Public License
 *	along with mikro.  If not, see <http://www.gnu.org/licenses/>. 
 *
 */
#ifndef MIKRO_H
#define MIKRO_H

#include "fssimplewindow.h"
#include "world.h"
#include "ogl.h"
#include "util.h"
#include "osc.h"

#define SCREENWIDTH		1440

using namespace std; 

void runApp (int, int, int, int, int, int, const char*, const char*, int, int, double);

void drawFrame(void);

void collectStates(int, int);

void setCells(int);

#endif