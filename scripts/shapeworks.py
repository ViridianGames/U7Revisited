import os
import sys
import time
import random
import requests
import glob
import json
import yaml
import subprocess
#import urlparse
import urllib
#from urllib.parse import quote
import gzip
import codecs
#import pycurl
import uuid
import numpy as np
import shutil
import zipfile

from plebwerks import FileWerks, stringStripStart, stringStripEnd, stringMatch, stringMatchStart, \
    stringMatchEnd, stringClean, listAdd, listContains, yamlRead, yamlWrite, timeNow, \
    openTextFileWrite, dictGetKeys, dictGetValue, openBinaryFileWrite, stringToFile, stringSplitNoEmpty


def pathAssertExists(path):
    if os.path.isdir(path):
        pass
    else:
        os.makedirs(path)


def rotate_point_numpy(x, y, angle_degrees, center_x=0.0, center_y=0.0):
    """Rotates a point (x, y) around the center (center_x, center_y) by angle_degrees."""

    angle_radians = np.radians(angle_degrees)
    rotation_matrix = np.array([
        [np.cos(angle_radians), -np.sin(angle_radians)],
        [np.sin(angle_radians), np.cos(angle_radians)]
    ])

    point = np.array([x - center_x, y - center_y])
    rotated_point = np.dot(rotation_matrix, point)

    return rotated_point[0] + center_x, rotated_point[1] + center_y


