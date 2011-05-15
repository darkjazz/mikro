/*
 *  world.h
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
#ifndef WORLD_H
#define WORLD_H

#include <vector>
#include <iostream>
#include <math.h>

#include "util.h"

using namespace std;

class Node {
public:
	Node() : x(0), y(0) {};
	~Node() {};
	vector<double> weights;	
	int x, y; 
	double states[3];
	Node* neighbors[8];
	
	double difference (vector<double>);
	void update (vector<double>, double, double);
	void nextState (double, int);
	
	
};

class World {
	
public:
	World(int, int, int, int, double);
	~World();
	void init();
	void clear();
	void setNeighborWeights(vector<double>);
	Node** nodes;
	int vectorSize() { return _vectorSize; };
	void setAdd (double);
	
	int index() { return _index; };
	int sizeX() { return _sizeX; };
	int sizeY() { return _sizeY; };
	double add() { return _add; };
	double cellState(int, int);
	
	Node* findBMU(vector<double>);
	Node* train(vector<double>);

private:
	int _vectorSize, _sizeX, _sizeY, _trainDur, _trainCount, _index;
	double _initLearningRate, _learningRate, _mapRadius, _timeConst, _add;
	vector<double> _neighborWeights;
};


#endif