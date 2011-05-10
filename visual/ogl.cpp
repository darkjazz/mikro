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
		drawLine(xL, yB + (fragSizeY / vectorSize * i), zF, xL + fragSizeX, yB + (fragSizeY / vectorSize * i), zF, 1.0);
	}
	
	if (ptrBMU) {
		if (ptrBMU->x == x && ptrBMU->y == y) {
			xW = fragSizeX;
			yH = fragSizeY;
			red = green = blue = 1.0;
			alpha = 0.2;
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
		
		fillRect(0);

		red = currentNode->weights[6] * state;
		green = currentNode->weights[6] * state;
		blue = currentNode->weights[6] * state;

		strokeRect(0, 2.0);
		
	}
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