class shapesMan:
    def __init__(self, dataRoot='data/'):
        self.dataRoot = dataRoot
        shapeTablePath = f'{self.dataRoot}shapetable.dat'
        shapeTableFW = FileWerks(shapeTablePath)
        self.shapes = {}
        for i in range(0, 1024):
            self.shapes[i] = {}
            self.shapes[i]['frames'] = []
        if shapeTableFW.exists is True:
            lines = shapeTableFW.getLines()
            for line in lines:
                lVals = line.split(' ')
                if len(lVals) == 35:
                    incrementDraw = 0
                    lIdx = 0
                    #m_shape
                    shapeIdx = int(lVals[lIdx])
                    lIdx += 1
                    #m_frame
                    frameIdx = int(lVals[lIdx])
                    lIdx += 1

                    ## set up the dictionary
                    while len(self.shapes[shapeIdx]['frames']) <= frameIdx:
                        self.shapes[shapeIdx]['frames'].append({})
                    
                    ## now continue through other values
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_topTextureOffsetX'] = int(lVals[lIdx])
                    lIdx += 1
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_topTextureOffsetY'] = int(lVals[lIdx])
                    lIdx += 1
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_topTextureWidth'] = int(lVals[lIdx])
                    lIdx += 1
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_topTextureHeight'] = int(lVals[lIdx])
                    lIdx += 1
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_frontTextureOffsetX'] = int(lVals[lIdx])
                    lIdx += 1
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_frontTextureOffsetY'] = int(lVals[lIdx])
                    lIdx += 1
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_frontTextureWidth'] = int(lVals[lIdx])
                    lIdx += 1
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_frontTextureHeight'] = int(lVals[lIdx])
                    lIdx += 1
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_rightTextureOffsetX'] = int(lVals[lIdx])
                    lIdx += 1
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_rightTextureOffsetY'] = int(lVals[lIdx])
                    lIdx += 1
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_rightTextureWidth'] = int(lVals[lIdx])
                    lIdx += 1
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_rightTextureHeight'] = int(lVals[lIdx])
                    lIdx += 1
                    #	int drawType
                    #	m_drawType = static_cast<ShapeDrawType>(drawType)
                    drawType = int(lVals[lIdx])
                    if drawType == 0:
                        imgSum = self.shapes[shapeIdx]['frames'][frameIdx]['m_topTextureOffsetX'] \
                            + self.shapes[shapeIdx]['frames'][frameIdx]['m_topTextureOffsetY'] \
                            + self.shapes[shapeIdx]['frames'][frameIdx]['m_topTextureWidth'] \
                            + self.shapes[shapeIdx]['frames'][frameIdx]['m_topTextureHeight'] \
                            + self.shapes[shapeIdx]['frames'][frameIdx]['m_frontTextureOffsetX'] \
                            + self.shapes[shapeIdx]['frames'][frameIdx]['m_frontTextureOffsetY'] \
                            + self.shapes[shapeIdx]['frames'][frameIdx]['m_frontTextureWidth'] \
                            + self.shapes[shapeIdx]['frames'][frameIdx]['m_frontTextureHeight'] \
                            + self.shapes[shapeIdx]['frames'][frameIdx]['m_rightTextureOffsetX'] \
                            + self.shapes[shapeIdx]['frames'][frameIdx]['m_rightTextureOffsetY'] \
                            + self.shapes[shapeIdx]['frames'][frameIdx]['m_rightTextureWidth'] \
                            + self.shapes[shapeIdx]['frames'][frameIdx]['m_rightTextureHeight']
                        if imgSum > 0:
                            #print(f'shape[{shapeIdx}:{frameIdx}] drawType[{drawType}] {lVals[3:33]}')
                            #incrementDraw = 1
                            pass
                    else:
                        #incrementDraw = 1
                        pass
                    lIdx += 1
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_drawType'] = drawType + incrementDraw

                    self.shapes[shapeIdx]['frames'][frameIdx]['m_Scaling_x'] = float(lVals[lIdx])
                    lIdx += 1
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_Scaling_y'] = float(lVals[lIdx])
                    lIdx += 1
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_Scaling_z'] = float(lVals[lIdx])
                    lIdx += 1
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_TweakPos_x'] = float(lVals[lIdx])
                    lIdx += 1
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_TweakPos_y'] = float(lVals[lIdx])
                    lIdx += 1
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_TweakPos_z'] = float(lVals[lIdx])
                    lIdx += 1
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_rotation'] = float(lVals[lIdx])
                    lIdx += 1
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_sideTextures0'] = int(lVals[lIdx])
                    lIdx += 1
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_sideTextures1'] = int(lVals[lIdx])
                    lIdx += 1
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_sideTextures2'] = int(lVals[lIdx])
                    lIdx += 1
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_sideTextures3'] = int(lVals[lIdx])
                    lIdx += 1
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_sideTextures4'] = int(lVals[lIdx])
                    lIdx += 1
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_sideTextures5'] = int(lVals[lIdx])
                    lIdx += 1

                    self.shapes[shapeIdx]['frames'][frameIdx]['m_customMeshName'] = lVals[lIdx]
                    #print(m_customMeshName)
                    lIdx += 1
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_meshOutline'] = int(lVals[lIdx])
                    lIdx += 1

                    self.shapes[shapeIdx]['frames'][frameIdx]['m_useShapePointer'] = int(lVals[lIdx])
                    lIdx += 1
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_frameCount'] = int(lVals[lIdx])
                    #if self.shapes[shapeIdx]['frames'][frameIdx]['m_frameCount'] > 1:
                    #    print(f'[{shapeIdx}:{frameIdx}]')
                    lIdx += 1
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_pointerShape'] = int(lVals[lIdx])
                    lIdx += 1
                    self.shapes[shapeIdx]['frames'][frameIdx]['m_pointerFrame'] = int(lVals[lIdx])
                    lIdx += 1
                    #print(lIdx)
                else:
                    print(len(lVals))
        self.intakeTFA()
    
    def intakeTFA(self, tfaYamlPath='data/data/u7/STATIC/TFA.DAT.yaml'):
        tfaObjs = yamlRead(tfaYamlPath)
        if isinstance(tfaObjs, dict):
            for shapeIdx in tfaObjs:
                self.shapes[shapeIdx]['width'] = dictGetValue(tfaObjs[shapeIdx], 'm_width')
                self.shapes[shapeIdx]['height'] = dictGetValue(tfaObjs[shapeIdx], 'm_height')
                self.shapes[shapeIdx]['depth'] = dictGetValue(tfaObjs[shapeIdx], 'm_depth')
                #print(tfaKey)
                #print(type(tfaKey))
        #print(type(tfaObjs))
    
    def scootMesh(self, meshName, outMeshName):
        meshFW = FileWerks(meshName)
        materialLibrary = None
        currentSurfaceIndex = None
        surfaces = []
        vertices = []
        bbMin = [None, None, None]
        bbMax = [None, None, None]
        writeMesh = False
        segments = {}
        curSegment = 'all'
        segments[curSegment] = []
        if meshFW.exists is True:
            lines = meshFW.getLines()
            for line in lines:
                #print(line)
                line = line.split('#')[0] # no comment
                lVals = line.split(' ')
                if len(lVals) >= 1:
                    cmd = lVals[0]
                    print(f'CMD: {cmd}')
                    if len(cmd) > 0:
                        if curSegment in segments:
                            pass
                        else:
                            segments[curSegment] = []
                        if curSegment in segments:
                            segments[curSegment].append(line)
                    if len(cmd) == 0:
                        #print(line)
                        pass
                    elif stringMatch(cmd, 'v'):
                        # vertices
                        if len(lVals) == 4:
                            pos = [float(lVals[1]), float(lVals[2]), float(lVals[3])]
                            #rX, rZ = rotate_point_numpy(pos[0], pos[2], rotAngle)
                            #pos[0] = rX
                            #pos[2] = rZ
                            #x = float(lVals[1])
                            #y = float(lVals[2])
                            #z = float(lVals[3])
                            #print(f'vertex {x:0.05f} {y:0.05f} {z:0.05f}')
                            for i in range(0, 3):
                                if bbMin[i] is None:
                                    bbMin[i] = pos[i]
                                    bbMax[i] = pos[i]
                                else:
                                    if pos[i] < bbMin[i]:
                                        bbMin[i] = pos[i]
                                    elif pos[i] > bbMax[i]:
                                        bbMax[i] = pos[i]
                            pass
                        else:
                            print(line)
                        pass
                    elif stringMatch(cmd, 'vt'):
                        # vertex texture (UV)
                        if len(lVals) == 3:
                            pass
                        else:
                            print(line)
                        pass
                    elif stringMatch(cmd, 'vn'):
                        # vertex normal (3d direction of 'up' from surface)
                        if len(lVals) == 4:
                            pass
                        else:
                            print(line)
                        pass
                    elif stringMatch(cmd, 'f'):
                        if len(lVals) == 4:
                            pass
                        elif len(lVals) == 5:
                            pass
                        else:
                            print(line)
                        # faces
                        pass
                    elif stringMatch(cmd, 'usemtl'):
                        # surface material
                        lVal = stringStripStart(line, f'{cmd} ')
                        if currentSurfaceIndex is not None:
                            surfaces[currentSurfaceIndex]['material'] = lVal
                        pass
                    elif stringMatch(cmd, 'mtllib'):
                        # material library
                        lVal = stringStripStart(line, f'{cmd} ')
                        materialLibrary = lVal
                        pass
                    elif stringMatch(cmd, 's'):
                        # surface index
                        lVal = stringStripStart(line, f'{cmd} ')
                        sIdx = int(lVal)
                        while len(surfaces) < (sIdx+1):
                            surfaces.append({})
                        currentSurfaceIndex = sIdx
                        pass
                    elif stringMatch(cmd, 'o'):
                        # surface name
                        lVal = stringStripStart(line, f'{cmd} ')
                        if currentSurfaceIndex is not None:
                            surfaces[currentSurfaceIndex]['label'] = lVal
                        pass
                    else:
                        print(cmd)
        #print(f'  bbMin {bbMin}')
        #print(f'  bbMax {bbMax}')
        bbDiff = [0.0, 0.0, 0.0]
        for i in range(0, 3):
            bbDiff[i] = bbMax[i] - bbMin[i]
        bbCenter = [bbMin[0] + (bbDiff[0] * 0.5), bbMin[1] + (bbDiff[1] * 0.5), bbMin[2] + (bbDiff[2] * 0.5)]
        outStr = ''
        for line in segments[curSegment]:
            #print(line)
            if stringMatchStart(line, 'v '):
                lVals = line.split(' ')
                if len(lVals) == 4:
                    pos = [float(lVals[1]), float(lVals[2]), float(lVals[3])]
                    for i in range(0, 3):
                        if i != 1:
                            pos[i] -= bbCenter[i]
                        else:
                            pos[1] -= bbMin[i]
                    outStr += f'v {pos[0]:0.08f} {pos[1]:0.08f} {pos[2]:0.08f}\n'
                else:
                    outStr += f'{line}\n'
                pass
            else:
                outStr += f'{line}\n'
        stringToFile(outMeshName, outStr)
        return bbMin, bbMax
    
    def parseMesh(self, meshName):
        meshFW = FileWerks(meshName)
        materialLibrary = None
        currentSurfaceIndex = None
        surfaces = []
        vertices = []
        bbMin = [None, None, None]
        bbMax = [None, None, None]
        if meshFW.exists is True:
            lines = meshFW.getLines()
            for line in lines:
                #print(line)
                line = line.split('#')[0] # no comment
                lVals = line.split(' ')
                if len(lVals) >= 1:
                    cmd = lVals[0]
                    if len(cmd) == 0:
                        pass
                    elif stringMatch(cmd, 'v'):
                        # vertices
                        if len(lVals) == 4:
                            pos = [float(lVals[1]), float(lVals[2]), float(lVals[3])]
                            #rX, rZ = rotate_point_numpy(pos[0], pos[2], rotAngle)
                            #pos[0] = rX
                            #pos[2] = rZ
                            #x = float(lVals[1])
                            #y = float(lVals[2])
                            #z = float(lVals[3])
                            #print(f'vertex {x:0.05f} {y:0.05f} {z:0.05f}')
                            for i in range(0, 3):
                                if bbMin[i] is None:
                                    bbMin[i] = pos[i]
                                    bbMax[i] = pos[i]
                                else:
                                    if pos[i] < bbMin[i]:
                                        bbMin[i] = pos[i]
                                    elif pos[i] > bbMax[i]:
                                        bbMax[i] = pos[i]
                            pass
                        else:
                            print(line)
                        pass
                    elif stringMatch(cmd, 'vt'):
                        # vertex texture (UV)
                        if len(lVals) == 3:
                            pass
                        else:
                            print(line)
                        pass
                    elif stringMatch(cmd, 'vn'):
                        # vertex normal (3d direction of 'up' from surface)
                        if len(lVals) == 4:
                            pass
                        else:
                            print(line)
                        pass
                    elif stringMatch(cmd, 'f'):
                        if len(lVals) == 4:
                            pass
                        elif len(lVals) == 5:
                            pass
                        else:
                            print(line)
                        # faces
                        pass
                    elif stringMatch(cmd, 'usemtl'):
                        # surface material
                        lVal = stringStripStart(line, f'{cmd} ')
                        if currentSurfaceIndex is not None:
                            surfaces[currentSurfaceIndex]['material'] = lVal
                        pass
                    elif stringMatch(cmd, 'mtllib'):
                        # material library
                        lVal = stringStripStart(line, f'{cmd} ')
                        materialLibrary = lVal
                        pass
                    elif stringMatch(cmd, 's'):
                        # surface index
                        lVal = stringStripStart(line, f'{cmd} ')
                        sIdx = int(lVal)
                        while len(surfaces) < (sIdx+1):
                            surfaces.append({})
                        currentSurfaceIndex = sIdx
                        pass
                    elif stringMatch(cmd, 'o'):
                        # surface name
                        lVal = stringStripStart(line, f'{cmd} ')
                        if currentSurfaceIndex is not None:
                            surfaces[currentSurfaceIndex]['label'] = lVal
                        pass
                    else:
                        print(cmd)
        #print(f'  bbMin {bbMin}')
        #print(f'  bbMax {bbMax}')
        return bbMin, bbMax
    

    def checkAllMeshes(self):
        meshNames = []
        #for shapeNum in range(150, 1024):
        for shapeNum in range(873, 874):
            for frameNum in range(0, 32):
                drawType = dictGetValue(self.shapes[shapeNum]['frames'][frameNum], 'm_drawType')
                if drawType >= 4:
                    meshName = dictGetValue(self.shapes[shapeNum]['frames'][frameNum], 'm_customMeshName')
                    if stringMatch(meshName, 'Models/3dmodels/zzwrongcube.obj'):
                        pass
                    else:
                        #if frameNum == 1:
                        #    print(f'[{shapeNum}: {frameNum}] {drawType} {meshName}')
                        #    self.checkMesh(shapeNum, frameNum)
                        if frameNum == 3:
                            print(f'[{shapeNum}: {frameNum}] {drawType} {meshName}')
                            meshName = self.checkMesh(shapeNum, frameNum)
                            if isinstance(meshName, str):
                                if len(meshName) > 0:
                                    listAdd(meshNames, meshName)
                    #print(drawType)
        for meshName in sorted(meshNames):
            print(meshName)
    
    
    def checkMesh(self, shapeNum, frameNum):
        meshName = dictGetValue(self.shapes[shapeNum]['frames'][frameNum], 'm_customMeshName')
        if stringMatch(meshName, 'Models/3dmodels/zzwrongcube.obj'):
            pass
        else:
            m_Scaling = [1.0, 1.0, 1.0]
            m_Scaling_x = dictGetValue(self.shapes[shapeNum]['frames'][frameNum], 'm_Scaling_x')
            m_Scaling_y = dictGetValue(self.shapes[shapeNum]['frames'][frameNum], 'm_Scaling_y')
            m_Scaling_z = dictGetValue(self.shapes[shapeNum]['frames'][frameNum], 'm_Scaling_z')
            m_Scaling[0] = m_Scaling_x
            m_Scaling[1] = m_Scaling_y
            m_Scaling[2] = m_Scaling_z
            m_TweakPos_x = dictGetValue(self.shapes[shapeNum]['frames'][frameNum], 'm_TweakPos_x')
            m_TweakPos_y = dictGetValue(self.shapes[shapeNum]['frames'][frameNum], 'm_TweakPos_y')
            m_TweakPos_z = dictGetValue(self.shapes[shapeNum]['frames'][frameNum], 'm_TweakPos_z')
            m_rotation = dictGetValue(self.shapes[shapeNum]['frames'][frameNum], 'm_rotation')
            #m_rotation = 0.0
            #self.scootMesh(meshName)
            bbMin, bbMax = self.parseMesh(meshName)
            ## rotate bbMin and bbMax by m_rotation
            #minX, minZ = rotate_point_numpy(bbMin[0], bbMin[2], m_rotation)
            #maxX, maxZ = rotate_point_numpy(bbMax[0], bbMax[2], m_rotation)
            #bbMin[0] = minX
            #bbMax[0] = maxX
            #bbMin[2] = minZ
            #bbMax[2] = maxZ
            print(f'Rotation {m_rotation}')
            print(f'   BB Min [{bbMin}]')
            print(f'   BB Max [{bbMax}]')
            bbDiff = [0.0, 0.0, 0.0]
            for i in range(0, 3):
                bbDiff[i] = bbMax[i] - bbMin[i]
            print(f'BB Diff [{bbDiff}]')
            bbCenter = [bbMin[0] + (bbDiff[0] * 0.5), bbMin[1] + (bbDiff[1] * 0.5), bbMin[2] + (bbDiff[2] * 0.5)]
            print(f'BB Center [{bbCenter}]')
            #for i in range(0, 3):
            #    if bbCenter[i] > bbMax[i]:
            #        print(f'WTF {i}')
            mshSize = [bbMax[0] - bbMin[0], bbMax[1] - bbMin[1], bbMax[2] - bbMin[2]]
            #for i in range(0, 3):
            #    mshSize[i] *= m_Scaling[i]
            print(f'  Mesh Size [{mshSize}]')
            tfaSize = [dictGetValue(self.shapes[shapeNum], 'width'), dictGetValue(self.shapes[shapeNum], 'height'), dictGetValue(self.shapes[shapeNum], 'depth')]
            print(f'   TFA Size [{tfaSize}]')
            recScale = [tfaSize[0] / mshSize[0], tfaSize[1] / mshSize[1], tfaSize[2] / mshSize[2]]
            print(f'   recScale [{recScale}]')
            print(f'  Scaling [{m_Scaling_x} {m_Scaling_y} {m_Scaling_z}]')
            print(f'   Adjust [{m_TweakPos_x} {m_TweakPos_y} {m_TweakPos_z}]')
            print(f'   RecAdv [{(tfaSize[0] * 0.5) - bbCenter[0]} {-bbMin[1]} {(tfaSize[2] * 0.5) - bbCenter[2]}]')
            #print(f'   RecAdv [{bbCenter[0] - (mshSize[0]*0.5)} {-bbMin[1]} {bbCenter[2] - (mshSize[2]*0.5)}]')

            
            #print(meshName)
            #meshFW = FileWerks(meshName)
            #if meshFW.exists is True:
                #print(f'  exists')
            pass
        return meshName


