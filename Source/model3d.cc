/*
 *  Copyright (C) 2000-2002  The Exult Team
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

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif
#include "Globals.h"
#include "model3d.h"

using namespace std;
//#include "pngio.h"

//
//Construction/Destruction
//

ModelFrame3D::ModelFrame3D( string filename )
{
	m_Filename = filename;

	m_VertPos = NULL;
	m_TexID = ~0;

	Build();
}

ModelFrame3D::~ModelFrame3D()
{
	//m_VertPos, m_VertUVW, m_VertNorm, and m_Indices are allocated in one pool...
	if( m_VertPos )
		free( m_VertPos );
}

//
//Code
//

bool ModelFrame3D::Build()
{
	FILE *File;
	char Filename[512];
	char Texname[32];

	//Try to open model file
	File = fopen( m_Filename.c_str(), "rb");
	if( File == NULL )
	{
		//Failed to cache file!
		m_VertPos = NULL;
		return false;
	}
	else
	{
		//Opened file. Clear out preexisting vertex data if we're rebuilding the model
		if( m_VertPos )
			free( m_VertPos );
	}

	//Read in file header
	fread( Texname, sizeof(char), 32, File );
	fread( &m_NumVerts, sizeof(unsigned short), 1, File );
	fread( &m_NumTris, sizeof(unsigned short), 1, File );

	//Allocate m_VertPos, m_VertUVW, m_VertNorm, and m_Indices in one pool for speed
	//(We use m_VertPos to see if a valid shape was loaded)
	m_VertPos = (float*)malloc( sizeof(float)*8*m_NumVerts +
								sizeof(unsigned short)*3*m_NumTris );

	m_VertUVW = m_VertPos + 3*m_NumVerts;
	m_VertNorm = m_VertUVW + 2*m_NumVerts;
	m_Indices = (unsigned short*)(m_VertNorm + 3*m_NumVerts);

	//Read data in
	fread( m_VertPos, sizeof(float)*3, m_NumVerts, File );
	fread( m_VertUVW, sizeof(float)*2, m_NumVerts, File );
	fread( m_VertNorm, sizeof(float)*3, m_NumVerts, File );
	fread( m_Indices, sizeof(unsigned short)*3, m_NumTris, File );

	std::vector<Vertex> vertices;

	int vertcounter = 0;
	int uvcounter = 0;
	for (int i = 0; i < m_NumVerts * 3; i += 3)
	{
		float x = m_VertPos[i];
		float y = m_VertPos[i + 1];
		float z = m_VertPos[i + 2];

		Vertex thisvertex;
		thisvertex.x = x / 10.0f;
		thisvertex.y = z / 10.0f;
		thisvertex.z = y / 10.0f;
		thisvertex.r = 1;
		thisvertex.g = 1;
		thisvertex.b = 1;
		thisvertex.a = 1;
		thisvertex.u = m_VertUVW[uvcounter];
		thisvertex.v = 1 - m_VertUVW[uvcounter + 1];
		uvcounter += 2;
		vertcounter += 3;

		vertices.push_back(thisvertex);
	}

	std::vector<unsigned int> indices;

	for (int i = 0; i < m_NumTris * 3; ++i)
	{
		unsigned short thisindex = m_Indices[i];

		indices.push_back(static_cast<unsigned int>(thisindex));
	}



		//float xOffset = m_VertPos[0];
		//for (int i = 0; i < m_NumVerts; i = i + 3)
		//{
		//	m_VertPos[i] -= xOffset;
		//}

		//float yOffset = m_VertPos[1];
		//for (int i = 1; i < m_NumVerts; i = i + 3)
		//{
		//	m_VertPos[i] -= yOffset;
		//}

		//float zOffset = m_VertPos[2];
		//for (int i = 2; i < m_NumVerts; i = i + 3)
		//{
		//	m_VertPos[i] -= zOffset;
		//}

	m_Mesh.Init(vertices, indices);


	fclose( File );

	sprintf(Filename, "3dmodels/%s.png", Texname);
	m_Texture = g_ResourceManager->GetTexture(Filename);
	m_TexID = m_Texture->GetTextureID();

	m_Filename = Filename;

	return true;
}

bool ModelFrame3D::Render( )
{
	//Did we fail to cache this?
#if 1
	if( !m_VertPos )		
		return false;
#else
	if( m_ShapeID == 0x18b && 0 )
	{
		if( !Build() )
			return false;
	}
	else
	{
		if( !m_VertPos )
			return false;
	}
#endif

#if 0
	//Debug information
	printf( "3D: Rendering model %05d:%02d\n", m_ShapeID, m_FrameID );
	printf("%s:%d - glGetError()=0x%08x\n",__FILE__,__LINE__,glGetError()); fflush(stdout);
#endif

#if 1
	//Quick render
	//glVertexPointer( 3, GL_FLOAT, 0, m_VertPos );
	//glTexCoordPointer( 2, GL_FLOAT, 0, m_VertUVW );
	//glNormalPointer( GL_FLOAT, 0, m_VertNorm );

	//glBindTexture( GL_TEXTURE_2D, m_TexID );
	//glEnable( GL_LIGHTING );
	//glDrawElements( GL_TRIANGLES, m_NumTris*3, GL_UNSIGNED_SHORT, m_Indices );
	//glDisable( GL_LIGHTING );
	g_Display->DrawMesh(&m_Mesh, glm::vec3(0, 0, 0), m_Texture);
#else
	//Debug render
	glDisable( GL_TEXTURE_2D );
	glBegin( GL_TRIANGLES );
	for( int i = 0; i < m_NumTris; i++ )
	{
		glColor3f( m_VertNorm[m_Indices[i*3+0]*3+0]/2.0f+0.5f, m_VertNorm[m_Indices[i*3+0]*3+1]/2.0f+0.5f, m_VertNorm[m_Indices[i*3+0]*3+2]/2.0f+0.5f );
		glVertex3fv( &m_VertPos[m_Indices[i*3+0]*3] );

		glColor3f( m_VertNorm[m_Indices[i*3+1]*3+0]/2.0f+0.5f, m_VertNorm[m_Indices[i*3+1]*3+1]/2.0f+0.5f, m_VertNorm[m_Indices[i*3+1]*3+2]/2.0f+0.5f );
		glVertex3fv( &m_VertPos[m_Indices[i*3+1]*3] );

		glColor3f( m_VertNorm[m_Indices[i*3+2]*3+0]/2.0f+0.5f, m_VertNorm[m_Indices[i*3+2]*3+1]/2.0f+0.5f, m_VertNorm[m_Indices[i*3+2]*3+2]/2.0f+0.5f );
		glVertex3fv( &m_VertPos[m_Indices[i*3+2]*3] );
	}
	glColor3f( 1, 1, 1 );
	glEnd();
	glEnable( GL_TEXTURE_2D );
#endif

	if(glGetError()){printf("%s:%d - glGetError()=0x%08x\n",__FILE__,__LINE__,glGetError()); fflush(stdout);}

	return true;
}
