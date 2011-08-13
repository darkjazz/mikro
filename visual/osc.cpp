/*
 *  osc.cpp
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

#include "osc.h"

int done = 0;

float bgRed = 0, bgGreen = 0, bgBlue = 0, addParam = 0.995, bgAlpha, patAlpha;
float transx = 0, transy = 0, transz = 0;
int patIndex, patActive, groupx = 10, groupy = 10, phase = 1, symmetry = 2;

vector<double> weights;
bool weightsChanged = false, patternChanged = false;
int size;

OSC::OSC(const char* host, const char* port, World* wrld, GraphicsRenderer* oglr) {
	addr = lo_address_new(host, port);
	ptrWrld = wrld;
	ptrGR = oglr;
}

OSC::~OSC() {
	addr = NULL;
	ptrWrld = NULL;
	weights.clear();
}

void OSC::sendStates (float* states, int num)
{
	lo_blob data = lo_blob_new(sizeof(float) * num, states);
	lo_send(addr, "/mikro/states", "b", data);
}

void OSC::sendBMU (int x, int y, double state, vector<double> * values)
{
	int i;
	float *arr;
	
	arr = new float[size+3];
	
	arr[0] = (float)x;
	arr[1] = (float)y;
	arr[2] = (float)state;
	
	for (i = 0; i < size; i++)
	{
		arr[i+3] = (float)values->at(i);
	}
	
	lo_blob data = lo_blob_new(sizeof(float) * (size+3), arr);
	lo_send(addr, "/mikro/bmu", "b", data);

	delete [] arr;
	
}

void OSC::startListener ()
{
	size = ptrWrld->vectorSize();
	char vec[size+1];
	int i;
	
	for (i = 0; i < size; i++) {
		vec[i] = 'f';
	}
	vec[i] = '\0';
	
	thread = lo_server_thread_new("7770", error);
	
	lo_server_thread_add_method(thread, "/mikro/quit", "i", quit_handler, NULL);
	lo_server_thread_add_method(thread, "/mikro/weights", vec, weights_handler, NULL);	
	lo_server_thread_add_method(thread, "/mikro/settings", "ffffffffiiii", settings_handler, NULL);	
	lo_server_thread_add_method(thread, "/mikro/pattern", "iif", pattern_handler, NULL);	
	lo_server_thread_start(thread);
		
}

void OSC::stopListener ()
{
	lo_server_thread_free(thread);
}

void OSC::updateSettings() {
	ptrWrld->setAdd((double)addParam);
}

void OSC::updatePatterns() {
	if (patternChanged) {
		ptrGR->patternLib[patIndex].active = (bool)patActive;
		ptrGR->patternLib[patIndex].alpha = patAlpha;
		patternChanged = false;
	}
}

int OSC::getDone () { return done; }
float OSC::getBGRed() { return bgRed; }
float OSC::getBGGreen() { return bgGreen; }
float OSC::getBGBlue() { return bgBlue; }
float OSC::getBGAlpha() { return bgAlpha; }
float OSC::getAddParam() { return addParam; }
float OSC::getTransX() { return transx; };
float OSC::getTransY() { return transy; };
float OSC::getTransZ() { return transz; };	
int OSC::getGroupX() { return groupx; }
int OSC::getGroupY() { return groupy; }
int OSC::getPhase() { return phase; }
int OSC::getSymmetry() { return symmetry; }
bool OSC::getWeightsChanged() { return weightsChanged; }

vector<double> OSC::getWeights() {  
	int x;
	x = weights.size();
	weightsChanged = false;
	return weights; 
}

int quit_handler(const char *path, const char *types, lo_arg **argv, int argc, 
				 void *data, void *user_data)
{
	done = 1;
	return 0;
}

int weights_handler(const char *path, const char *types, lo_arg **argv, int argc, 
					   void *data, void *user_data)
{
	weights.clear();
	for (int i = 0; i < size; i++) {
		weights.push_back((double)(argv[i]->f));
	}
	weightsChanged = true;
	return 0;
}

int settings_handler(const char *path, const char *types, lo_arg **argv, int argc, 
					void *data, void *user_data)
{
	addParam = argv[0]->f;
	bgRed = argv[1]->f;
	bgGreen = argv[2]->f;
	bgBlue = argv[3]->f;
	bgAlpha = argv[4]->f;
	transx = argv[5]->f;
	transy = argv[6]->f;
	transz = argv[7]->f;
	groupx = argv[8]->i;
	groupy = argv[9]->i;
	phase = argv[10]->i;
	symmetry = argv[11]->i;
	return 0;
}

int pattern_handler(const char *path, const char *types, lo_arg **argv, int argc, 
					 void *data, void *user_data)
{
	patternChanged = true;
	patIndex = argv[0]->i;
	patActive = argv[1]->i;
	patAlpha = argv[2]->f;
	return 0;
}



void error (int num, const char *msg, const char *path)
{
	printf("liblo server %d error in path %s: %s\n", num, path, msg);
	fflush(stdout);
}