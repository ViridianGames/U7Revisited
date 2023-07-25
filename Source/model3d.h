/*
 *  Copyright (C) 2005  The Exult Team
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#ifndef MODEL3D_H
#define MODEL3D_H

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <map>
#include <string>
//class Model3D;
class ModelFrame3D;
class Shape_frame;
//#include "shapes/vgafile.h"
//#include "pngio.h"

#include "GL/glew.h"
#ifdef _WINDOWS
#include <Windows.h>
#include <gl/gl.h>
#elif defined __APPLE__
#include <OpenGL/gl.h>
#else
#include <GL/gl.h>
#endif

#define MODEL_MAX_FRAMES 32


class ModelFrame3D
{
	friend class GL_texshape;
private:
	Shape_frame *m_Frame;		// Which shape-frame does this belong to?
	//Texture data
	//static std::map<std::string,unsigned int> m_TexCache;
	//static std::map<unsigned int,unsigned int> m_TexRef;
	unsigned int m_TexID;		// OpenGL Texture ID for this texture
	//Model data
	unsigned short m_NumVerts;	// Number of vertices in frame.
					// Vertices include 3 floats for each Pos,
					// UVW (texture coordinates), and normal
	unsigned short m_NumTris;	// Number of triangles in the frame.
					// There will be 3 vertex indices per tri
	unsigned short* m_Indices;	// unsigned int[m_NumTris*3]

	float *m_VertPos;		// float[m_NumVerts*3]
	float *m_VertUVW;		// float[m_NumVerts*2]
	float *m_VertNorm;		// float[m_NumVerts*3]

	Mesh m_Mesh;
	Texture* m_Texture;

	std::string m_Filename;

public:
	ModelFrame3D( std::string filename );
	~ModelFrame3D();
	
	bool Render();
	bool Build();
};

#endif

