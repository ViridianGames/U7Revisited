#!/c/Python26/python.exe
#import ogre.renderer.OGRE as ogre
#import ogre.io.OIS as OIS
#import SampleFramework as sf
#import ode
#from ode_n_ogre import *
import os
import struct
#import os, gc, time
#from wuhandy import *
#from wudanicon import *
from wicon.handy import file_open_in, file_open_in_b, file_open_out
from wicon.common import list_getlast, file_exists, str_strip_newline, str_strip_start, str_strip_end, str_match
from wicon.image_utils import getimagesize
from wicon.selection import getselsize
from wicon.wudanicon import ImageOperation, tiny_dot

#def getshapename(shapenum):
#	global shapesman
#	return shapesman.shapenames[shapenum]


def shapeexclude(shapenum):
	#if(shapenum == 275):
	#	return True
	return False
	if(shapenum == 275):
		return True
	elif(shapenum == 0): #carpet
		return True
	elif(shapenum == 1): #sidwalk
		return True
	elif(shapenum == 2): #carpet
		return True
	elif(shapenum == 3): #lightning
		return True
	elif(shapenum == 6): #arrow
		return True
	elif(shapenum == 15): #ford
		return True
	elif(shapenum == 16): #rut
		return True
	elif(shapenum == 20): #unknown
		return True
	elif(shapenum == 21): #stone floor
		return True
	elif(shapenum == 200): #trap
		return True
	elif(shapenum == 283): #desk
		return True
	elif(shapenum == 305): #The Black Gate
		return True
	elif(shapenum == 330): #Virtue Stone
		return True
	elif(shapenum == 400): #body
		return True
	elif(shapenum == 405): #ship's hold
		return True
	elif(shapenum == 407): #desk
		return True
	elif(shapenum == 406): #nightstand
		return True
	elif(shapenum == 414): #body
		return True
	elif(shapenum == 416): #drawers
		return True
	elif(shapenum == 507): #corpse
		return True
	elif(shapenum == 522): #locked chest
		return True
	elif(shapenum == 679):
		return True
	elif(shapenum == 762): #body
		return True
	elif(shapenum == 776): #moongate
		return True
	elif(shapenum == 777): #moongate
		return True
	elif(shapenum == 778): #body
		return True
	elif(shapenum == 406):
		return True
	elif(shapenum == 798):
		return True
	elif(shapenum == 799):  #unsealed box
		return True
	elif(shapenum == 800):
		return True
	elif(shapenum == 801): #backpack
		return True
	elif(shapenum == 802):
		return True
	elif(shapenum == 803):
		return True
	elif(shapenum == 804):
		return True
	elif(shapenum == 819):
		return True
	elif(shapenum == 892):  #body
		return True
	elif(shapenum == 961): #barge
		return True
	return False

