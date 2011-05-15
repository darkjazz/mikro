/*
 *  osc.h
 *  mikro
 *
 *  Created by alo on 22/04/2011.
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
#ifndef OSC_H
#define OSC_H

#include <vector>
#include "util.h"
#include "lo/lo.h"
#include "world.h"
#include "ogl.h"

using namespace std; 

class OSC {

public:
	OSC(const char*, const char*, World*, GraphicsRenderer*);
	~OSC();
	
	void sendStates (float*, int);
	void sendBMU(int x, int y, double state, vector<double>* values);	
	void startListener();
	void stopListener();
	int getDone();
	float getBGRed();
	float getBGGreen();
	float getBGBlue();
	float getAddParam();
	float getTransX();
	float getTransY();
	float getTransZ();	
	bool getWeightsChanged();
	vector<double> getWeights();
	void updateSettings();
	void updatePatterns();

private:	
	lo_server_thread thread;
	lo_address addr;
	World* ptrWrld;
	GraphicsRenderer* ptrGR;
};

void error(int num, const char *msg, const char *path);

int quit_handler(const char *path, const char *types, lo_arg **argv, int argc, 
				 void *data, void *user_data);

int background_handler(const char *path, const char *types, lo_arg **argv, int argc, 
				 void *data, void *user_data);

int weights_handler(const char *path, const char *types, lo_arg **argv, int argc, 
					   void *data, void *user_data);

int settings_handler(const char *path, const char *types, lo_arg **argv, int argc, 
					 void *data, void *user_data);

int pattern_handler(const char *path, const char *types, lo_arg **argv, int argc, 
					 void *data, void *user_data);


#endif