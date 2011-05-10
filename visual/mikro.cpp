/*
 *  mikro.cpp
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

#include "mikro.h"

int sizeX=40, sizeY=40, debugMode=1, width=800, height=600, frameRate=30, vecSize=8, trainDur=1000;
const char* host = "127.0.0.1";
const char* port = "57120";
float delta;
bool isRunning = true;
double learnRate = 0.1;

World* world;
OSC* responder;
Node* bmu;
GraphicsRenderer* ogl;

void drawFrame (void) {
	
	ogl->initFrame(world, bmu, width, height);
	
	glLoadIdentity();
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);	
			
	for (int x = 0; x < sizeX; x++) {
		for (int y = 0; y < sizeY; y++) {
			ogl->drawFragment( &world->nodes[x][y], x, y);
		}
	}
	
	glClearColor(responder->getBGRed(), responder->getBGGreen(), responder->getBGBlue(), 1.0);
	
	FsSwapBuffers();
}

void runApp (int x, int y, int dbg, int w, int h, int f, const char* a, const char* p, int vs, int td, double lr) {
	
	int i;
	
	sizeX = x ?: sizeX; 
	sizeY = y ?: sizeY; 
	debugMode = dbg ?: debugMode; 
	width = w ?: width;	
	height = h ?: height; 
	frameRate = f ?: frameRate; 
	host = a ?: host; 
	port = p ?: port;
	vecSize = vs ?: vecSize;
	trainDur = td ?: trainDur;
	learnRate = lr ?: learnRate;
	
	bmu = NULL;
	
	if (debugMode == 1)
		FsOpenWindow(0,  0, width, height, 1);
	else
		FsOpenWindow(SCREENWIDTH, 0, width, height, 1);
		
	delta = 1.0/frameRate;
	
	world = new World(sizeX, sizeY, vecSize, trainDur, learnRate);

	ogl = new GraphicsRenderer();
	
	ogl->setupOgl();
	
	responder = new OSC(a, p, world, ogl);

	responder->startListener();

	while (isRunning) {
		responder->updateSettings();
		if (responder->getWeightsChanged()) {			
			bmu = world->train(responder->getWeights());
			for (i = 0; i < 3; i++) {
				world->nodes[bmu->x][bmu->y].states[i] = 1.0;
			}
			responder->updatePatterns();			
		}
		drawFrame();
		FsSleep(delta*1000);
		if ((responder->getDone()) == 1) {
			isRunning = false;
		}
	}
	
	delete world;
	
	responder->stopListener();
	
	delete responder;
	
	delete ogl;
	
}

