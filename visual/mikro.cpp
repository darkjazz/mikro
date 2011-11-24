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
double delta;
bool isRunning = true;
double learnRate = 0.1;
float* avgStates;

int grpSize = 10;

bool flicker = false;

World* world;
OSC* responder;
Node* bmu;
GraphicsRenderer* ogl;

enum cellSymmetry { NONE, DIAGONAL, FULL };

void setCells() {
	// symmetry flag: 0 - no symmetry, 1 - diagonal, 2 - square
	
	int i, xx, yy, hlfx, hlfy, sym;
	
	sym = responder->getSymmetry();
	
	for (i = 0; i < 3; i++) {
		world->nodes[bmu->x][bmu->y].states[i] = 0.5;
	}		

	if (sym > NONE)
	{
		hlfx = world->sizeX() / 2 - 1;
		hlfy = world->sizeY() / 2 - 1;
		
		if (bmu->x > hlfx) 
		{ 
			xx = hlfx - wrapi(bmu->x, 0, hlfx); 
		}
		else
		{	
			xx = (world->sizeX() - 1) - bmu->x; 
		}
		
		if (bmu->y > hlfy)
		{	
			yy = hlfy - wrapi(bmu->y, 0, hlfy); 
		}
		else
		{	
			yy = (world->sizeY() - 1) - bmu->y; 
		}
		
		for (i = 0; i < 3; i++) {
			world->nodes[xx][yy].states[i] = 0.5;
		}				
		
		if (sym == FULL) {
			
			for (i = 0; i < 3; i++) {
				world->nodes[bmu->x][yy].states[i] = 0.5;
			}				
			
			for (i = 0; i < 3; i++) {
				world->nodes[xx][bmu->y].states[i] = 0.5;
			}
		}

	}
	
}

void drawFrame (void) {
	Node* thisNode;
	vector<double> weights;
	bool weightsUpdated;
	
	responder->updateSettings();
		
	glLoadIdentity();
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);	
	
	glTranslatef(responder->getTransX(), responder->getTransY() , responder->getTransZ());

	weightsUpdated = responder->getWeightsChanged();

	if (weightsUpdated) {
		weights = responder->getWeights();
		bmu = world->findBMU(weights);
		setCells();
		responder->sendBMU(bmu->x, bmu->y, bmu->states[world->index()], &bmu->weights);
	}
	
	ogl->prepareFrame();
		
	for (int x = 0; x < sizeX; x++) {
		for (int y = 0; y < sizeY; y++) {
			thisNode = &world->nodes[x][y];
			if (weightsUpdated) {
				world->train(weights, thisNode, bmu);
			}
			thisNode->nextState(world->add(), world->index());			
			ogl->drawFragment( &world->nodes[x][y], bmu, x, y);
			collectStates(x, y);
		}
		ogl->drawRow();
	}
	
	ogl->drawWorld();
	
	responder->updatePatterns();	

	world->incrementTrainCount();
		
	world->incrementIndex();
	
	/*
	if (flicker)
	{
		glClearColor(responder->getBGRed(), responder->getBGGreen(), responder->getBGBlue(), responder->getBGAlpha());
		flicker = false;
	}
	else
	{
		glClearColor(responder->getBGRed(), responder->getBGGreen(), responder->getBGBlue(), responder->getBGAlpha());
		flicker = true;
	}
	*/
	
	glClearColor(responder->getBGRed(), responder->getBGGreen(), responder->getBGBlue(), responder->getBGAlpha());

	FsSwapBuffers();
}

void collectStates(int x, int y) {
	int index; 
	index = floor(x / responder->getGroupX()) * (sizeX / responder->getGroupX()) + floor(y / responder->getGroupY());
	avgStates[index] += (float)world->cellState(x, y);
}

void runApp (int x, int y, int dbg, int w, int h, int f, const char* a, const char* p, int vs, int td, double lr) {
	
	int i, stateSize;
	
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
		
	delta = 1.0/(double)frameRate;
	
	world = new World(sizeX, sizeY, vecSize, trainDur, learnRate);

	ogl = new GraphicsRenderer(world, width, height);
	
	ogl->setupOgl();
	
	ogl->reshape((double)width, (double)height);
	
	responder = new OSC(a, p, world, ogl);

	responder->startListener();
		
	stateSize = (sizeX / responder->getGroupX()) * (sizeY / responder->getGroupY());

	avgStates = new float[stateSize];
	
//	ogl->patternLib[12].active = true;
//	ogl->patternLib[12].alpha = 1.0;

	while (isRunning) {				

		if ((sizeX / responder->getGroupX()) * (sizeY / responder->getGroupY()) != stateSize)
		{
			stateSize = (sizeX / responder->getGroupX()) * (sizeY / responder->getGroupY());
			delete [] avgStates;
			avgStates = new float[stateSize];		
		}
		
		for (i = 0; i < stateSize; i++) {
			avgStates[i] = 0.0;
		}
		drawFrame();
		for (i = 0; i < stateSize; i++) {
			avgStates[i] /= (responder->getGroupX() * responder->getGroupY());
		}
		responder->sendStates(avgStates, stateSize);
		if ((responder->getDone()) == 1) {
			isRunning = false;
		}

		FsSleep(delta);
				 		
	}
		
	delete world;
	
	responder->stopListener();
	
	delete responder;
	
	delete ogl;
	
	delete [] avgStates;
	
}