class shapeTop():
	def __init__(self,path):
		self.path = path
		self.ofs = []
		self.shapes = []
		self.shapenames = []
		self.shapetfas = []
		self.numshapes = None
		self.filesize = None
		self.readtext = False
		self.intformat = "<1I"
		self.ofsformat = "<2I"
		self.ihdformat = "<4h"
		
		inf = file_open_in_b(self.path)
		if(inf==None):
			print('	ERR: unable to open %s' % (self.path))
			return None
		self.filesize = os.stat(self.path)[6]
		print('	size of %s: %d bytes' % (self.path, self.filesize))
		
		#this section reads in the number of shapes
		#we know the filesize at this point
		inf.seek(0x54)
		tmpdata = inf.read(struct.calcsize(self.intformat))
		data = struct.unpack(self.intformat, tmpdata)
		self.numshapes = int(data[0])
		
		#this section reads in the offsets for this data
		#we know the number of shapes at this point
		inf.seek(0x80)
		for i in range(0,self.numshapes):
			inf.seek(0x80+(i*8))
			tmpdata = inf.read(struct.calcsize(self.ofsformat))
			data = struct.unpack(self.ofsformat, tmpdata)
			self.ofs.append([data[0],data[1],0])
			#for i in range(0,numschunks):
			#	tmpdata = inf.read(struct.calcsize(chunkFormat))
			#	data = struct.unpack(chunkFormat, tmpdata)
			#	self.schunk.append(data)
			#for i in range(0,self.numschunks):
			#	print('Schunk %d - %d' % (i,len(self.schunk[i])))
			#	scy = 256 * (i/12)
			#	scx = 256 * (i%12)
			#	#for val in self.schunk[i]:
			#	#	print(val)
			#	print('  %d, %d' % (scx, scy))
			#for schunk in self.schunks:
			#	print('Schunk: %d' % (len(schunk)))
		
		
		#this section builds the actual shape offsets for shapes 150 and up
		inf.seek(self.ofs[150][0])
		#print(self.ofs[150][0])
		#return
		print('	reading shapes offsets')
		for i in range(150,self.numshapes):
			#print(i)
			inf.seek(self.ofs[i][0])
			keepos = self.ofs[i][0]
			#print(keepos)
			tmpdata = inf.read(struct.calcsize(self.ofsformat))
			data = struct.unpack(self.ofsformat, tmpdata)
			if(i<self.numshapes-1):
				self.ofs[i+1][0] = data[0]+keepos
			self.ofs[i+0][1] = data[1]
			#print('%d %08x' % (i, ofs[i][0]))
		inf.close()

	def readFlexText(self,path):
		ofs = []
		inf = file_open_in_b(path)
		if(inf==None):
			print('        ERR: unable to open %s' % (path))
			return None
		inf.seek(0x80)
		for i in range(0,self.numshapes):
			data = struct.unpack("2I", inf.read(8))
			#print(data)
			ofs.append([data[0],data[1]])
		for i in range(0,self.numshapes):
			inf.seek(ofs[i][0])
			val = struct.unpack("%ds" % (ofs[i][1]), inf.read(ofs[i][1]))[0]
			self.shapenames.append(val[:-1])
			#print(val)
		inf.close()

	def readShapeTFA(self,path):
		ofs = []
		inf = file_open_in_b(path)
		if(inf==None):
			print('        ERR: unable to open %s' % (path))
			return None
		inf.seek(0)
		for i in range(0,self.numshapes):
			data = struct.unpack("3B", inf.read(3))
			#print(data)
			val1 = data[0]
			val2 = data[1]
			val3 = data[2]
			self.shapetfas.append([val1,val2,val3])
		#	ofs.append([data[0],data[1]])
		#for i in range(0,self.numshapes):
		#	inf.seek(ofs[i][0])
		#	val = struct.unpack("%ds" % (ofs[i][1]), inf.read(ofs[i][1]))[0]
		#	self.shapenames.append(val[:-1])
			#print(val)
		inf.close()

	def shape_frame_get(self,shapenum,framenum):
		of = self.ofs[shapenum]
		for shape in self.shapes:
			if(shape.index == shapenum):
				shape.frame_read(framenum)
				return shape
		#hasn't been loaded before
		inf = file_open_in_b(self.path)
		if(inf==None):
			print('	unable to open %s' % (self.path))
			return None
		#print('shapenum(%d) framenum(%d) get offsets!' % (shapenum, framenum))
		numframes = of[1] / 64
		shape = u7shape(shapenum,framenum)
		if(shapenum>=150):
			numframes = (of[1]-4)/4
			for j in range(0,numframes):
				inf.seek(of[0]+4+(j*4))
				tmpdata = inf.read(struct.calcsize(self.intformat))
				data = struct.unpack(self.intformat, tmpdata)
				frameofs = data[0]+of[0]
				#print('(%s): %03x_%02d:0x%06x' % (self.getshapename(shapenum),shapenum,j,frameofs))
				inf.seek(frameofs)
				tmpdata = inf.read(struct.calcsize(self.ihdformat))
				data = struct.unpack(self.ihdformat, tmpdata)
				xright = data[0]
				xleft = data[1]
				yabove = data[2]
				ybelow = data[3]
				pofs = [xright,xleft,yabove,ybelow]
				shape.setFramePXO(j,pofs)
		else:
			for j in range(0,numframes):
				pofs = [8,8]
				print('(%s): %03x_%02d:%s' % (self.getshapename(shapenum),shapenum,j,pofs))
				shape.setFrameOfs(j,pofs)
		inf.close()
		#print('%03x (%02d): %04x | %d' % (i, numframes, of[0], of[1]))
		self.ofs[shapenum][2] = 1
		shape.setnumframes(numframes)
		shape.setfofs(of[0])
		shape.frame_read(framenum)
		self.shapes.append(shape)
		return list_getlast(self.shapes)
	
	def getshapename(self, shapenum):
		if(shapenum >= 0 and shapenum < self.numshapes):
			return self.shapenames[shapenum]
		return None
	
	def getshapeTFA(self, shapenum):
		if(shapenum >= 0 and shapenum < self.numshapes):
			return self.shapetfas[shapenum]
		return None


