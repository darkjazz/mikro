/*
 *  ogl.h
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
#ifndef OGL_H
#define OGL_H

#include <OpenGL/OpenGL.h>
#include "world.h"

const int numPatterns = 4;

struct pattern {

	bool active; 
	double alpha;
	
	pattern(): active(false), alpha(0) {};
	~pattern() {};
};


class GraphicsRenderer {

public:
	GraphicsRenderer() {
		patternLib = new pattern[numPatterns];
	};
	
	~GraphicsRenderer() {
		delete [] patternLib;
	};
	
	pattern* patternLib;	
	
	// *** OpenGL global setup  *** //

	void setupOgl (void);

	// *** draw cells *** //

	void initFrame(World*, Node*, int, int);

	void drawFragment(Node*, int, int);

private:
	
	double fragSizeX, fragSizeY, state;
	float xL, yB, zF, xW, yH, zD, red, green, blue, alpha;
	int currentIndex, vectorSize;
	Node* currentNode;
	Node* ptrBMU;
		
	void pattern01(int, int);
	
	void pattern02(int, int);
	
	void pattern03(int, int);

	void pattern04(int, int);

	// *** basic drawing functions *** //
	
	void fillRect (int);
	
	void strokeRect (int, float);
	
	void drawPoint (float, float, float, float);
	
	void drawLine (float, float, float, float, float, float, float);
	
	void drawCircle (int, float, int, bool);
	
};

#endif