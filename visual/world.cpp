/*
 *  world.cpp
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

#include "world.h"

/* ****** NODE ****** */

double Node::difference (vector<double> compareVector) {
	double diff;
	int i;
	diff = 0.0;
	for (i = 0; i < compareVector.size(); i++) {
		diff += pow(weights[i] - compareVector[i] , 2);
	}
	
	return diff;
}

void Node::update (vector<double> inputVector, double learningRate, double influence) {
	int i;
	
	for (i = 0; i < inputVector.size(); i++)
		weights[i] = weights[i] + ((inputVector[i] - weights[i]) * learningRate * influence);

}

void Node::nextState (double add, int index) {
	int i;
	double avg, sum;
	
	avg = 0;
	sum = 0;
	
	for (i = 0; i < 8; i++) {
		avg += (neighbors[i]->states[index] * weights[i]);
		sum += weights[i];
	}
	
	avg = avg / sum + add;
	
	this->states[wrapi(index + 1, 0, 2)] = wrapd(avg, 0.0, 1.0);
	
}


/* ****** WORLD ****** */

World::World (int sizeX, int sizeY, int sizeV, int tDur, double lRate) {
	_sizeX = sizeX; _sizeY = sizeY; _vectorSize = sizeV;
	_trainDur = tDur; _learningRate = lRate; _initLearningRate = lRate;
	
	_trainCount = 0;
	
	_add = 0.995;
	
	_index = 0;
	
	_mapRadius = (double)max(_sizeX, _sizeY) / 2.0f;
	
	_timeConst = (double)(_trainDur / logf(_mapRadius));
	
	for (int i = 0; i < 8; i++) 
		_neighborWeights.push_back(1.0);
	
	nodes = NULL;
	
	this->init();
}

World::~World() {
	this->clear();
}

void World::init (void) {
	int x, y, i, j, nCount = 0;
	double state;
	
	this->clear();
		
	nodes = new Node*[_sizeX];
	assert(nodes);
	for (x = 0; x < _sizeX; x++) {
		nodes[x] = new Node[_sizeY];
		assert(nodes[x]);
		for (y = 0; y < _sizeY; y++) {
			nodes[x][y].x = x;
			nodes[x][y].y = y;
			for (i = 0; i < _vectorSize; i++) {
				state = randd();
 				nodes[x][y].weights.push_back(state);
			}
			state = randd();
			for (i = 0; i < 3; i++) {
				nodes[x][y].states[i] = 0;			
			}
			
		}
	}
	
	for (x = 0; x < _sizeX; x++) {
		for (y = 0; y < _sizeY; y++) {
			nCount = 0;
			for (i = 0; i < 3; i++) {
				for (j = 0; j < 3; j++) {
					if (!(i == 1 && j == 1)) {
						nodes[x][y].neighbors[nCount] = &(nodes[wrapi(x+(i-1), 0, _sizeX-1)][wrapi(y+(j-1), 0, _sizeY-1)]);
						nCount++;
					}
				}
			}
			
		}
	}
	
}

void World::clear (void) {
	int y;
	if (nodes) {
		for (y = 0; y < _sizeY; y++) {
			if (nodes[y]) {
				delete [] nodes[y];
				nodes[y] = NULL;
			}
		}
		delete [] nodes; 
		nodes = NULL;
	}
}

void World::setNeighborWeights(vector<double> newWeights) {
	for (int i = 0; i < newWeights.size(); i++) {
		_neighborWeights[i] = newWeights[i];
	}
}

void World::setAdd (double value) { _add = value; }

double World::cellState(int x, int y) { return nodes[x][y].states[_index]; }

Node* World::findBMU(vector<double> inputVector) {
	int x, y;
	double diff, best;
	Node* theNode;
	
	best = 10.0;
	
	for (x = 0; x < _sizeX; x++) {
		for (y = 0; y < _sizeY; y++) {
			diff = nodes[x][y].difference(inputVector);
			if (diff < best) {
				best = diff;
				theNode = &(nodes[x][y]);
			}
		}
	}
	
	return theNode;
}

Node* World::train (vector<double> inputVector) {
	Node* bmu; 
	Node* thisNode;
	int x, y;
	double tRadius, influence, dist;
	
	bmu = this->findBMU(inputVector);

	for (x = 0; x < _sizeX; x++) {
		for (y = 0; y < _sizeY; y++) {

			thisNode = &nodes[x][y];

			if (_trainCount < _trainDur) {
				tRadius = _mapRadius * exp(_trainCount / (_timeConst*-1.0));
				
				dist = pow(bmu->x - thisNode->x, 2) + pow(bmu->y - thisNode->y, 2);
				
				if (dist < pow(tRadius, 2)) {
					influence = exp(dist / (pow(tRadius, 2) * -2.0));
					thisNode->update(inputVector, _learningRate, influence);
				}
				
				_learningRate = _initLearningRate * exp(_trainCount / (_trainDur * -1.0));
				
			}
			
			thisNode->nextState(_add, _index);
			
		}
	}
	
	if (_trainCount < _trainDur) { _trainCount++; }
	
	_index = wrapi(_index + 1, 0, 2);
	
	return bmu;
	
}