class u7shape():
	def __init__(self,shapenum,framenum=None):
		self.index = shapenum
		self.frames = []
		self.framexy = []
		self.frameofs = []
		self.framepxo = []
		self.framespace = []
		self.frame_read(framenum)
		self.numframes = None
		self.fofs = None
		
	def writeFrameInfo(self,framenum,path):
		out = file_open_out(path,0)
		if(out==None):
			return
		out.write('1,1,1')
		out.close
		
	def frameinfo_read(self,framenum,path):
		#inf = openInFile(path)
		if(framenum>=len(self.framespace)):
			#print('framenum is larger than list (%d vs %d) ? %s' % (framenum, len(self.framespace),path))
			diff = (framenum + 1) - len(self.framespace) 
			#print('diff is %d' % (diff))
			for i in range(0,diff):
				self.frames.append(None)
				self.framexy.append(None)
				self.frameofs.append(None)
				self.framepxo.append(None)
				self.framespace.append(None)
				print('Added %d' % (i))
		return
		if(inf==None):
			self.framespace[framenum] = [1,1,1]
			self.writeFrameInfo(framenum,path)
			return
		self.framespace[framenum] = [1,1,1]
		lines = inf.readlines()
		vals = lines[0].split(',')
		i = 0
		for val in vals:
			print('[%s]' % (val))
			self.framespace[framenum][i] = int(val)
			i += 1

	def frame_read(self, framenum):
		if framenum is None:
			return
		for i in range(len(self.frames), framenum+1):
			self.frames.append(None)
			self.framexy.append(None)
			self.frameofs.append(None)
			self.framepxo.append(None)
			self.framespace.append(None)
		#print('shape(%d) framenum(%d) read!' % (self.index, framenum))
		if self.frames[framenum] is not None:
			return
		self.frames[framenum] = 'shape%03x_%02d' % (self.index, framenum)
		imgpath = 'img_out/%s.png' % (self.frames[framenum])
		infopath = 'data/%s.info.txt' % (self.frames[framenum])
		self.frameinfo_read(framenum, infopath)
		
		box = getimagesize(imgpath)
		if box is not None:
			if self.framexy[framenum] is None and box is not None:
				self.framexy[framenum] = [box[0], box[1]]
				#self.frameofs[framenum] = [0,0]
			#if(self.framexy[framenum][0]!=8):
			#	if(perfect != True):
			#		print('img_out/%s.png' % (self.frames[framenum]))
			ImageOperation('selsquare %s %s 0 0 %d %d cm 232 0 4' % (self.frames[framenum], imgpath, self.framexy[framenum][0], self.framexy[framenum][1]))
			if box[0] != 8:
				#print('shape(%d) framenum(%d) box(%s)!' % (self.index, framenum, str(box)))
				if self.framepxo[framenum] is not None:
					#print('shape(%d) framenum(%d) pxo(%s)!' % (self.index, framenum, str(self.framepxo[framenum])))
					sel_max = getselsize(self.frames[framenum])
					#print('img size! %s versus %s' % (str(box), str(sel_max)))
					pofs = [None, None]
					i = 0
					sel_max[i] -= 8
					if sel_max[i] < 0:
						print('selsize was less than 8!')
						sel_max[i] = 0
					pofs[i] = self.framexy[framenum][i] - sel_max[i] + self.framepxo[framenum][0]
					i = 1
					sel_max[i] -= 8
					if sel_max[i] < 0:
						print('selsize was less than 0!')
						sel_max[i] = 0
					pofs[i] = self.framexy[framenum][i] - sel_max[i] + self.framepxo[framenum][3]
					#	pofs[i] = self.framexy[framenum][i] - sel_max[i] + self.framepxo[framenum][i]
					self.setFrameOfs(framenum,pofs)
					self.framepxo[framenum] = None
				else:
					#print('shape(%d) framenum(%d) no pxo!' % (self.index, framenum))
					sel_max = getselsize(self.frames[framenum])
					print('img size! %s versus %s' % (str(box), str(sel_max)))
					pofs = [None,None]
					for i in range(0,2):
						print(len(sel_max))
						if sel_max[i] is None:
							print(sel_max[i])
							sel_max[i] = 9
						sel_max[i] -= 8
						pofs[i] = self.framexy[framenum][i] - sel_max[i]
					self.setFrameOfs(framenum,pofs)
			#if(self.frameofs[framenum][0] == 0):
			#	max = getselsize(self.frames[framenum])
			#	for i in range(0,2):
			#		max[i] -= 8
			#		self.frameofs[framenum][i] = self.framexy[framenum][i] - max[i]
			#	#if(max[0] != 0):
			#	#	print(max)
			#if(self.frameofs[framenum][0] != 0 and self.framexy[framenum][0] != 8):
			#	if(perfect != True):
			#		print(self.frameofs[framenum])
			#ImageOperation('selsquare %s %s 0 0 %d %d 232 0 4' % (self.frames[framenum],imgpath,self.framexy[framenum][0],self.framexy[framenum][1]))
			#ImageOperation('selremovecolor %s 232 0 4' % (self.frames[framenum]))

	def drawSize(self,framenum,pxx,pxy):
		size = self.framexy[framenum]
		ofs = self.frameofs[framenum]
		pxo = self.framepxo[framenum]
		rvals = [[pxx,pxy],None]
		if(size == None):
			return rvals
		if(size[0]==8):
			rvals[1] = [8,8]
			return rvals
		if(ofs == None):
			print('shape(%d) framenum(%d) no ofs?' % (self.index, framenum))
			return rvals
		if(self.frames != None):
			offset = [pxx-((size[0]-ofs[0])*2), pxy-((size[1]-ofs[1])*2)]
			if(pxo!=None):
				offset[0] += pxo[0]*2
				offset[1] += pxo[3]*2
			rvals[0] = [offset[0],offset[1]]
			rvals[1] = [size[0],size[1]]
		return rvals

	def blitFrame(self,framenum,viewport,pxx,pxy,mini=False):
		print(framenum)
		size = self.framexy[framenum]
		ofs = self.frameofs[framenum]
		pxo = self.framepxo[framenum]
		#if(ofs==None):
		#	ofs = self.framepxo[framenum]
		#print('pixel %d, %d' % (pxx, pxy))
		if(mini):
			if(size[0]==8):
				ImageOperation('selappend %s u7world %d %d 0 0 1 1' % (self.frames[framenum], pxx, pxy))
			return
		if(size != None):
			if(size[0]==8):
				ImageOperation('selappend %s u7world %d %d' % (self.frames[framenum], pxx, pxy))
				return True
			else:
				#pass
				#print(self.frames[framenum])
				if(ofs == None):
					print('shape(%d) framenum(%d) no ofs?' % (self.index, framenum))
					return False
				if(self.frames != None):
					#ImageOperation('selappend %s u7world %d %d 0 0 %d %d sc 2' % (self.frames[framenum], pxx-((size[0]-ofs[0])*2), pxy-((size[1]-ofs[1])*2), size[0], size[1]))
					offset = [pxx-((size[0]-ofs[0])*2), pxy-((size[1]-ofs[1])*2)]
					if(pxo!=None):
						#if(self.index==453):
						#	print(len(offset))
						#	print(len(pxo))
						#	print(pxo)
						offset[0] += pxo[0]*2
						offset[1] += pxo[3]*2
					#pstart = [offset[0],offset[1]]
					#pstop = [pstart[0]+size[0],pstart[1]+size[1]]
					p0 = [offset[0],offset[1]]
					p1 = [offset[0]+size[0],offset[1]]
					p2 = [offset[0]+size[0],offset[1]+size[1]]
					p3 = [offset[0],offset[1]+size[1]]
					pointsx = [0,0]
					pointsy = [0,0]
					if(p0[0]<0):
						pointsx[0] += 1
					if(p1[0]<0):
						pointsx[0] += 1
					if(p2[0]<0):
						pointsx[0] += 1
					if(p3[0]<0):
						pointsx[0] += 1
					if(p0[0]>=viewport[0]):
						pointsx[1] += 1
					if(p1[0]>=viewport[0]):
						pointsx[1] += 1
					if(p2[0]>=viewport[0]):
						pointsx[1] += 1
					if(p3[0]>=viewport[0]):
						pointsx[1] += 1
					if(p0[1]<0):
						pointsy[0] += 1
					if(p1[1]<0):
						pointsy[0] += 1
					if(p2[1]<0):
						pointsy[0] += 1
					if(p3[1]<0):
						pointsy[0] += 1
					if(p0[1]>=viewport[1]):
						pointsy[1] += 1
					if(p1[1]>=viewport[1]):
						pointsy[1] += 1
					if(p2[1]>=viewport[1]):
						pointsy[1] += 1
					if(p3[1]>=viewport[1]):
						pointsy[1] += 1
					pval = 0
					xval = pointsx[1] - pointsx[0]
					if(xval<0):
						xval *= -1
					yval = pointsy[1] - pointsy[0]
					if(yval<0):
						yval *= -1
					pval = xval + yval
					#print(pval)
					if(xval==4 and yval==4):
						#print('!frame blit, shape %d framenum %d ofs(%d %d) sz(%d %d) (%d %d)' % (self.index, framenum, offset[0], offset[1], size[0], size[1], xval, yval))
						#print('  p0: %d %d' % (p0[0],p0[1]))
						#print('  p1: %d %d' % (p1[0],p1[1]))
						#print('  p2: %d %d' % (p2[0],p2[1]))
						#print('  p3: %d %d' % (p3[0],p3[1]))
						return False
					elif(xval>=4 or yval>=4):
						#print('!frame blit, shape %d framenum %d ofs(%d %d) sz(%d %d) (%d %d)' % (self.index, framenum, offset[0], offset[1], size[0], size[1], xval, yval))
						#print('  p0: %d %d' % (p0[0],p0[1]))
						#print('  p1: %d %d' % (p1[0],p1[1]))
						#print('  p2: %d %d' % (p2[0],p2[1]))
						#print('  p3: %d %d' % (p3[0],p3[1]))
						return False
					print('frame blit, shape %d framenum %d ofs(%d %d) sz(%d %d)' % (self.index, framenum, offset[0], offset[1], size[0], size[1]))
					#if(self.index==453):
					ImageOperation('selappend %s u7world of %d %d sc 2' % (self.frames[framenum], offset[0], offset[1]))
					return True
					#ImageOperation('selappend %s u7world of %d %d' % (self.frames[framenum], pxx-((size[0]-ofs[0])*2), pxy-((size[1]-ofs[1])*2)))
				#ImageOperation('selappend %s u7world of %d %d' % (self.frames[framenum], pxx-((size[0]-ofs[0])*2), pxy-((size[1]-ofs[1])*2)))
				return False
		else:
			return False
			#ImageOperation('selappend %s u7world %d %d' % (self.frames[framenum], pxx, pxy))

	def setFrameSize(self,framenum,size):
		for i in range(len(self.frames),framenum+1):
			self.frames.append(None)
			self.framexy.append(None)
			self.frameofs.append(None)
			self.framepxo.append(None)
		self.framexy[framenum] = size

	def setFrameOfs(self,framenum,ofs):
		for i in range(len(self.frames),framenum+1):
			self.frames.append(None)
			self.framexy.append(None)
			self.frameofs.append(None)
			self.framepxo.append(None)
		#print('setting shape %03x frame %d ofs %s' % (self.index,framenum,ofs))
		self.frameofs[framenum] = ofs

	def setFramePXO(self,framenum,ofs):
		for i in range(len(self.frames),framenum+1):
			self.frames.append(None)
			self.framexy.append(None)
			self.frameofs.append(None)
			self.framepxo.append(None)
		#print('setting shape %03x frame %d ofs %s' % (self.index,framenum,ofs))
		self.framepxo[framenum] = ofs

	def setnumframes(self,numframes):
		self.numframes = numframes

	def setfofs(self,fofs):
		self.fofs = fofs


