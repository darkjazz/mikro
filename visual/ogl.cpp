/*
 *  ogl.cpp
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

#include "ogl.h"

const double pi = 3.1415926535;

void GraphicsRenderer::setupOgl () {
	
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	glClearDepth(1.0f);
	glDepthFunc(GL_LEQUAL);
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_BLEND);
	glEnable(GL_LINE_SMOOTH);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
	glHint(GL_POLYGON_SMOOTH_HINT, GL_NICEST);
	glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);	
	glDepthRange(0.1, 100.0);
		
}

void GraphicsRenderer::reshape(double width, double height) {
    double aspect;
    aspect = width / height;
    glViewport(0, 0, width, height);
    glMatrixMode(GL_PROJECTION);
    // you must reload the identity before this or you'll lose your picture
    glLoadIdentity();
	gluPerspective(45.0f, (GLfloat)aspect, 0.1f,100.0f);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

void GraphicsRenderer::prepareFrame() {
	
	if (patternLib[12].active)
	{
		_drawRow = true;
		delete [] rowColors;
		delete [] rowNormals;
		delete [] rowVertices;
		
		rowVertices = new GLfloat[world->sizeY()*3];
		rowNormals = new GLfloat[world->sizeY()*3];
		rowColors = new GLfloat[world->sizeY()*4];
	}
	
//	if (patternLib[13].active)
//	{
//		_drawWorld = true;
//		delete [] worldColors;
//		delete [] worldNormals;
//		delete [] worldVertices;
//		
//		worldVertices = new GLfloat[world->sizeX() * world->sizeY() * 3];
//		worldNormals = new GLfloat[world->sizeX() * world->sizeY() * 3];
//		worldColors = new GLfloat[world->sizeX() * world->sizeY() * 4];
//	}
	
}

void GraphicsRenderer::drawFragment(Node *theNode, Node* _bmu, int x, int y) {
	
	currentNode = theNode;
	ptrBMU = _bmu;
	
	state = currentNode->states[currentIndex];
	if (patternLib[0].active) {
		pattern00(x, y);
	}
	if (patternLib[1].active) {
		pattern01(x, y);	
	}
	if (patternLib[2].active) {
		pattern02(x, y);	
	}
	if (patternLib[3].active) {
		pattern03(x, y);	
	}
	if (patternLib[4].active) {
		pattern04(x, y);	
	}
	if (patternLib[5].active) {
		pattern05(x, y);	
	}
	if (patternLib[6].active) {
		pattern06(x, y);	
	}
	if (patternLib[7].active) {
		pattern07(x, y);	
	}
	if (patternLib[8].active) {
		pattern08(x, y);	
	}
	if (patternLib[9].active) {
		pattern09(x, y);	
	}
	if (patternLib[10].active) {
		pattern10(x, y);	
	}
	if (patternLib[11].active) {
		pattern11(x, y);	
	}
	if (patternLib[12].active) {
		pattern12(x, y);	
	}
	if (patternLib[13].active) {
		pattern13(x, y);	
	}
	if (patternLib[14].active) {
		pattern14(x, y);	
	}
	if (patternLib[15].active) {
		pattern15(x, y);	
	}
}

void GraphicsRenderer::drawRow() {
	
	if (_drawRow)
	{
	
		glEnableClientState(GL_NORMAL_ARRAY);
		glEnableClientState(GL_COLOR_ARRAY);
		glEnableClientState(GL_VERTEX_ARRAY);
		
		glNormalPointer(GL_FLOAT, 0, rowNormals);
		glColorPointer(4, GL_FLOAT, 0, rowColors);
		glVertexPointer(3, GL_FLOAT, 0, rowVertices);

		glEnable(GL_LINE_SMOOTH);
		
		glDrawArrays(GL_LINES, 0, world->sizeY());
		
		glDisable(GL_LINE_SMOOTH);
		
	//	glEnable(GL_POLYGON_SMOOTH);
	//	
	//	glDrawArrays(GL_POLYGON, 0, world->sizeY());
	//	
	//	glDisable(GL_POLYGON_SMOOTH);
		
		glDisableClientState(GL_VERTEX_ARRAY);
		glDisableClientState(GL_COLOR_ARRAY);
		glDisableClientState(GL_NORMAL_ARRAY);
	}
	
}

void GraphicsRenderer::drawWorld() {

}

void GraphicsRenderer::pattern00(int x, int y) {
	xL = x * fragSizeX + fragSizeX - (fragSizeX * 2.0 * state);
	yB = y * fragSizeY + fragSizeY - (fragSizeY * 2.0 * state);
	zF = zD = -100.0;
	
	xW = fragSizeX * state * 4.0;
	yH = fragSizeY * state * 4.0;
	
	red = clipf(currentNode->weights[0], 0.0, 1.0) * state;
	green = clipf(currentNode->weights[1], 0.0, 1.0) * state;
	blue = clipf(currentNode->weights[2], 0.0, 1.0) * state;
	alpha = state;
	alpha *= patternLib[0].alpha;
	
//	strokeRect(0, 1.0);
	strokeRectArray();
		
}

void GraphicsRenderer::pattern01(int x, int y) {
	int i;
	xL = fragSizeX * x;
	yB = fragSizeY * y;
	zF = zD = -100;
		
	for (i = 0; i < vectorSize; i++) {
		red = green = blue = currentNode->weights[i]; 
		alpha = currentNode->weights[i] * state;
		alpha *= patternLib[1].alpha;
		drawLine(xL, yB + (fragSizeY / vectorSize * i), zF, xL + fragSizeX, yB + (fragSizeY / vectorSize * i), zF, 1.0);
	}
	
	if (ptrBMU) {
		if (ptrBMU->x == x && ptrBMU->y == y) {
			xW = fragSizeX;
			yH = fragSizeY;
			red = green = blue = 1.0;
			alpha = 0.2;
			alpha *= patternLib[1].alpha;
			strokeRect(0, 1.0);
		}
	}
	
}

void GraphicsRenderer::pattern02(int x, int y) {
	
	float eState;
	
	if (x > 0 && y > 0 && x < world->sizeX() - 1 && y < world->sizeY() - 1)
	{
	
		eState = currentNode->neighbors[3]->states[currentIndex];
		
		xL = fragSizeX * 1.1 * x + (fragSizeX * cos(state * 2 * pi)) - (fragSizeX * 2 * cos(state * 2 * pi));
		yB = fragSizeY * 1.1 * y + (fragSizeY * sin(state * 2 * pi)) - (fragSizeY * 2 * sin(state * 2 * pi));
		zF = zD = -100;
		
		xW = fragSizeX * 1.1 * x + (fragSizeX * cos(eState * 2 * pi)) - (fragSizeX * 2 * cos(eState * 2 * pi));
		yH = fragSizeY * 1.1 * (y - 1) + (fragSizeY * sin(eState * 2 * pi)) - (fragSizeY * 2 * sin(eState * 2 * pi));

		red = currentNode->weights[4] * state;
		green = currentNode->weights[5] * state;
		blue = currentNode->weights[6] * state;
		alpha = currentNode->weights[7] * state;
		alpha *= patternLib[2].alpha;
		
		drawLine(xL, yB, zF, xW, yH, zD, (state + eState) / 2.0);
		
//		if (state > 0.5)
//		{
//		
//			eState = currentNode->neighbors[0]->states[currentIndex];				
//			xW = fragSizeX * 1.1 * (x - 1) + (fragSizeX * cos(eState * 2 * pi)) - (fragSizeX * 2 * cos(eState * 2 * pi));
//			drawLine(xL, yB, zF, xW, yH, zD, (state + eState) / 2.0);
//		}
		
//		if (state > 0.7)
//		{
//			eState = currentNode->neighbors[1]->states[currentIndex];				
//			yH = fragSizeY * 1.1 * y + (fragSizeY * sin(eState * 2 * pi)) - (fragSizeY * 2 * sin(eState * 2 * pi));
//			drawLine(xL, yB, zF, xW, yH, zD, (state + eState) / 2.0);
//		}
		
		eState = currentNode->neighbors[2]->states[currentIndex];				
		xW = fragSizeX * 1.1 * (x - 1) + (fragSizeX * cos(eState * 2 * pi)) - (fragSizeX * 2 * cos(eState * 2 * pi));
		yH = fragSizeY * 1.1 * (y + 1) + (fragSizeY * sin(eState * 2 * pi)) - (fragSizeY * 2 * sin(eState * 2 * pi));
		drawLine(xL, yB, zF, xW, yH, zD, (state + eState) / 2.0);
	}
		
}

void GraphicsRenderer::pattern03(int x, int y) {
	
//	if (between(y, 2, 5) || between(y, 10, 13) || between(y, 18, 21) || between(y, 26, 29) || between(y, 34, 37) ) {

	if (isEven(y)) {
		
		xL = x * fragSizeX + fragSizeX - (fragSizeX * 1.5 * (1.0 - state));
		yB = y * fragSizeY + (fragSizeY * 0.33);
		zF = zD = -100;
		
		xW = fragSizeX * 1.5 * (1.0 - state);
		yH = fragSizeY * 0.1 * (1.0 - state);
		
		red = currentNode->weights[0] * (1.0-state);
		green = currentNode->weights[0] * (1.0-state);
		blue = currentNode->weights[0] * (1.0-state);
		alpha = map(currentNode->weights[1] * state, 0.4, 1.0);
		alpha *= patternLib[3].alpha;
		
		strokeRect(0, 1.0);

		xL = x * fragSizeX + fragSizeX - (fragSizeX * 4.0 * (1.0 - state));
		yB = y * fragSizeY + (fragSizeY * 0.66);
		zF = zD = 0;
		
		xW = fragSizeX * (1.0 - state) * 4.0;
		yH = fragSizeY * 0.1 * (1.0 - state);
		
		red = currentNode->weights[2] * (1.0-state);
		green = currentNode->weights[2] * (1.0-state);
		blue = currentNode->weights[2] * (1.0-state);
		alpha = map(currentNode->weights[3] * state, 0.2, 0.6);
		alpha *= patternLib[3].alpha;

		strokeRect(0, 2.0);
	}
	else 
	{
		xL = x * fragSizeX + fragSizeX - (fragSizeX * 1.5 * state);
		yB = y * fragSizeY + (fragSizeY * 0.33);
		zF = zD = -100.0;
		
		xW = fragSizeX * 1.5 * state;
		yH = fragSizeY * 0.1 * state - (fragSizeY * 0.1);
		
		red = currentNode->weights[4] * state;
		green = currentNode->weights[4] * state;
		blue = currentNode->weights[4] * state;
		alpha = map(currentNode->weights[5] * (1.0 - state), 0.3, 0.8);
		alpha *= patternLib[3].alpha;
		
		strokeRect(0, 1.0);

		yB = y * fragSizeY + (fragSizeY * 0.66);
		yH = fragSizeY * 0.1 * state - (fragSizeY * 0.1);
		
		red = currentNode->weights[6] * state;
		green = currentNode->weights[6] * state;
		blue = currentNode->weights[6] * state;

		strokeRect(0, 2.0);
		
	}
}

void GraphicsRenderer::pattern04(int x, int y) {
	
//	int i;
	float xx, yy;
	
	xx = fragSizeX * cos((state + (x + 1 / 40)) * (2 * pi));
	yy = fragSizeY * sin((state + (y + 1 / 40)) * (2 * pi));
	
	xW = state * fragSizeX * 0.25f;
	yH = state * fragSizeY * 0.25f;
	
	xL = x * fragSizeX + xx + xW;
	yB = y * fragSizeY + yy + yH;
	
	red = currentNode->weights[7] * state;
	green = currentNode->weights[6] * state;
	blue = currentNode->weights[5] * state;
	alpha = map(state, 0.5, 1.0);
	alpha *= patternLib[4].alpha;
	
	drawPoint(xL, yB, -100.0, state * 2.0f);
	
}

void GraphicsRenderer::pattern05(int x, int y) {

	double radius, dist;

	radius = 6.0;

	if (ptrBMU)
	{
		
		zF = zD = -100;
				
		red = currentNode->weights[0] * (1.0 - state);
		green = currentNode->weights[1] * (1.0 - state);
		blue = currentNode->weights[2] * (1.0 - state);
		
		dist = pow(ptrBMU->x - currentNode->x, 2) + pow(ptrBMU->y - currentNode->y, 2);		
		
		if (dist < pow(radius, 2)) {
			xL = x * fragSizeX + fragSizeX - (fragSizeX * state);
			yB = y * fragSizeY + (fragSizeY * 0.5);
			xW = fragSizeX * state * 2.0;
			yH = yB;
									
			alpha = map(exp(dist / (pow(radius, 2) * -2.0)), 0.2, 1.0);
			alpha *= patternLib[5].alpha;
			
			drawLine(xL, yB, zF, xL + xW, yB, zF, map(state, 1.0, 2.0));			
			
		}
		else 
		{
			yB = y * fragSizeY + fragSizeY - (fragSizeY * state);
			xL = x * fragSizeX + (fragSizeX * 0.5);
			yH = fragSizeY * state * 2.0;
			xW = xL;

			alpha = map(state, 0.0, 1.0);
			alpha *= patternLib[5].alpha;			
			drawLine(xL, yB, zF, xL, yB + yH, zF, 1.0);			
		}
			
	}
	
}

void GraphicsRenderer::pattern06(int x, int y) {
	
	int i;
	float xx, yy;
	
	for (i = 0; i < vectorSize; i++) {
	
		xx = fragSizeX * cos( (state * currentNode->weights[i] ) * (2 * pi));
		yy = fragSizeY * sin( (state * currentNode->weights[i] ) * (2 * pi));
				
		xL = x * fragSizeX + xx;
		yB = y * fragSizeY + yy;
		
		red = currentNode->weights[i] * state;
		green = currentNode->weights[i] * state;
		blue = currentNode->weights[i] * state;
		alpha = currentNode->weights[i] * state;
		alpha *= patternLib[6].alpha;
		
		drawPoint(xL, yB, -100.0, 1.0);
	}
			
}

void GraphicsRenderer::pattern07(int x, int y) {
	int i;
	float ex, ey;

	for (i = 0; i < vectorSize; i++)
	{
		xL = x * fragSizeX + (fragSizeX * 0.5) + (fragSizeX * 0.5 * cosf(state * (i / (float)vectorSize) * (2.0 * pi)));
		yB = y * fragSizeY + (fragSizeY * 0.5) + (fragSizeY * 0.5 * sinf(state * (i / (float)vectorSize) * (2.0 * pi)));

		ex = fragSizeX * cosf( (1.0 - state) * (i / (float)vectorSize) * (2.0 * pi));
		ey = fragSizeY * sinf( (1.0 - state) * (i / (float)vectorSize) * (2.0 * pi));
		red = currentNode->weights[i] * state;
		green = currentNode->weights[wrapi(i+1,0,vectorSize-1)] * state;
		blue = currentNode->weights[wrapi(i+2,0,vectorSize-1)] * state;
		alpha = currentNode->weights[wrapi(i+3,0,vectorSize-1)] * state;
		alpha *= patternLib[7].alpha;
		
		drawLine(xL, yB, -100.0, xL + ex, yB + ey, -100.0, 1.0);
	}
}

void GraphicsRenderer::pattern08(int x, int y) {
	
	red = clipf(currentNode->weights[0], 0.0, 1.0);
	green = clipf(currentNode->weights[1], 0.0, 1.0);
	blue = clipf(currentNode->weights[2], 0.0, 1.0);
	alpha = clipf(1.0 - currentNode->weights[3], 0.0, 1.0);
	alpha *= patternLib[8].alpha;
	
	xL = x * fragSizeX;
	yB = y * fragSizeY;
	xW = fragSizeX;
	yH = fragSizeY * 0.25;
	
	zF = zD = -100.0;
	
//	drawLine(xL, yB, zF, xL + xW, yB + yH, zD, 1.0);

	strokeRect(0, 1.0);
	
	red = green = blue = clipf(currentNode->weights[5], 0.0, 1.0);
	
	xL = x * fragSizeX;
	yB = y * fragSizeY + (fragSizeY * 0.5);

//	drawLine(xL, yB, zF, xL + xW, yB + yH, zD, 1.0);
	
	strokeRect(0, 1.0);
	
}

void GraphicsRenderer::pattern09(int x, int y) {
	int i, count;
	float ex, ey, cx, cy;

//	red = state * clipf(currentNode->weights[1], 0.0, 1.0);
//	green = state * clipf(currentNode->weights[1], 0.0, 1.0);
//	blue = state * clipf(currentNode->weights[1], 0.0, 1.0);

	red = green = blue = map(state, 0.1, 0.7);
	
	count = map(state, 4, 8);
	
	cx = x * fragSizeX + (fragSizeX * 0.8);
	cy = y * fragSizeY + (fragSizeY * 0.8);
	
	for (i = 0; i < count; i++)
	{
		ex = cx + (fragSizeX * map(state, 0.5, 2.0) * cosf(state * (i / (float)count) * (2.0 * pi)));
		ey = cy + (fragSizeY * map(state, 0.5, 2.0) * sinf(state * (i / (float)count) * (2.0 * pi)));
		
		alpha = state;
		alpha *= patternLib[9].alpha;
		
		drawLine(cx, cy, -100.0, ex, ey, -100.0, 1.0);
	}
}

void GraphicsRenderer::pattern10(int x, int y) {
	double rounded;
	
	rounded = round(state * 10) / 10.0;	
	xL = x * fragSizeX + fragSizeX - (fragSizeX * 4.0 * rounded);
	yB = y * fragSizeY + (fragSizeY * 0.4);
	zF = zD = -100.0;
	
	xW = fragSizeX * 8.0 * rounded;
	yH = fragSizeY * 0.6;
	
	red = ((currentNode->weights[7] * 0.5) + (rounded * 0.5)) / 2.0;
	green = ((currentNode->weights[6] * 0.5) + (rounded * 0.5)) / 2.0;
	blue = ((currentNode->weights[5] * 0.5) + (rounded * 0.5)) / 2.0;
	alpha = 1.0 - rounded;
	alpha *= patternLib[10].alpha;
	
	strokeRect(0, 2.0);
	
}

void GraphicsRenderer::pattern11(int x, int y) {
	double fsizey = (fragSizeY * 0.4) + 10.0;
	
	xL = x * fragSizeX + fragSizeX - (fragSizeX * 2.5 * state);
	yB = y * fsizey + fsizey - (fsizey * 2.5 * state);
	zF = zD = -100.0;
	
	xW = fragSizeX * state * 5.0;
	yH = fsizey * state * 5.0;
	
	red = state;
	green = state;
	blue = state;
	alpha = state;
	alpha *= patternLib[11].alpha;
	
	strokeRect(0, 1.0);
	
}

void GraphicsRenderer::pattern12(int x, int y) {

	int indexv, indexc;
	float xx, yy;

	xx = fragSizeX * cos((state + (x + 1 / 40)) * (2 * pi));
	yy = fragSizeY * sin((state + (y + 1 / 40)) * (2 * pi));
	
	xW = state * fragSizeX * 0.25f;
	yH = state * fragSizeY * 0.25f;
	
	xL = x * fragSizeX + xx + xW;
	yB = y * fragSizeY + yy + yH;
	
	red = state * currentNode->weights[0];
	green = state * currentNode->weights[1];
	blue = state * currentNode->weights[2];
	alpha = state;
	alpha *= patternLib[12].alpha;
		
	indexv = y * 3;
	indexc = y * 4;
	
	rowVertices[indexv] = xL;
	rowVertices[indexv + 1] = yB;
	rowVertices[indexv + 2] = -100.0 * map(state, 0.8, 1.2);
	
	rowNormals[indexv] = 0;
	rowNormals[indexv + 1] = 0;
	rowNormals[indexv + 2] = 1;
	
	rowColors[indexc] = red;
	rowColors[indexc + 1] = green;
	rowColors[indexc + 2] = blue;
	rowColors[indexc + 3] = alpha;
	
}

void GraphicsRenderer::pattern13(int x, int y) {
	int segs;

	xL = x * fragSizeX + fragSizeX - (fragSizeX * state);
	yB = y * fragSizeY + fragSizeY - (fragSizeY * state);
	zF = zD = -100.0;
	
	xW = fragSizeX * state * 2.0;
	yH = fragSizeY * state * 2.0;
	
	red = clipf(currentNode->weights[0], 0.0, 1.0) * state;
	green = clipf(currentNode->weights[1], 0.0, 1.0) * state;
	blue = clipf(currentNode->weights[2], 0.0, 1.0) * state;
	alpha = state;
	alpha *= patternLib[13].alpha;
	
	segs = map(state, 4, 32);
	
	drawCircle(0, xW, (int)segs, false);
		
}

void GraphicsRenderer::pattern14(int x, int y) {
	int segs, i;
	float avg;
	
	xL = x * fragSizeX + fragSizeX - (fragSizeX * 0.5 * state);
	yB = y * fragSizeY + fragSizeY - (fragSizeY * 0.5 * state);
	zF = zD = -100.0;
	
	avg = 0.0;
	for (i = 0; i < vectorSize; i++)
	{
		avg += currentNode->weights[i];
	}
	
	avg = avg / vectorSize;
	
	xW = fragSizeX * state * avg;
	yH = fragSizeY * state;
	
	red = clipf(currentNode->weights[7], 0.0, 1.0) * state;
	green = clipf(currentNode->weights[6], 0.0, 1.0) * state;
	blue = clipf(currentNode->weights[5], 0.0, 1.0) * state;
	alpha = state;
	alpha *= patternLib[14].alpha;
	
	segs = 12;
	
	drawCircle(0, xW, (int)segs, true);
	drawCircle(0, xW, (int)segs, false);
	
}

void GraphicsRenderer::pattern15(int x, int y) {
	xL = x * fragSizeX;
	yB = y * fragSizeY;
	zF = zD = -100.0;
	
	xW = fragSizeX * state;
	yH = fragSizeY * state;
	
	red = clipf(currentNode->weights[0], 0.0, 1.0) * state;
	green = clipf(currentNode->weights[1], 0.0, 1.0) * state;
	blue = clipf(currentNode->weights[2], 0.0, 1.0) * state;
	alpha = state;
	alpha *= patternLib[15].alpha;
	
	if (state > 0.75) {
		drawLine(xL, yB + (fragSizeY * 0.5), zF, xL + xW, yB + (fragSizeY * 0.5), zD, state * 3.0);
	}
	else
	{
		drawLine(xL + (fragSizeX * 0.5), yB, zF, xL + (fragSizeX * 0.5), yB + yH, zD, state * 3.0);	
	}
}

void GraphicsRenderer::strokeRectArray() {
	
	GLfloat vertices[] = {
		xL, yB, zF,				xL + xW, yB, zF,
		xL + xW, yB, zF,		xL + xW, yB + yH, zF,
		xL + xW, yB + yH, zF,	xL, yB + yH, zF,
		xL, yB + yH, zF,		xL, yB, zF
	};
	
	GLfloat normals[] = {
		0, 0, 1,				0, 0, 1,
		0, 0, 1,				0, 0, 1,
		0, 0, 1,				0, 0, 1,
		0, 0, 1,				0, 0, 1
	};
	
	GLfloat colors[] = {
		red, green, blue, alpha,	red, green, blue, alpha,
		red, green, blue, alpha,	red, green, blue, alpha,
		red, green, blue, alpha,	red, green, blue, alpha,
		red, green, blue, alpha,	red, green, blue, alpha
	};
	
	glEnableClientState(GL_NORMAL_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_VERTEX_ARRAY);
	
	glNormalPointer(GL_FLOAT, 0, normals);
	glColorPointer(4, GL_FLOAT, 0, colors);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	
	glEnable(GL_LINE_SMOOTH);
	
	glDrawArrays(GL_LINES, 0, 8);
	
	glDisable(GL_LINE_SMOOTH);
		
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_NORMAL_ARRAY);
	
}

void GraphicsRenderer::fillRect (int plane) {
	glColor4f(red, green, blue, alpha);
	glEnable(GL_POLYGON_SMOOTH);
	glBegin(GL_POLYGON);
	
	switch (plane)
	{
		case 0:
			glVertex3f (xL, yB, zF);
			glVertex3f (xL + xW, yB, zF);
			
			glVertex3f (xL + xW, yB, zF);
			glVertex3f (xL + xW, yB + yH, zF);
			
			glVertex3f (xL + xW, yB + yH, zF);
			glVertex3f (xL, yB + yH, zF);
			
			glVertex3f (xL, yB + yH, zF);
			glVertex3f (xL, yB, zF);
			
			break;
			
		case 1:
			glVertex3f (xL, yB, zF);
			glVertex3f (xL, yB, zF + zD);
			
			glVertex3f (xL, yB, zF + zD);
			glVertex3f (xL, yB + yH, zF + zD);
			
			glVertex3f (xL, yB + yH, zF + zD);
			glVertex3f (xL, yB + yH, zF);
			
			glVertex3f (xL, yB + yH, zF);
			glVertex3f (xL, yB, zF);
			
			break;
			
		case 2:
			glVertex3f (xL, yB, zF);
			glVertex3f (xL + xW, yB, zF);
			
			glVertex3f (xL + xW, yB, zF);
			glVertex3f (xL + xW, yB, zF + zD);
			
			glVertex3f (xL + xW, yB, zF + zD);
			glVertex3f (xL, yB, zF + zD);
			
			glVertex3f (xL, yB, zF + zD);
			glVertex3f (xL, yB, zF);
			
			break;
			
	}
	
	glEnd();
	glDisable(GL_POLYGON_SMOOTH);
	
}

void GraphicsRenderer::strokeRect (int plane, float lineWidth) {
	glColor4f(red, green, blue, alpha);
	glEnable(GL_LINE_SMOOTH);
	glLineWidth(lineWidth);
	glBegin(GL_LINES);
	
	switch (plane)
	{
		case 0:
			glVertex3f (xL, yB, zF);
			glVertex3f (xL + xW, yB, zF);
			
			glVertex3f (xL + xW, yB, zF);
			glVertex3f (xL + xW, yB + yH, zF);
			
			glVertex3f (xL + xW, yB + yH, zF);
			glVertex3f (xL, yB + yH, zF);
			
			glVertex3f (xL, yB + yH, zF);
			glVertex3f (xL, yB, zF);
			
			break;
			
		case 1:
			glVertex3f (xL, yB, zF);
			glVertex3f (xL, yB, zF + zD);
			
			glVertex3f (xL, yB, zF + zD);
			glVertex3f (xL, yB + yH, zF + zD);
			
			glVertex3f (xL, yB + yH, zF + zD);
			glVertex3f (xL, yB + yH, zF);
			
			glVertex3f (xL, yB + yH, zF);
			glVertex3f (xL, yB, zF);
			
			break;
			
		case 2:
			glVertex3f (xL, yB, zF);
			glVertex3f (xL + xW, yB, zF);
			
			glVertex3f (xL + xW, yB, zF);
			glVertex3f (xL + xW, yB, zF + zD);
			
			glVertex3f (xL + xW, yB, zF + zD);
			glVertex3f (xL, yB, zF + zD);
			
			glVertex3f (xL, yB, zF + zD);
			glVertex3f (xL, yB, zF);
			
			break;
			
	}
	
	
	glEnd();
	glDisable(GL_LINE_SMOOTH);
}

void GraphicsRenderer::drawPoint (float x, float y, float z, float sz) {
	glColor4f(red, green, blue, alpha);
	glEnable(GL_POINT_SMOOTH);
	glPointSize(sz);
	glBegin(GL_POINTS);
	glVertex3f(x, y, z);
	glEnd();
	glDisable(GL_POINT_SMOOTH);
}


void GraphicsRenderer::drawLine (float startx, float starty, float startz, float endx, float endy, float endz, float lineWidth) {
	glColor4f(red, green, blue, alpha);
	glEnable(GL_LINE_SMOOTH);
	glLineWidth(lineWidth);
	glBegin(GL_LINES);
	
	glVertex3f(startx, starty, startz);
	glVertex3f(endx, endy, endz);
	
	glEnd();
	glDisable(GL_LINE_SMOOTH);
}

void GraphicsRenderer::drawCircle (int plane, float r, int num_segments, bool fill) { 
	int i;
	float theta, tangetial_factor, radial_factor, x, y;
	theta = 2 * pi / num_segments;
	tangetial_factor = tanf(theta);
	radial_factor = cosf(theta);
	x = r;
	y = 0;
	
	if (fill) {
		glBegin(GL_POLYGON);	
	}
	{
		glBegin(GL_LINE_LOOP);
	}
	glColor4f(red, green, blue, alpha);
	for(i = 0; i < num_segments; i++) 
	{ 
		switch (plane) {
			case 0:
				glVertex3f(x + xL, y + yB, zF);
				break;
			case 1: 
				glVertex3f(xL, x + yB, y + zF);
				break;
			case 2:
				glVertex3f(y + xL, yB, x + zF);
				break;
		}
		
        
		float tx = -y; 
		float ty = x; 
		x += tx * tangetial_factor; 
		y += ty * tangetial_factor; 
		x *= radial_factor; 
		y *= radial_factor; 
	} 
	glEnd(); 
}