def main(argv):
    ## ok this is main function
    sm = shapesMan('data/')
    #sm.intakeTFA()
    #sm.checkAllMeshes()
    meshNames = []
    # 1x1
    #listAdd(meshNames, 'Models/3dmodels/candle_tin.obj')
    #listAdd(meshNames, 'Models/3dmodels/chair.obj')
    listAdd(meshNames, 'Models/3dmodels/column.obj')
    #listAdd(meshNames, 'Models/3dmodels/green_bottle.obj')
    #listAdd(meshNames, 'Models/3dmodels/whiskey_bottle.obj')
    #listAdd(meshNames, 'Models/3dmodels/wood_stein.obj')
    # 2x1
    #listAdd(meshNames, 'Models/3dmodels/anvil.obj')
    #listAdd(meshNames, 'Models/3dmodels/mountainquarter1.obj')
    #listAdd(meshNames, 'Models/3dmodels/mountainquarter2.obj')
    #listAdd(meshNames, 'Models/3dmodels/mountainside1.obj')
    #listAdd(meshNames, 'Models/3dmodels/mountainside2.obj')
    #listAdd(meshNames, 'Models/3dmodels/reversemountainquarter1.obj')
    #listAdd(meshNames, 'Models/3dmodels/trough_1.obj')
    #listAdd(meshNames, 'Models/3dmodels/trough_2.obj')
    #listAdd(meshNames, 'Models/3dmodels/trough_3.obj')
    #listAdd(meshNames, 'Models/3dmodels/trough_4.obj')
    #listAdd(meshNames, 'Models/3dmodels/wood_long_table.obj')
    #listAdd(meshNames, 'Models/3dmodels/wood_round_table.obj')
    #listAdd(meshNames, 'Original/Models/3dmodels/wooden_chair_001.obj', 'Models/3dmodels/wooden_chair_001.obj')
    for meshName in meshNames:
        sm.scootMesh(f'Original/{meshName}', meshName)
    #sm.scootMesh('Original/Models/3dmodels/wooden_chair_001.obj', 'Models/3dmodels/wooden_chair_001.obj')
    #sm.checkMesh(873, 0)
    sm.checkMesh(687, 2)
    #checkMesh(873, 0)
    pass


## begin main loop
if __name__ == "__main__":
    requests.packages.urllib3.disable_warnings()
    random.seed(timeNow())
    sys.exit(main(sys.argv[1:]))
