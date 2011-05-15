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

void GraphicsRenderer::setupOgl (void) {
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
		
}

void GraphicsRenderer::initFrame(World * ptrWorld, Node * argBMU, int winWidth, int winHeight) {
	fragSizeX = (double)(winWidth / ptrWorld->sizeX());
	fragSizeY = (double)(winHeight / ptrWorld->sizeY());
	vectorSize = ptrWorld->vectorSize();
	ptrBMU = argBMU;
	currentIndex = ptrWorld->index();
}

void GraphicsRenderer::drawFragment(Node *theNode, int x, int y) {
	
	currentNode = theNode;
	
	state = currentNode->states[currentIndex];
	if (patternLib[0].active) {
		pattern01(x, y);
	}
	if (patternLib[1].active) {
		pattern02(x, y);	
	}
	if (patternLib[2].active) {
		pattern03(x, y);	
	}
	if (patternLib[3].active) {
		pattern04(x, y);	
	}
	if (patternLib[4].active) {
		pattern05(x, y);	
	}
	if (patternLib[5].active) {
		pattern06(x, y);	
	}
	if (patternLib[6].active) {
		pattern07(x, y);	
	}
	if (patternLib[7].active) {
		pattern08(x, y);	
	}
	if (patternLib[8].active) {
		pattern09(x, y);	
	}
	
}

void GraphicsRenderer::pattern01(int x, int y) {
	xL = x * fragSizeX + fragSizeX - (fragSizeX * 2.0 * state);
	yB = y * fragSizeY + fragSizeY - (fragSizeY * 2.0 * state);
	zF = zD = 0;
	
	xW = fragSizeX * state * 4.0;
	yH = fragSizeY * state * 4.0;
	
	red = currentNode->weights[0] * state;
	green = currentNode->weights[1] * state;
	blue = currentNode->weights[2] * state;
	alpha = currentNode->weights[3] * state;
	alpha *= patternLib[0].alpha;
	
	strokeRect(0, 1.0);

}

void GraphicsRenderer::pattern02(int x, int y) {
	int i;
	xL = fragSizeX * x;
	yB = fragSizeY * y;
	zF = zD = 0;
		
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

void GraphicsRenderer::pattern03(int x, int y) {
	
	xL = fragSizeX * x + fragSizeX - (fragSizeX * state);
	yB = fragSizeY * y + fragSizeX - (fragSizeX * state);
	zF = zD = 0;
	
	xW = fragSizeX * state;
	yH = fragSizeY * state;

	red = currentNode->weights[0] * state;
	green = currentNode->weights[1] * state;
	blue = currentNode->weights[2] * state;
	alpha = currentNode->weights[3] * state;
	alpha *= patternLib[2].alpha;

	drawCircle(0, xW * yH , map(state, 6, 12), false);
	
}

void GraphicsRenderer::pattern04(int x, int y) {
	
	if (between(y, 2, 5) || between(y, 10, 13) || between(y, 18, 21) || between(y, 26, 29) || between(y, 34, 37) ) {
	
		xL = x * fragSizeX + fragSizeX - (fragSizeX * (1.0 - state));
		yB = y * fragSizeY + fragSizeY - (fragSizeY * (1.0 - state));
		zF = zD = 0;
		
		xW = fragSizeY * (1.0 - state);
		yH = fragSizeX * (1.0 - state);
		
		red = currentNode->weights[0] * (1.0-state);
		green = currentNode->weights[0] * (1.0-state);
		blue = currentNode->weights[0] * (1.0-state);
		alpha = map(currentNode->weights[1] * state, 0.4, 1.0);
		alpha *= patternLib[3].alpha;
		
		strokeRect(0, 1.0);

		xL = x * fragSizeX + fragSizeX - (fragSizeX * (1.0 - state) * 0.75);
		yB = y * fragSizeY + fragSizeY - (fragSizeY * (1.0 - state) * 0.75);
		zF = zD = 0;
		
		xW = fragSizeY * (1.0 - state) * 0.5;
		yH = fragSizeX * (1.0 - state) * 0.5;
		
		red = currentNode->weights[2] * (1.0-state);
		green = currentNode->weights[2] * (1.0-state);
		blue = currentNode->weights[2] * (1.0-state);
		alpha = map(currentNode->weights[3] * state, 0.2, 0.6);
		alpha *= patternLib[3].alpha;

		fillRect(0);
	}
	else 
	{
		xL = x * fragSizeX + fragSizeX - (fragSizeX * state);
		yB = y * fragSizeY + fragSizeY - (fragSizeY * state);
		zF = zD = 1.0;
		
		xW = fragSizeX * state - (fragSizeX * 0.1);
		yH = fragSizeY * state - (fragSizeY * 0.1);
		
		red = currentNode->weights[4] * state;
		green = currentNode->weights[4] * state;
		blue = currentNode->weights[4] * state;
		alpha = map(currentNode->weights[5] * (1.0 - state), 0.3, 0.8);
		alpha *= patternLib[3].alpha;
		
		fillRect(0);

		red = currentNode->weights[6] * state;
		green = currentNode->weights[6] * state;
		blue = currentNode->weights[6] * state;

		strokeRect(0, 2.0);
		
	}
}

void GraphicsRenderer::pattern05(int x, int y) {
	
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
	
	drawPoint(xL, yB, 0.0, state * 2.0f);
	
}

void GraphicsRenderer::pattern06(int x, int y) {

	double radius, dist;

	radius = 6.0;

	if (ptrBMU)
	{
		
		zF = zD = 0;
				
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

void GraphicsRenderer::pattern07(int x, int y) {
	
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
		
		drawPoint(xL, yB, 0.0, 1.0);
	}
			
}

void GraphicsRenderer::pattern08(int x, int y) {
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
		
		drawLine(xL, yB, 0, xL + ex, yB + ey, 0, 1.0);
	}
}

void GraphicsRenderer::pattern09(int x, int y) {
	
	red = clipf(currentNode->weights[0], 0.0, 1.0);
	green = clipf(currentNode->weights[1], 0.0, 1.0);
	blue = clipf(currentNode->weights[2], 0.0, 1.0);
	alpha = clipf(1.0 - currentNode->weights[3], 0.0, 1.0);
	alpha *= patternLib[8].alpha;
	
	xL = x * fragSizeX;
	yB = y * fragSizeY;
	xW = fragSizeX;
	yH = fragSizeY * 0.25;
	
	zF = zD = 0.0;
	
//	drawLine(xL, yB, zF, xL + xW, yB + yH, zD, 1.0);

	strokeRect(0, 1.0);
	
	red = green = blue = clipf(currentNode->weights[5], 0.0, 1.0);
	
	xL = x * fragSizeX;
	yB = y * fragSizeY + (fragSizeY * 0.5);

//	drawLine(xL, yB, zF, xL + xW, yB + yH, zD, 1.0);
	
	strokeRect(0, 1.0);
	
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