def dumpshapes():
	global shapes
	out = file_open_out('shapeslist.txt',0)
	imgdump = False
	for shape in shapes:
		for i in range(0,len(shape.frames)):
			frame = shape.frames[i]
			size = shape.framexy[i]
			ofs = shape.frameofs[i]
			if(size!=None):
				nomus = 'img_out/shape%03x_%02d.png' % (shape.index,i)
				if(ofs!=None):
					string = '%s,%d,%d,%d,%d\n' % (nomus,size[0],size[1],ofs[0],ofs[1])
					out.write(string)
				else:
					pass
					#print' unable to dump shape%03x_%02d ofs not loaded.' % (shape.index,i)
			if(frame!=None):
				if(imgdump):
					ImageOperation('selsave %s %s.png' % (frame, frame))
			#	if(size!=None):
			#		print('shape,%d,%d,size,%d,%d' % (shape.index,i,size[0],size[1]))
			#	else:
			#		pass
					#print('shape,%d,%d,size,-1,-1' % (shape.index,i))
	out.close()


def shape_frame_get(i, j):
	pass


def readshapesizes():
	inf = file_open_in('shapesize.txt')
	if(inf == None):
		return
	lines = inf.readlines()
	for line in lines:
		line = str_strip_newline(line)
		vals = line.split(',')
		#print(vals)
		if(len(vals)==5):
			svals = str_strip_start(str_strip_end(vals[0],'.png'),'img_out/shape').split('_')
			#print(svals)
			if(len(svals)==2):
				#print(svals)
				shapenum = int(svals[0],16)
				framenum = int(svals[1])
				width = int(vals[1])
				height = int(vals[2])
				ofsx = int(vals[3])
				ofsy = int(vals[4])
				shape = shape_frame_get(shapenum,None)
				shape.setFrameSize(framenum,[width,height])
				#shape.setFrameOfs(framenum,[ofsx,ofsy])


