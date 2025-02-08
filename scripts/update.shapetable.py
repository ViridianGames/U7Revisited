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
import numpy
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


def updateShapeTable():
    dataRoot = 'data/'
    animFrames3 = []
    listAdd(animFrames3, 934)
    animFrames4 = []
    listAdd(animFrames4, 794)
    animFrames5 = []
    listAdd(animFrames5, 893)
    animFrames11 = []
    listAdd(animFrames11, 256)
    listAdd(animFrames11, 384)
    listAdd(animFrames11, 419)
    listAdd(animFrames11, 516)
    listAdd(animFrames11, 610)
    listAdd(animFrames11, 612)
    listAdd(animFrames11, 613)
    listAdd(animFrames11, 632)
    listAdd(animFrames11, 699)
    listAdd(animFrames11, 736)
    listAdd(animFrames11, 737)
    listAdd(animFrames11, 751)
    #only 8 frames here
    listAdd(animFrames11, 780)
    listAdd(animFrames11, 808)
    listAdd(animFrames11, 834)
    listAdd(animFrames11, 875)
    listAdd(animFrames11, 907)
    listAdd(animFrames11, 911)
    listAdd(animFrames11, 918)
    listAdd(animFrames11, 926)
    listAdd(animFrames11, 927)
    listAdd(animFrames11, 930)
    listAdd(animFrames11, 938)
    listAdd(animFrames11, 985)
    listAdd(animFrames11, 1008)
    listAdd(animFrames11, 1009)
    listAdd(animFrames11, 1012)
    listAdd(animFrames11, 1020)
    listAdd(animFrames11, 1022)
    animFrames12 = []
    listAdd(animFrames12, 222)
    listAdd(animFrames12, 232)
    #print(animFrames11)
    shapeTablePath = f'{dataRoot}original.shapetable.dat'
    shapeTableFW = FileWerks(shapeTablePath)
    shapes = {}
    for i in range(0, 1024):
        shapes[i] = {}
        shapes[i]['frames'] = []
    if shapeTableFW.exists is True:
        lines = shapeTableFW.getLines()
        for line in lines:
            lVals = line.split(' ')
            if len(lVals) == 34:
                incrementDraw = 0
                lIdx = 0
                #m_shape
                shapeIdx = int(lVals[lIdx])
                lIdx += 1
                #m_frame
                frameIdx = int(lVals[lIdx])
                lIdx += 1

                ## set up the dictionary
                while len(shapes[shapeIdx]['frames']) <= frameIdx:
                    shapes[shapeIdx]['frames'].append({})
                
                ## now continue through other values
                shapes[shapeIdx]['frames'][frameIdx]['m_topTextureOffsetX'] = int(lVals[lIdx])
                lIdx += 1
                shapes[shapeIdx]['frames'][frameIdx]['m_topTextureOffsetY'] = int(lVals[lIdx])
                lIdx += 1
                shapes[shapeIdx]['frames'][frameIdx]['m_topTextureWidth'] = int(lVals[lIdx])
                lIdx += 1
                shapes[shapeIdx]['frames'][frameIdx]['m_topTextureHeight'] = int(lVals[lIdx])
                lIdx += 1
                shapes[shapeIdx]['frames'][frameIdx]['m_frontTextureOffsetX'] = int(lVals[lIdx])
                lIdx += 1
                shapes[shapeIdx]['frames'][frameIdx]['m_frontTextureOffsetY'] = int(lVals[lIdx])
                lIdx += 1
                shapes[shapeIdx]['frames'][frameIdx]['m_frontTextureWidth'] = int(lVals[lIdx])
                lIdx += 1
                shapes[shapeIdx]['frames'][frameIdx]['m_frontTextureHeight'] = int(lVals[lIdx])
                lIdx += 1
                shapes[shapeIdx]['frames'][frameIdx]['m_rightTextureOffsetX'] = int(lVals[lIdx])
                lIdx += 1
                shapes[shapeIdx]['frames'][frameIdx]['m_rightTextureOffsetY'] = int(lVals[lIdx])
                lIdx += 1
                shapes[shapeIdx]['frames'][frameIdx]['m_rightTextureWidth'] = int(lVals[lIdx])
                lIdx += 1
                shapes[shapeIdx]['frames'][frameIdx]['m_rightTextureHeight'] = int(lVals[lIdx])
                lIdx += 1
                #	int drawType
                #	m_drawType = static_cast<ShapeDrawType>(drawType)
                drawType = int(lVals[lIdx])
                if drawType == 0:
                    imgSum = shapes[shapeIdx]['frames'][frameIdx]['m_topTextureOffsetX'] \
                           + shapes[shapeIdx]['frames'][frameIdx]['m_topTextureOffsetY'] \
                           + shapes[shapeIdx]['frames'][frameIdx]['m_topTextureWidth'] \
                           + shapes[shapeIdx]['frames'][frameIdx]['m_topTextureHeight'] \
                           + shapes[shapeIdx]['frames'][frameIdx]['m_frontTextureOffsetX'] \
                           + shapes[shapeIdx]['frames'][frameIdx]['m_frontTextureOffsetY'] \
                           + shapes[shapeIdx]['frames'][frameIdx]['m_frontTextureWidth'] \
                           + shapes[shapeIdx]['frames'][frameIdx]['m_frontTextureHeight'] \
                           + shapes[shapeIdx]['frames'][frameIdx]['m_rightTextureOffsetX'] \
                           + shapes[shapeIdx]['frames'][frameIdx]['m_rightTextureOffsetY'] \
                           + shapes[shapeIdx]['frames'][frameIdx]['m_rightTextureWidth'] \
                           + shapes[shapeIdx]['frames'][frameIdx]['m_rightTextureHeight']
                    if imgSum > 0:
                        #print(f'shape[{shapeIdx}:{frameIdx}] drawType[{drawType}] {lVals[3:33]}')
                        incrementDraw = 1
                else:
                    incrementDraw = 1
                lIdx += 1
                shapes[shapeIdx]['frames'][frameIdx]['m_drawType'] = drawType + incrementDraw

                shapes[shapeIdx]['frames'][frameIdx]['m_Scaling_x'] = float(lVals[lIdx])
                lIdx += 1
                shapes[shapeIdx]['frames'][frameIdx]['m_Scaling_y'] = float(lVals[lIdx])
                lIdx += 1
                shapes[shapeIdx]['frames'][frameIdx]['m_Scaling_z'] = float(lVals[lIdx])
                lIdx += 1
                shapes[shapeIdx]['frames'][frameIdx]['m_TweakPos_x'] = float(lVals[lIdx])
                lIdx += 1
                shapes[shapeIdx]['frames'][frameIdx]['m_TweakPos_y'] = float(lVals[lIdx])
                lIdx += 1
                shapes[shapeIdx]['frames'][frameIdx]['m_TweakPos_z'] = float(lVals[lIdx])
                lIdx += 1
                shapes[shapeIdx]['frames'][frameIdx]['m_rotation'] = float(lVals[lIdx])
                lIdx += 1
                shapes[shapeIdx]['frames'][frameIdx]['m_sideTextures0'] = int(lVals[lIdx])
                lIdx += 1
                shapes[shapeIdx]['frames'][frameIdx]['m_sideTextures1'] = int(lVals[lIdx])
                lIdx += 1
                shapes[shapeIdx]['frames'][frameIdx]['m_sideTextures2'] = int(lVals[lIdx])
                lIdx += 1
                shapes[shapeIdx]['frames'][frameIdx]['m_sideTextures3'] = int(lVals[lIdx])
                lIdx += 1
                shapes[shapeIdx]['frames'][frameIdx]['m_sideTextures4'] = int(lVals[lIdx])
                lIdx += 1
                shapes[shapeIdx]['frames'][frameIdx]['m_sideTextures5'] = int(lVals[lIdx])
                lIdx += 1

                shapes[shapeIdx]['frames'][frameIdx]['m_customMeshName'] = lVals[lIdx]
                #print(m_customMeshName)
                lIdx += 1
                shapes[shapeIdx]['frames'][frameIdx]['m_meshOutline'] = int(lVals[lIdx])
                lIdx += 1

                shapes[shapeIdx]['frames'][frameIdx]['m_useShapePointer'] = int(lVals[lIdx])
                lIdx += 1
                shapes[shapeIdx]['frames'][frameIdx]['m_pointerShape'] = int(lVals[lIdx])
                lIdx += 1
                shapes[shapeIdx]['frames'][frameIdx]['m_pointerFrame'] = int(lVals[lIdx])
                lIdx += 1
                shapes[shapeIdx]['frames'][frameIdx]['m_frameCount'] = 1
                if shapeIdx in animFrames3:
                    if frameIdx < 3:
                        shapes[shapeIdx]['frames'][frameIdx]['m_frameCount'] = 3
                if shapeIdx in animFrames4:
                    #if frameIdx < 4:
                    shapes[shapeIdx]['frames'][frameIdx]['m_frameCount'] = 4
                if shapeIdx in animFrames5:
                    if frameIdx < 5:
                        shapes[shapeIdx]['frames'][frameIdx]['m_frameCount'] = 5
                if shapeIdx in animFrames11:
                    if frameIdx < 11:
                        shapes[shapeIdx]['frames'][frameIdx]['m_frameCount'] = 11
                if shapeIdx in animFrames12:
                    if frameIdx < 12:
                        shapes[shapeIdx]['frames'][frameIdx]['m_frameCount'] = 12
                #print(lIdx)