def readshapes(path):
	inf = file_open_in_b(path)
	if(inf==None):
		print('	ERR: unable to open %s' % (path))
		return None
	filesize = os.stat(path)[6]
	print('	size of %s: %d bytes' % (path, filesize))
	#print(filesize)
		#numschunks = filesize / 512
		#print(numschunks)
	inf.seek(0x54)
	intformat = "<1I"
	ofsformat = "<2I"
	ihdformat = "<4h"
	ofs = []
	tmpdata = inf.read(struct.calcsize(intformat))
	data = struct.unpack(intformat, tmpdata)
	numshapes = int(data[0])
	inf.seek(0x80)
	for i in range(0,numshapes):
		inf.seek(0x80+(i*8))
		tmpdata = inf.read(struct.calcsize(ofsformat))
		data = struct.unpack(ofsformat, tmpdata)
		ofs.append([data[0],data[1]])
		#for i in range(0,numschunks):
		#	tmpdata = inf.read(struct.calcsize(chunkFormat))
		#	data = struct.unpack(chunkFormat, tmpdata)
		#	self.schunk.append(data)
		#for i in range(0,self.numschunks):
		#	print('Schunk %d - %d' % (i,len(self.schunk[i])))
		#	scy = 256 * (i/12)
		#	scx = 256 * (i%12)
		#	#for val in self.schunk[i]:
		#	#	print(val)
		#	print('  %d, %d' % (scx, scy))
		#for schunk in self.schunks:
		#	print('Schunk: %d' % (len(schunk)))

	inf.seek(ofs[150][0])
	#print(ofs[150][0])
	#return
	print('	reading shapes offsets')
	for i in range(150,numshapes):
		#print(i)
		inf.seek(ofs[i][0])
		keepos = ofs[i][0]
		#print(keepos)
		tmpdata = inf.read(struct.calcsize(ofsformat))
		data = struct.unpack(ofsformat, tmpdata)
		if(i<numshapes-1):
			ofs[i+1][0] = data[0]+keepos
		ofs[i+0][1] = data[1]
		#print('%d %08x' % (i, ofs[i][0]))
		
	print('	reading shape positioning data')
	i = 0
	for of in ofs:
		numframes = of[1] / 64
		shape = shape_frame_get(i,None)
		if(i>=150):
			numframes = (of[1]-4)/4
			for j in range(0,numframes):
				inf.seek(of[0]+4+(j*4))
				tmpdata = inf.read(struct.calcsize(intformat))
				data = struct.unpack(intformat, tmpdata)
				frameofs = data[0]+of[0]
				#print('%03x_%02d:0x%06x' % (i,j,frameofs))
				inf.seek(frameofs)
				tmpdata = inf.read(struct.calcsize(ihdformat))
				data = struct.unpack(ihdformat, tmpdata)
				xright = data[0]
				xleft = data[1]
				yabove = data[2]
				ybelow = data[3]
				pofs = [xright,ybelow]
				#for val in data:
				#	print('shape%03x_%02d: val %d' % (shape.index,j,val))
				#print(pofs)
				#print('readshapes')
				shape.setFramePXO(j,pofs)
				#shape.setFrameOfs(j,pofs)
				#size = [data[4],data[5]]
				#datalen = data[6]
				#print('%03x_%02d: ofs %s' % (i,j,pofs))
				#print('%03x_%02d: size %s' % (i,j,size))
				#print('%03x_%02d: fsiz %s' % (i,j,datalen))
				#for val in data:
				#	print('%03x_%02d:%d' % (i,j,val))
		else:
			for j in range(0,numframes):
				pofs = [8,8]
				shape.setFrameOfs(j,pofs)
		#print('%03x (%02d): %04x | %d' % (i, numframes, of[0], of[1]))
		shape.setnumframes(numframes)
		shape.setfofs(of[0])
		i+=1
	inf.close()
	
	print('	converting shapes to HD')
	for i in range(128,150):
		shape = shape_frame_get(i,None)
		for j in range(0,shape.numframes):
			#shape = shape_frame_get(i,j)
			nomus = 'img_out/shape%03x_%02d.png' % (shape.index,j)
			targus = 'hd/shape%03x_%02d.png' % (shape.index,j)
			if(file_exists(nomus)==True and file_exists(targus)==False):
				ImageOperation('resize -i %s -o %s -w 16 -m bicubic' % (nomus, targus))
			else:
				if(file_exists(nomus)!=True):
					print('shape image %s not exist!' % (nomus))

	print('	writing information to ./debug.shapes.txt')
	out = file_open_out('debug.shapes.txt',0)
	for shape in shapes:
		out.write('%03x,0x%06x,%d\n' % (shape.index,shape.fofs,shape.numframes))
	out.close()
	return