#	//printf("Shape: %d Frame: %d DrawType: %d\n", m_shape, m_frame, m_drawType)
#	Init(m_shape, m_frame, false)
                pass
            else:
                print(len(lVals))
                print(line)
    outString = ''
    for i in range(150, 1024):
        if i in shapes:
            for j in range(0, 32):
                if j > len(shapes[shapeIdx]['frames']):
                    print('OOF')
                else:
                    shapeIdx = i
                    frameIdx = j
                    outString += f'{i} {j} '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_topTextureOffsetX')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_topTextureOffsetY')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_topTextureWidth')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_topTextureHeight')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_frontTextureOffsetX')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_frontTextureOffsetY')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_frontTextureWidth')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_frontTextureHeight')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_rightTextureOffsetX')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_rightTextureOffsetY')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_rightTextureWidth')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_rightTextureHeight')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_drawType')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_Scaling_x')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_Scaling_y')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_Scaling_z')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_TweakPos_x')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_TweakPos_y')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_TweakPos_z')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_rotation')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_sideTextures0')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_sideTextures1')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_sideTextures2')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_sideTextures3')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_sideTextures4')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_sideTextures5')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_customMeshName')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_meshOutline')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_useShapePointer')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_frameCount')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_pointerShape')) + ' '
                    outString += str(dictGetValue(shapes[shapeIdx]['frames'][frameIdx], 'm_pointerFrame')) + ' '

                    outString += '\n'
            pass
        else:
            print('OOF')
    stringToFile('data/shapetable.dat', outString)


def main(argv):
    ## ok this is main function
    updateShapeTable()
    pass


## begin main loop
if __name__ == "__main__":
    requests.packages.urllib3.disable_warnings()
    random.seed(timeNow())
    sys.exit(main(sys.argv[1:]))
