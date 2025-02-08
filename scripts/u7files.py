# u7files.py
import gc
import time
import os
import sys
import shutil
import psutil
import struct
import glob
from u7shapes import *
from dotenv import load_dotenv

from plebwerks import FileWerks, stringStripStart, stringStripEnd, stringMatch, stringMatchStart, \
    stringMatchEnd, stringClean, listAdd, listContains, yamlRead, yamlWrite, timeNow, \
    openTextFileWrite, dictGetKeys, dictGetValue, openBinaryFileWrite, stringToFile, \
    stringSplitNoEmpty, pathAssertExists, openBinaryFileRead

from wicon.wudanicon import ImageOperation, adddot, addline, file_exists, file_is_image, getimagesize, VariableObject, selobj_retrieve_data, get_var, PrettyLine
from wicon.selection import selection_get, SelCoord
from wicon.font import FontObject
from wicon.handy import file_open_in, file_open_out
from wicon.common import line_to_vars, str_strip_newline, str_strip_end, all_true, i_list_add, i_on_list
from wicon.q_math import *

from collections import OrderedDict

class GarbageCollector():
    def __init__(self):
        self.lastrun = int(time.time())

    def checkrun(self):
        now = int(time.time())
        if (now - self.lastrun) > 30:
            gc.collect()
            self.lastrun = now

garbageman = GarbageCollector()


def show_sizeof(x, level=0):
    print("\t" * level, x.__class__, sys.getsizeof(x), x)
    if hasattr(x, '__iter__'):
        if hasattr(x, 'items'):
            for xx in x.items():
                show_sizeof(xx, level + 1)
        else:
            for xx in x:
                show_sizeof(xx, level + 1)


def current_mem_usage():
    process = psutil.Process(os.getpid())
    return int(process.memory_info().rss)


def barf_mem_usage():
    global memusage
    newmemusage = current_mem_usage()
    deltamemusage = newmemusage - memusage
    memusage = newmemusage
    print('MEM: {0}KB DELTA: {1}KB'.format(in_kilobytes(memusage), in_kilobytes(deltamemusage)))


def in_kilobytes(val):
    return '{0:0.03f}'.format(float(val)/1024.0)


def bounds_check(rvals, box):
    start = rvals[0]
    size = rvals[1]
    size[0] = int(size[0] * 2)
    size[1] = int(size[1] * 2)
    #print(box)
    p = [start, None, None, None]
    p[1] = [start[0]+size[0], start[1]]
    p[2] = [start[0]+size[0], start[1]+size[1]]
    p[3] = [start[0], start[1]+size[1]]
    for i in range(0, 4):
        rel = [p[i][0]-box[0], p[i][1]-box[1]]
        if (p[i][0] >= 0) and (rel[0] < 0):
            if(p[i][1] >= 0) and (rel[1] < 0):
                return True
        #rel = [start,None,None,None]
        #rel[1] = [p[i][0]-box[0],p[i][1]]
        #rel[2] = [p[i][0]-box[0],p[i][1]-box[1]]
        #rel[3] = [p[i][0],p[i][1]-box[1]]
    #for pr in rel:
    #    print(pr)
    #print('----')
    return False
    #start is already relative of viewport


def drawbox(selname, start, size, color=None):
    if color is None:
        color = [0, 0, 0, 255]
    start1 = [start[0], start[1]]
    start2 = [start[0]+size[0]-1, start[1]+1]
    start3 = [start[0], start[1]+1]
    start4 = [start[0], start[1]+size[1]-1]
    lenx = size[0]
    leny = size[1]-2
    for i in range(0, lenx):
        ImageOperation('seladdmark %s %d %d %d %d %d %d 0' % (selname, start1[0]+i, start1[1], color[0], color[1], color[2], color[3]))
    for i in range(0,leny):
        ImageOperation('seladdmark %s %d %d %d %d %d %d 0' % (selname, start2[0],start2[1]+i,color[0],color[1],color[2],color[3]))
    for i in range(0,leny):
        ImageOperation('seladdmark %s %d %d %d %d %d %d 0' % (selname, start3[0],start3[1]+i,color[0],color[1],color[2],color[3]))
    for i in range(0,lenx):
        ImageOperation('seladdmark %s %d %d %d %d %d %d 0' % (selname, start4[0]+i,start4[1],color[0],color[1],color[2],color[3]))


def dumpu7world():
    i = 0
    while i < 10000:
        path = 'out%04d.png' % i
        if file_exists(path) is False:
            ImageOperation('selsave u7world %s' % path)
            print('saved world as %s' % path)
            return
        i += 1


def draw_sceneobject(sobjs, index):
    print('  draw_sceneobject -> Start')
    so = None
    if isinstance(index, int):
        print('  draw_sceneobject -> index INT {0}'.format(index))
        if index in range(0, len(sobjs)):
            so = sobjs[index]
        else:
            print('  draw_sceneobject -> requested index {0} is not in range {1}'.format(index, len(sobjs)))
    else:
        print('  draw_sceneobject -> index UNK {0}'.format(index))
    if so is None:
        return
    print('  draw_sceneobject -> obj[{0}] - draw'.format(index))
    if so.drawn is True:
        return
    print('  draw_sceneobject -> DRAW OBJECT {0}'.format(index))
    ImageOperation('selappend %s u7world of %d %d sc 2' % (so.sf.frames[so.framenum], so.px[0], so.px[1]))
    #print('obj[%d] - draw' % (doj[0]))
    #print(so.dump())
    so.drawn = True
    for dop in so.postdraws:
        print('  draw_sceneobject -> postdraws')
        draw_sceneobject(sobjs, dop)


class U7SceneObject():
    def __init__(self, shapenum, framenum, lpos, pxofs, chunkobj, index):
        global shapesman
        self.name = shapesman.getshapename(shapenum)
        self.tfa = shapesman.getshapeTFA(shapenum)
        self.shapenum = shapenum
        self.framenum = framenum
        self.chunkobj = chunkobj
        self.drawn = False
        self.postdrawn = False
        self.parent = None
        self.postdraws = []
        self.lpos = lpos
        self.space = [1, 1, 1]
        self.debug = False
        self.sf = shapesman.shape_frame_get(self.shapenum, self.framenum)
        self.space = self.sf.framespace[self.framenum]
        self.drawval = None
        self.index = index
        self.px = pxofs
        self.size = [None, None]
        self.zscore = None
        xval = (self.tfa[2] & 7) + 1
        yval = ((self.tfa[2] & 56) >> 3) + 1
        zval = (self.tfa[0] & 224) >> 5
        self.space = [xval, yval, zval]

    def drawpos(self,rvals):
        self.px = rvals[0]
        self.size = rvals[1]
        p0 = [self.px[0] + self.size[0], self.px[1] + self.size[1]]
        #if(p0[0]<0):
        #    return
        #if(p0[1]<0):
        #    return
        #self.zscore = p0[0] * p0[0] + p0[1] * p0[1]
        self.zscore = p0[1]
        
    def dump(self):
        line = ''
        tfastr = ''
        tfavals = []
        for i in range(0, 3):
            tfavals.append((self.tfa[i] & 128)>>7)
            tfavals.append((self.tfa[i] & 64)>>6)
            tfavals.append((self.tfa[i] & 32)>>5)
            tfavals.append((self.tfa[i] & 16)>>4)
            tfavals.append((self.tfa[i] & 8)>>3)
            tfavals.append((self.tfa[i] & 4)>>2)
            tfavals.append((self.tfa[i] & 2)>>1)
            tfavals.append(self.tfa[i] & 1)
        for i in range(0,8):
            tfastr += '%s' % (str(tfavals[i]))
        tfastr += '  '
        for i in range(8,16):
            tfastr += '%s' % (str(tfavals[i]))
        tfastr += '  '
        for i in range(16,24):
            tfastr += '%s' % (str(tfavals[i]))
        #line += 'obj[%d] - %s(%03x_%02d) parent(%s)- [%d,%d,%d] [%d %d %d] px[%d,%d] TFA[%s]' % (self.index,self.name,self.shapenum,self.framenum,self.lpos[0],self.lpos[1],self.lpos[2],self.space[0],self.space[1],self.space[2],self.px[0],self.px[1],tfastr)
        if self.zscore is not None:
            line += ' size[%s,%s] z[%s]' % (str(self.size[0]), str(self.size[1]), str(self.zscore))
        return line


class U7WorldObject():
    def __init__(self, shapenum, framenum, lpos, data):
        global shapesman
        self.debug = False
        self.name = shapesman.getshapename(shapenum)
        self.shapenum = shapenum
        self.framenum = framenum
        self.lpos = lpos
        self.debug = False
        #if(self.shapenum == 293):
        #    self.debug = True
        #if(self.shapenum == 849):
        #    self.debug = True
        #if(self.shapenum==282 and self.framenum==2):
        #    self.debug = True
        #elif(self.shapenum==820 and self.framenum==2):
        #    self.debug = True
        #if(self.debug):
        #    print('%s: %d %d %s' % (self.name, self.shapenum, self.framenum, str(self.lpos)))
        self.cpos = [-1,-1]
        self.oflag = None
        self.oval = None
        self.qflag = None
        self.quality = None
        self.container = False
        self.egg = False
        self.contents = []
        self.exclude = shapeexclude(self.shapenum)
        if len(data) == 1:
            self.exclude = True
        if len(data) > 2:
            self.cpos = [data[1] >> 4, data[2] >> 4]
        if len(data) == 7:
            #self.exclude = True
            self.qflag = data[6] >> 7
            self.quality = data[6] & 127
            #val = data[5]&15
            #if(val==6):
            #    self.exclude = True
        if len(data) == 13:
            #print('LEN DATA %d' % len(data))
            self.oflag = data[7] >> 7
            if self.oflag == 1:
                self.container = True
                self.oval = data[7] & 127
            if int(data[12]) == 0:
                self.container = True
            if self.shapenum == 275:
                self.container = False
            #elif int(data[12]) == 1:
            #    self.egg = True
            #else:
            #    print('LAST BYTE: %d' % int(data[12]))
            #if self.egg is True:
            #    print(' is EGG')
            #if self.container is True:
            #    print(' is CONTAINER')
        if lpos[2] >= 5:
            self.exclude = True
        if len(data) > 1:
            print('U7WorldObject %d POS %d %d %d' % (len(data), lpos[0], lpos[1], lpos[2]))
            if self.exclude is True:
                print('U7WorldObject: EXCLUDE %s,%d,%s' % (self.name, self.shapenum, str(self.oval)))
        if self.oval is not None:
            if self.exclude is False:
                print('U7WorldObject: %s,%d,%d' % (self.name, self.shapenum, self.oval))
                if self.egg is True:
                    print(' is EGG')
                if self.container is True:
                    print(' is CONTAINER')
        else:
            if self.exclude is False:
                print('U7WorldObject: %s,%d frame %d' % (self.name, self.shapenum, self.framenum))
        self.data = data


def data_get_string(data, offset, length):
    if offset + length > len(data):
        return ''
    line = ''
    for i in range(0, length):
        byte = data[offset+i]
        if byte != 0:
            line += chr(byte)
    return line


def data_get_short(data, offset):
    length = 2
    if offset + length > len(data):
        return 0
    a = int(data[offset])
    b = int(data[offset+1])
    return (b << 8) + a


def data_get_word(data, offset):
    length = 4
    if offset + length > len(data):
        return 0
    a = int(data[offset])
    b = int(data[offset+1])
    c = int(data[offset+2])
    d = int(data[offset+3])
    return (d << 24) + (c << 16) + (b << 8) + a


def bytestr_to_charstr(data):
    line = ''
    for i in range(0, len(data)):
        #line += '{0}'.format(data[i].decode("utf-8"))
        if data[i] >= 32:
            if data[i] < 127:
                line += '{0}'.format(chr(data[i]))
            else:
                line += '.'
        else:
            line += '.'
    return line


def bytestr_to_intstr(data):
    line = ''
    for i in range(0, len(data)):
        line += '%03d ' % data[i]
    return str_strip_end(line, ' ')


def bytestr_to_hexstr(data):
    line = ''
    for i in range(0, len(data)):
        line += '%02x ' % data[i]
    return str_strip_end(line, ' ')


def bytestr_to_binstr(data):
    line = ''
    for i in range(0, len(data)):
        bstr = ''
        byte = data[i]
        pwr = 128
        for j in range(0, 8):
            if byte >= pwr:
                bstr += '1'
                byte -= pwr
            else:
                bstr += '0'
            pwr /= 2

        line += '%s ' % bstr
    return str_strip_end(line, ' ')


def ireg_item_parse(data):
    global shapesman
    tidbit = ''
    dlen = len(data)
    lpos = [0, 0, 0]
    shapenum = data[3] + 256*(data[4] & 3)
    framenum = (data[4] >> 2)
    cpos = [data[1] >> 4, data[2] >> 4]
    cnum = (cpos[1]*16) + cpos[0]
    quantity = data[6]
    if dlen == 11 or dlen == 7:
        lpos = [data[1] & 15, data[2] & 15, data[5] >> 4]
    elif dlen == 13:
        lpos = [data[1] & 15, data[2] & 15, data[10] >> 4]
    name = shapesman.getshapename(shapenum)
    return [name, shapenum, framenum, quantity, cnum, cpos, lpos]


class U7ireg():
    def __init__(self, path, index):
        self.path = path
        self.index = index
        self.worldpos = [(self.index % 12) * 256, ((self.index - (self.index % 12))/12) * 256]
        self.cregs = []
        global shapesman
        for i in range(0, 257):
            self.cregs.append([])
        print('U7IREG Object: %s' % self.path)
        self.filesize = os.stat(self.path)[6]
        self.ireg_read()
        self.ifix_read()
        return
        #print('ireg: %s (%d bytes)' % (self.path, self.filesize))
        inf = file_open_in_b(self.path)
        data = []
        for i in range(0, self.filesize):
            data.append(struct.unpack("B", inf.read(1))[0])
        inf.close()
        self.data = data
        container = None
        i = 0
        itemnum = 0
        cnum = 0
        in_item = False
        out_item_ofs = 0
        out_item_str_ct = 0
        out_item_str = ''
        zero_ct = 0
        while i < len(data):
            #print(cnum)
            if cnum >= 256:
                print('err cnum in %s' % path)
                cnum = 256
            item = None
            #print('IREG OFS %02x VAL %d (%02x)' % (i, data[i], data[i]))
            if data[i] == 0:
                if in_item is True:
                    in_item = False
                    out_item_ofs = i
                if in_item is False:
                    out_item_str_ct += 1
                    out_item_str += '%02x ' % (data[i])
                container = None
                zero_ct += 1
                i += 1
            elif data[i] == 10:
                if in_item is False:
                    print('OUT ITEM STR %04x: (%d) %s' % (out_item_ofs, out_item_str_ct, out_item_str))
                    in_item = True
                    out_item_str = ''
                    out_item_str_ct = 0
                print('DATA IS 10')
                item_str = '%02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x' % (data[i], data[i+1], data[i+2], data[i+3], data[i+4], data[i+5], data[i+6], data[i+7], data[i+8], data[i+9], data[i+10])
                print('    ITEM STR %04x: (%d) %s' % (i, 11, item_str))
                shapenum = data[i+3] + 256*(data[i+4] & 3)
                framenum = (data[i+4] >> 2)
                cpos = [data[i+1] >> 4, data[i+2] >> 4]
                cnum = (cpos[1]*16) + cpos[0]
                lpos = [data[i+1] & 15, data[i+2] & 15, data[i+5] >> 4]
                self.cregs[cnum].append(U7WorldObject(shapenum, framenum, lpos, data[i:i+7]))
                item = list_getlast(self.cregs[cnum])
                if item.container is not False:
                    container = item
                #container = None
                print('CHUNK NUM %d - zero ct %d' % (cnum, zero_ct))
                itemnum += 1
                i += 11
            elif data[i] == 6:
                if in_item is False:
                    print('OUT ITEM STR %04x: (%d) %s' % (out_item_ofs, out_item_str_ct, out_item_str))
                    in_item = True
                    out_item_str = ''
                    out_item_str_ct = 0
                print('DATA IS 6')
                item_str = '%02x %02x %02x %02x %02x %02x %02x' % (data[i], data[i+1], data[i+2], data[i+3], data[i+4], data[i+5], data[i+6])
                print('    ITEM STR %04x: (%d) %s' % (i, 7, item_str))
                #print('%s' % (str(data[i:i+7])))
                shapenum = data[i+3] + 256*(data[i+4] & 3)
                framenum = (data[i+4] >> 2)
                if container is None:
                    print('not container')
                    cpos = [data[i+1] >> 4, data[i+2] >> 4]
                    cnum = (cpos[1]*16) + cpos[0]
                    #cnum = 0
                    lpos = [data[i+1] & 15, data[i+2] & 15, data[i+5] >> 4]
                    self.cregs[cnum].append(U7WorldObject(shapenum, framenum, lpos, data[i:i+7]))
                    item = list_getlast(self.cregs[cnum])
                    if item.container is not False:
                        container = item
                else:
                    print('yes container')
                    cpos = container.cpos
                    lpos = container.lpos
                    self.cregs[cnum].append(U7WorldObject(shapenum, framenum, lpos, data[i:i+7]))
                    item = list_getlast(self.cregs[cnum])
                    if item.container is not False:
                        container = item
                print('CHUNK NUM %d - zero ct %d' % (cnum, zero_ct))
                itemnum += 1
                i += 7
            elif data[i] == 12:
                if in_item is False:
                    print('OUT ITEM STR %04x: (%d) %s' % (out_item_ofs, out_item_str_ct, out_item_str))
                    in_item = True
                    out_item_str = ''
                    out_item_str_ct = 0
                print('DATA IS 12')
                item_str = '%02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x' % (data[i], data[i+1], data[i+2], data[i+3], data[i+4], data[i+5], data[i+6], data[i+7], data[i+8], data[i+9], data[i+10], data[i+11], data[i+12])
                print('    ITEM STR %04x: (%d) %s' % (i, 13, item_str))
                #print('%s' % (str(data[i:i+13])))
                shapenum = data[i+3] + 256*(data[i+4] & 3)
                framenum = (data[i+4] >> 2)
                cpos = [data[i+1] >> 4, data[i+2] >> 4]
                cnum = (cpos[1]*16) + cpos[0]
                #cnum = 0
                #out.write('<tr>\n<td>\nchunk:\n</td>\n<td>%s\n</td>\n</tr>\n' % (str(pos)))
                lpos = [data[i+1] & 15, data[i+2] & 15, data[i+10] >> 4]
                self.cregs[cnum].append(U7WorldObject(shapenum, framenum, lpos, data[i:i+13]))
                item = list_getlast(self.cregs[cnum])
                if item.container is not False:
                    container = item
                print('CHUNK NUM %d - zero ct %d' % (cnum, zero_ct))
                itemnum += 1
                i += 13
                if container is not None:
                    in_container = True
                    while in_container:
                        if i < len(data):
                            byte = data[i]
                            if byte == 1:
                                print('CONTAINER DATA (%s) CLOSED %02x' % (container.name, data[i]))
                                in_container = False
                                i += 1
                            elif byte == 0:
                                print('CONTAINER DATA (%s) CLOSED %02x' % (container.name, data[i]))
                                in_container = False
                                i += 1
                            elif byte == 10:
                                print('CONTAINER DATA (%s) 10 len!' % container.name)
                                item_str = '%02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x' % (data[i], data[i+1], data[i+2], data[i+3], data[i+4], data[i+5], data[i+6], data[i+7], data[i+8], data[i+9], data[i+10])
                                print('    ITEM STR %04x: (%d) %s' % (i, 11, item_str))
                                shapenum = data[i+3] + 256*(data[i+4] & 3)
                                framenum = (data[i+4] >> 2)
                                cpos = [data[i+1] >> 4, data[i+2] >> 4]
                                cnum = (cpos[1]*16) + cpos[0]
                                lpos = [data[i+1] & 15, data[i+2] & 15, data[i+5] >> 4]
                                self.cregs[cnum].append(U7WorldObject(shapenum, framenum, lpos, data[i:i+7]))
                                i += 11
                            elif byte == 12:
                                print('CONTAINER DATA (%s) 12 len!' % container.name)
                                item_str = '%02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x' % (data[i], data[i+1], data[i+2], data[i+3], data[i+4], data[i+5], data[i+6], data[i+7], data[i+8], data[i+9], data[i+10], data[i+11], data[i+12])
                                print('    ITEM STR %04x: (%d) %s' % (i, 13, item_str))
                                i += 11
                            else:
                                print('CONTAINER DATA (%s) IS %02x' % (container.name, data[i]))
                                i += 1
                        else:
                            in_container = False
                            i += 1

                    container = None
            #elif data[i] == 1:
            #    print('DATA IS 1')
            #    #self.cregs[0].append(U7WorldObject(0, data[i], [0, 0, 0], [data[i]]))
            #    container = None
            #    i += 1
            #elif data[i] == 0:
            #    print('DATA IS 0')
            #    #out.write( ' -> (%d) %d<br>' % (i, data[i]) )
            #    #self.cregs[0].append(U7WorldObject(0, data[i], [0, 0, 0], [data[i]]))
            #    container = None
            #    #cnum += 1
            #    #print('increasing cnum to %d' % (cnum))
            #    i += 1
            else:
                print('DATA IS %02x ???' % data[i])
                if in_item is True:
                    in_item = False
                    out_item_ofs = i
                if in_item is False:
                    out_item_str_ct += 1
                    out_item_str += '%02x ' % (data[i])
                #out.write( ' -> (%d) %d<br>' % (i, data[i]) )
                #self.cregs[0].append(U7WorldObject(0, data[i], [0, 0, 0], [data[i]]))
                container = None
                i += 1
            print('IREG ----')
        print('ZERO CT %d' % zero_ct)
        #self.dump()
        self.ireg_read()
        self.ifix_read()
        return
        #out.close()
        #print('----')
        #for bit in data:
        #    print(bit)

    def ireg_read(self):
        ireg_valid = True

        container = None
        in_item = False

        ireg_path = 'blackgate/STATIC/u7ireg{0:02x}'.format(self.index)
        global shapesman
        #for i in range(0, 257):
        #    ifix_coffs.append(None)
        #    ifix_clens.append(0)
        print('U7IREG Object: %s' % ireg_path)
        ireg_filesize = os.stat(ireg_path)[6]
        print('ireg_read -> IREG: %s (%d bytes)' % (ireg_path, ireg_filesize))
        inf = file_open_in_b(ireg_path)
        data = []
        for i in range(0, ireg_filesize):
            data.append(struct.unpack("B", inf.read(1))[0])
        inf.close()
        cur_chunk = 0
        i = 0
        still_reading = True
        out_item_str_ct = 0
        out_item_str = ''

        while still_reading is True:
            if i >= ireg_filesize:
                still_reading = False
            else:
                if data[i] == 0:
                    ## close out old chunk
                    container = None
                    in_item = False
                    ## new chunk
                    cur_chunk += 1
                    print('ireg_read -> IREG: CHUNK NUMBER %d' % cur_chunk)
                    if out_item_str_ct > 0:
                        print('ireg_read -> iChk[{0}]: UNKNOWN ({1}) {2}'.format(cur_chunk, out_item_str_ct, out_item_str))
                    out_item_str_ct = 0
                    out_item_str = ''
                    i += 1
                elif data[i] == 6:
                    skipper = data[i] + 1
                    if out_item_str_ct > 0:
                        print('ireg_read -> iChk[{0}]: UNKNOWN ({1}) {2}'.format(cur_chunk, out_item_str_ct, out_item_str))
                        out_item_str_ct = 0
                        out_item_str = ''
                    vals = ireg_item_parse(data[i:i+skipper])
                    print('ireg_read -> iChk[{0}]: ITEM LEN({1}): {2}'.format(cur_chunk, data[i], bytestr_to_hexstr(data[i:i+skipper])))
                    print('ireg_read -> iChk[{0}]: BINARY({1})\t{2}'.format(cur_chunk, bytestr_to_binstr(data[i:i+skipper]), vals[0]))
                    print(vals)
                    ## CREGS
                    #[name, shapenum, framenum, quantity, cnum, cpos, lpos]
                    #shapenum = data[i+3] + 256*(data[i+4] & 3)
                    #framenum = (data[i+4] >> 2)
                    #cpos = [data[i+1] >> 4, data[i+2] >> 4]
                    #cnum = (cpos[1]*16) + cpos[0]
                    #lpos = [data[i+1] & 15, data[i+2] & 15, data[i+5] >> 4]
                    self.cregs[cur_chunk].append(U7WorldObject(vals[1], vals[2], vals[6], data[i:i+skipper]))
                    item = list_getlast(self.cregs[cur_chunk])
                    ## END CREGS
                    i += 7
                elif data[i] == 10:
                    skipper = data[i] + 1
                    if out_item_str_ct > 0:
                        print('ireg_read -> iChk[{0}]: UNKNOWN ({1}) {2}'.format(cur_chunk, out_item_str_ct, out_item_str))
                        out_item_str_ct = 0
                        out_item_str = ''
                    vals = ireg_item_parse(data[i:i+skipper])
                    print('ireg_read -> iChk[{0}]: ITEM LEN({1}): {2}'.format(cur_chunk, data[i], bytestr_to_hexstr(data[i:i+skipper])))
                    print('ireg_read -> iChk[{0}]: BINARY({1})\t{2}'.format(cur_chunk, bytestr_to_binstr(data[i:i+skipper]), vals[0]))
                    print(vals)
                    ## CREGS
                    #[name, shapenum, framenum, quantity, cnum, cpos, lpos]
                    #shapenum = data[i+3] + 256*(data[i+4] & 3)
                    #framenum = (data[i+4] >> 2)
                    #cpos = [data[i+1] >> 4, data[i+2] >> 4]
                    #cnum = (cpos[1]*16) + cpos[0]
                    #lpos = [data[i+1] & 15, data[i+2] & 15, data[i+5] >> 4]
                    self.cregs[cur_chunk].append(U7WorldObject(vals[1], vals[2], vals[6], data[i:i+skipper]))
                    item = list_getlast(self.cregs[cur_chunk])
                    ## END CREGS
                    i += skipper
                elif data[i] == 12:
                    skipper = data[i] + 1
                    if out_item_str_ct > 0:
                        print('ireg_read -> iChk[{0}]: UNKNOWN ({1}) {2}'.format(cur_chunk, out_item_str_ct, out_item_str))
                        out_item_str_ct = 0
                        out_item_str = ''
                    vals = ireg_item_parse(data[i:i+skipper])
                    print('ireg_read -> ITEM LEN(%d): %s' % (data[i], bytestr_to_hexstr(data[i:i+skipper])))
                    print('ireg_read -> BINARY(%s)\t%s' % (bytestr_to_binstr(data[i:i+skipper]), vals[0]))
                    print(vals)
                    i += skipper
                else:
                    out_item_str_ct += 1
                    print('ireg_read -> iChk[{0}]: ADD ONE'.format(cur_chunk))
                    out_item_str += '%02x ' % (data[i])
                    i += 1

    def ifix_read(self):
        ifix_valid = True
        ifix_header_str = 'Ultima VII Data File (C) 1992 Origin Inc.'
        ifix_path = 'blackgate/STATIC/U7IFIX%02x' % self.index
        ifix_coffs = []
        ifix_clens = []
        global shapesman
        for i in range(0, 257):
            ifix_coffs.append(None)
            ifix_clens.append(0)
        print('U7IFIX Object: %s' % ifix_path)
        ifix_filesize = os.stat(ifix_path)[6]
        print('IFIX: %s (%d bytes)' % (ifix_path, ifix_filesize))
        inf = file_open_in_b(ifix_path)
        data = []
        for i in range(0, ifix_filesize):
            data.append(struct.unpack("B", inf.read(1))[0])
        inf.close()
        header_shorts = []

        ifix_data = data
        container = None
        i = 0
        itemnum = 0
        cnum = 0
        header_string = data_get_string(ifix_data, 0, 80)
        print('First 80 chars: (%s)' % header_string)
        if str_match(ifix_header_str, header_string):
            print('MATCHES IFIX HEADER')
        else:
            ifix_valid = False

        if ifix_valid is False:
            return

        i += 80
        #while i < len(ifix_data):
        while i < 128:
            ofs = i
            j = data_get_short(ifix_data, ofs)
            header_shorts.append(j)
            i += 2

        chunk_num = 0
        while i < 2176:
            offset = data_get_word(ifix_data, i)
            i += 4
            length = data_get_word(ifix_data, i)
            i += 4
            if offset != 0:
                ifix_coffs[chunk_num] = offset
                ifix_clens[chunk_num] = length
                #print('CHUNK %d offset %04x length %d' % (chunk_num, ifix_coffs[chunk_num], ifix_clens[chunk_num]))
            chunk_num += 1

        chunk_num = 0
        while chunk_num < 256:
            if ifix_coffs[chunk_num] is not None:
                offset = ifix_coffs[chunk_num]
                length = ifix_clens[chunk_num]
                item_ct = length / 4
                item_num = 0
                i = offset
                while i < offset + length:
                    byte = ifix_data[i]
                    cpos = [ifix_data[i] >> 4, ifix_data[i] & 15, ifix_data[i+1] & 15]
                    print('CHUNK %d ITEM %d / %d BYTE 1 OFS %0004x DEC %03d CHAR %s' % (chunk_num, item_num, item_ct, i, byte, chr(byte)))

                    byte = ifix_data[i+1]
                    print('CHUNK %d ITEM %d / %d BYTE 2 OFS %0004x DEC %03d CHAR %s' % (chunk_num, item_num, item_ct, i, byte, chr(byte)))

                    byte = ifix_data[i+2]
                    print('CHUNK %d ITEM %d / %d BYTE 3 OFS %0004x DEC %03d CHAR %s' % (chunk_num, item_num, item_ct, i, byte, chr(byte)))

                    byte = ifix_data[i+3]
                    print('CHUNK %d ITEM %d / %d BYTE 4 OFS %0004x DEC %03d CHAR %s' % (chunk_num, item_num, item_ct, i, byte, chr(byte)))

                    unknown = ifix_data[i+1] >> 4
                    #shapenum = ifix_data[i+2] << 2
                    #shapenum = (data[i+2] << 2) + (data[i+3] & 3)
                    shapenum = data[i+2] + 256*(data[i+3] & 3)
                    framenum = (data[i+3] >> 2)
                    print('CHUNK %d ITEM %d / %d pos %d %d %d' % (chunk_num, item_num, item_ct, cpos[0], cpos[1], cpos[2]))
                    print('CHUNK %d ITEM %d / %d unknown %d shape %d frame %d shape%03x_%d.png' % (chunk_num, item_num, item_ct, unknown, shapenum, framenum, shapenum, framenum))
                    self.cregs[chunk_num].append(U7WorldObject(shapenum, framenum, cpos, data[i:i+4]))
                    item_num += 1
                    i += 4
            chunk_num += 1
    
    def getchunkobjs(self, pos):
        bchunksize = 16 * 16 # self.chunksize * 16
        schunksize = bchunksize * 16
        wchunkwide = schunksize * 12
        schunkxy = [0, 0]
        bchunkxy = [0, 0]
        scxy = [0, 0]
        ipos = [0, 0]
        print('getchunkobjs -> STEP 1')
        wpos = [self.worldpos[0] * 16, self.worldpos[1] * 16]
        for i in range(0, 2):
            if pos[i] < wpos[i]:
                return None
            if pos[i] >= (wpos[i] + schunksize):
                return None
            #if None, wasn't in this superchunk!
            #ipos[i] = (pos[i] - (pos[i] % 16)) / 16
        
        print('getchunkobjs -> STEP 2')
        for i in range(0, 2):
            ipos[i] = pos[i]
            keep = ipos[i] - wpos[i]
            while keep > bchunksize:
                keep -= bchunksize
                bchunkxy[i] += 1
        bchunknum = (bchunkxy[1] * 16) + bchunkxy[0]
        print('getchunkobjs -> STEP 3 {0}'.format(len(self.cregs[bchunknum])))
        return self.cregs[bchunknum]
    
    def dump(self):
        out = file_open_out('u7ireg%04x.html' % self.index, 0)
        j = 0
        while j < len(self.cregs):
            creg = self.cregs[j]
            if len(creg) > 0:
                out.write('CHUNK %d</br>\n' % j)
            for obj in creg:
                if obj.exclude is False:
                    out.write('<table>\n<tr>\n<td colspan="2">\n')
                    if len(obj.data) == 1:
                        if obj.data[0] == 0:
                            out.write('Chunk Closed: ')
                        else:
                            out.write('Statement: ')
                    elif len(obj.data)==7:
                        out.write( 'Normal Object: ' )
                        pos = [self.worldpos[0] + (obj.cpos[0]*16) + obj.lpos[0], self.worldpos[1] + (obj.cpos[1]*16) + obj.lpos[1]]
                        tiny_dot( 'u7world', pos[0], pos[1] )
                    elif(len(obj.data)==13):
                        out.write( 'Special Object: ' )
                    out.write( '%s' % (str(obj.data)) )
                    out.write('</td>\n</tr>\n')
                    
                    out.write('<tr>\n<td colspan="2">\n')
                    if(len(obj.data)==7):
                        for val in obj.data[1:]:
                            num1 = val>>4
                            num2 = val&15
                            out.write( '%02x %02x | ' % (num1, num2) )
                        #val = obj.data[5]&15
                        #out.write( 'deepok ' )
                        #out.write( '%s ' % (str(val)) )
                        out.write( '%s (%d,%d) (%s) (%s) (%s)' % (obj.name, obj.shapenum, obj.framenum, str(obj.cpos), str(obj.lpos), str(obj.quality)) )
                    elif(len(obj.data)==13):
                        for val in obj.data[1:]:
                            num1 = val>>4
                            num2 = val&15
                            out.write('%02x %02x | ' % (num1, num2))
                        #val = obj.data[10]&15
                        #out.write( 'deepok ' )
                        #out.write( '%s ' % (str(val)) )
                        out.write('%s (%d,%d) (%s) (%s)' % (obj.name, obj.shapenum, obj.framenum, str(obj.cpos), str(obj.lpos)))
                    out.write('</td>\n</tr>\n')
                    if obj.qflag is not None:
                        if obj.quality != 0:
                            out.write('<tr>\n<td colspan="2">\nquality: %s\n</td>\n</tr>\n' % (str(obj.quality)))
                    if obj.oflag is not None:
                        if obj.oval is not None:
                            out.write('<tr>\n<td>\nobjtype:\n</td>\n<td>%s\n</td>\n</tr>\n' % (str(obj.oval)))
                    out.write('<tr>\n<td>\nc pos:\n</td>\n<td>%s\n</td>\n</tr>\n' % (str(obj.cpos)))
                    out.write('<tr>\n<td>\nl pos:\n</td>\n<td>%s\n</td>\n</tr>\n' % (str(obj.lpos)))
                    #out.write('<tr>\n<td colspan="2">\n')
                    #out.write( '%s (%d,%d)' % (obj.name, obj.shapenum, obj.framenum) )
                    #out.write('</td>\n</tr>\n')
                    out.write('<tr>\n<td colspan="2">\n<img src="img_out/shape%03x_%02d.png"></td>\n</tr>\n' % (obj.shapenum, obj.framenum))
                    #print(' -> (%d) %d' % (i, data[i]))
                    out.write('</table>\n')
                else:
                    pass
            j += 1
        if 0:  # unreachable code
            global shapesman
            data = self.data
            i = 0
            while i < len(data):
                if data[i] == 6:
                    out.write('<table>\n<tr>\n<td colspan="2">\n')
                    out.write('%s' % (str(data[i:i+7])))
                    out.write('</td>\n</tr>\n')
                    val = i + 3
                    shapenum = data[val] + 256*(data[val+1] & 3)
                    framenum = (data[val+1] >> 2)  # % 32
                    val = i+1
                    pos = [data[val] >> 4, data[val+1] >> 4]
                    out.write('<tr>\n<td>\nchunk:\n</td>\n<td>%s\n</td>\n</tr>\n' % (str(pos)))
                    pos = [data[val] & 15, data[val+1] & 15, data[val+4] >> 4]
                    out.write('<tr>\n<td>\npos:\n</td>\n<td>%s\n</td>\n</tr>\n' % (str(pos)))
                    out.write('<tr>\n<td colspan="2">\n')
                    out.write('%s' % (shapesman.shapenames[shapenum]))
                    out.write('</td>\n</tr>\n')
                    out.write( '<tr>\n<td colspan="2">\n<img src="img_out/shape%03x_%02d.png"></td>\n</tr>\n' % (shapenum, framenum) )
                    #print(' -> (%d) %d' % (i, data[i]))
                    out.write('</table>\n')
                    i+= 6
                elif data[i]==12:
                    out.write('<table>\n<tr>\n<td colspan="2">\n')
                    out.write( '%s' % (str(data[i:i+13])) )
                    out.write('</td>\n</tr>\n')
                    val = i+3
                    shapenum = data[val] + 256*(data[val+1]&3)
                    framenum = (data[val+1] >> 2)# % 32
                    val = i+1
                    pos = [data[val]>>4, data[val+1]>>4]
                    out.write('<tr>\n<td>\nchunk:\n</td>\n<td>%s\n</td>\n</tr>\n' % (str(pos)))
                    pos = [data[val]&15, data[val+1]&15]
                    out.write('<tr>\n<td>\npos:\n</td>\n<td>%s\n</td>\n</tr>\n' % (str(pos)))
                    out.write('<tr>\n<td colspan="2">\n')
                    out.write( '%s' % (shapesman.shapenames[shapenum]) )
                    out.write('</td>\n</tr>\n')
                    out.write( '<tr>\n<td colspan="2">\n<img src="img_out/shape%03x_%02d.png"></td>\n</tr>\n' % (shapenum, framenum))
                    #print(' -> (%d) %d' % (i, data[i]))
                    if data[i+12] == 1:
                        out.write('</table>\n')
                    elif data[i+12] == 0:
                        out.write('<tr>\n<td colspan="2">\n')
                        out.write('Container Opened')
                        out.write('</td>\n</tr>\n')
                    i += 12
                elif data[i] == 1:
                    out.write('<tr>\n<td colspan="2">\n')
                    out.write('Container Closed')
                    out.write('</td>\n</tr>\n')
                    out.write('</table>\n')
                else:
                    #out.write( ' -> (%d) %d<br>' % (i, data[i]) )
                    pass
                i += 1
            out.close()


class U7World():
    def __init__(self, path, chunksize=16):
        self.texts = []
        self.path = path
        self.viewport = [400, 400]
        inf = file_open_in_b(self.path)
        if inf is None:
            return
        self.filesize = os.stat(self.path)[6]
        print(self.filesize)
        self.numschunks = self.filesize / 512
        print(self.numschunks)
        fmt_chunk = "<256H"
        self.schunk = []
        self.iregs = []
        self.ifixs = []
        for i in range(0, self.numschunks):
            tmpdata = inf.read(struct.calcsize(fmt_chunk))
            data = struct.unpack(fmt_chunk, tmpdata)
            self.schunk.append(data)
            self.iregs.append(None)
            self.ifixs.append(None)
        print(len(self.schunk))
        self.chunkpath = None
        self.chunksize = chunksize
        self.chunkfilesize = None
        self.numchunks = None
        self.chunks = []
        self.fchunk = None
        #if(self.chunksize==16):
            
        #for i in range(0,self.numschunks):
        #    print('Schunk %d - %d' % (i,len(self.schunk[i])))
        #    scy = 256 * (i/12)
        #    scx = 256 * (i%12)
        #    #for val in self.schunk[i]:
        #    #    print(val)
        #    print('  %d, %d' % (scx, scy))
        #for schunk in self.schunks:
        #    print('Schunk: %d' % (len(schunk)))
        inf.close()
        if 0:
            self.world = []
            for i in range(0, 3072):
                self.world.append([])
                for j in range(0, 3072):
                    if i % 16 == 0 and j % 16 == 0:
                        print(('%d %d' % (i, j)))
                    self.world[i].append(None)

    def chunk(self, chunkpath):
        self.chunkpath = chunkpath
        if file_exists(self.chunkpath) is False:
            self.chunksize = None
            return None
        self.chunkfilesize = os.stat(self.chunkpath)[6]
        self.numchunks = self.chunkfilesize / 512
        print(self.chunkfilesize)
        print(self.numchunks)
        self.chunks = []
        for i in range(0, self.numchunks):
            self.chunks.append(None)
        print(len(self.chunks))
        self.fchunk = file_open_in_b(self.chunkpath)
        if self.fchunk is None:
            return None
        return True

    def readchunk(self, num):
        #out = openOutFile('chunk%04d.html' % (num), 0)
        if num > self.numchunks:
            return None
        if num < 0:
            return None
        if self.chunks[num] is not None:
            return self.chunks[num]
        fmt_chunk = "<512B"
        self.fchunk.seek(num*512)
        tmpdata = self.fchunk.read(struct.calcsize(fmt_chunk))
        data = struct.unpack(fmt_chunk, tmpdata)
        #print(len(data))
        self.chunks[num] = []
        columns = []
        for i in range(0, 16):
            columns.append([])
        #items = []
        #out.write('<table margins="0" border="0" cellspacing="0" cellpadding="0" padding="0"><tr>\n')
        for i in range(0, 256):
            x = i % 16
            y = (i - x) / 16
            val = i * 2
            shapenum = data[val] + 256*(data[val+1] & 3)
            framenum = (data[val+1] >> 2) % 32
            #self.chunks[num].append([shapenum,framenum])
            if shapenum > 150:
                columns[x].append([x, y, shapenum, framenum])
            else:
                targus = 'hd/shape%03x_%02d.png' % (shapenum, framenum)
                if file_exists(targus) is False:
                    print('chunk %d: %s' % (num, targus))
            #shape_frame_get(shapenum,framenum)
            #out.write('<td><img src="img_out/shape%03x_%02d.png" width="8" height="8" border="0"></td>\n' % (shapenum,framenum))
            #if ((i+1) % 16) == 0:
            #    out.write('</tr>\n<tr>\n')#<br/>\n')
        
        for i in range(0, 16):
            for vals in columns[i]:
                #print(vals)
                self.chunks[num].append(vals)
        
        #out.write('</table>\n')
        #self.chunks[num] = data
        #for val in self.chunks[num]:
        #    print(val)
        #out.close()
        return self.chunks[num]

    def readschunk(self, num, type=0, min=0, max=256):
        _debug = False
        _mini = False
        _texchunk = True
        
        if self.iregs[num] is None:
            print('schunk, loading ireg: u7ireg%02x' % num)
        #    self.iregs[num] = u7ireg('blackgate/STATIC/u7ireg%02x' % (num), num)
        #if(self.ifixs[num] is None):
        #    self.ifixs[num] = u7ifix('blackgate/STATIC/u7ireg%02x' % (num), num)
        
        global shapesman
        scx = num % 12
        scy = (num-(num % 12))/12
        chunksize = self.chunksize
        if chunksize is None:
            return None
        if chunksize == 1:
            _mini = True
        scx *= chunksize * 256
        scy *= chunksize * 256
        pass2 = []
        for i in range(min, max):
            pix = i % 16
            piy = (i-pix)/16
            
            chunk_is_good = False
            if type == 0:
                chunk_is_good = True
            elif type == 1:
                if ((pix >= 0) and (pix < 8)) and ((piy >= 0) and (piy < 8)):
                    chunk_is_good = True
            elif type == 2:
                if ((pix >= 8) and (pix < 16)) and ((piy >= 0) and (piy < 8)):
                    chunk_is_good = True
            elif type == 3:
                if ((pix >= 0) and (pix < 8)) and ((piy >= 8) and (piy < 16)):
                    chunk_is_good = True
            elif type == 4:
                if ((pix >= 8) and (pix < 16)) and ((piy >= 8) and (piy < 16)):
                    chunk_is_good = True
            
            if chunk_is_good:
                cx = pix
                cy = piy
                cx *= chunksize * 16
                cy *= chunksize * 16
                posx = scx + cx
                posy = scy + cy
                #print(len(self.schunk[num]))
                #if(_debug):
                print('(%d, %d): %d' % (posx, posy, self.schunk[num][i]))
                if _texchunk:
                    if _mini:
                        chunkimg = 'thumb/chunk_%03d.png' % (self.schunk[num][i])
                        ImageOperation('selsquare u7world %s 0 0 %d %d of %d %d' % (chunkimg, self.chunksize*16, self.chunksize*16, posx, posy))
                    else:
                        chunkimg = 'hd/chunk_%03d.png' % (self.schunk[num][i])
                        ImageOperation('selsquare u7world %s 0 0 %d %d of %d %d' % (chunkimg, self.chunksize*16, self.chunksize*16, posx, posy))
                    pass
                else:
                    chunk = self.readchunk(self.schunk[num][i])
                    j = 0
                    for val in chunk:
                        jx = j % 16
                        jy = (j-jx)/16
                        if _debug:
                            print('(%d,%d) shape%03x_%02d' % (jx, jy, val[0], val[1]))
                        #if(val[0]==1 and val[1]==0):
                        #    val[1] = 1
                        mval = 8
                        if _mini:
                            mval = 1
                        pxx = ((j % 16) * mval)+posx
                        pxy = ((j/16) * mval)+posy
                        #print('%d,%d : %s' % (pxx,pxy,str(val)))
                        #if(j%2==0 and pi%2==0):
                        #sf = None  # not used?
                        sf = shapesman.shape_frame_get(val[0], val[1])
                        if sf is not None:
                            size = sf.framexy[val[1]]
                            if size is not None:
                                if size[0] != 8:
                                    pass2.append([sf, val[1], pxx, pxy])
                                else:
                                    sf.blitFrame(val[1], pxx, pxy, _mini)
                        j += 1
        #read ireg
        #for val in pass2:
        #    sf = val[0]
        #    sf.blitFrame(val[1],val[2],val[3])

    def getschunknum(self, pos):
        bchunksize = self.chunksize * 16
        schunksize = bchunksize * 16
        wchunkwide = schunksize * 12
        schunkxy = [0, 0]
        #bchunkxy = [0, 0]
        #scxy = [0, 0]
        ipos = [0, 0]
        for i in range(0, 2):
            ipos[i] = pos[i]
            while ipos[i] < 0.0:
                ipos[i] += wchunkwide
            while ipos[i] >= wchunkwide:
                ipos[i] -= wchunkwide
            keep = ipos[i]
            while keep > schunksize:
                keep -= schunksize
                schunkxy[i] += 1
        
        schunknum = (schunkxy[1] * 12) + schunkxy[0]
        return schunknum

    def getchunknum(self, pos):
        bchunksize = self.chunksize * 16
        schunksize = bchunksize * 16
        wchunkwide = schunksize * 12
        schunkxy = [0, 0]
        bchunkxy = [0, 0]
        scxy = [0, 0]
        ipos = [0, 0]
        for i in range(0, 2):
            ipos[i] = pos[i]
            while ipos[i] < 0.0:
                ipos[i] += wchunkwide
            while ipos[i] >= wchunkwide:
                ipos[i] -= wchunkwide
            keep = ipos[i]
            while keep > schunksize:
                keep -= schunksize
                schunkxy[i] += 1

            scxy[i] = (schunkxy[i] * schunksize)
            keep = ipos[i] - scxy[i]
            while keep > bchunksize:
                keep -= bchunksize
                bchunkxy[i] += 1

        schunknum = (schunkxy[1] * 12) + schunkxy[0]
        bchunknum = (bchunkxy[1] * 16) + bchunkxy[0]
        #print(schunknum)
        #print(bchunknum)
        return self.schunk[schunknum][bchunknum]

    def viewport_set(self, viewport):
        self.viewport = viewport

    def view(self, pos):
        if self.chunksize is None:
            return None
        global shapesman
        global memusage
        #chks = []  # not used
        #chkdim = [1,1]  # not used
        ipos = [0, 0]
        schunkxy = [0, 0]
        bchunkxy = [0, 0]
        ofsxy = [0, 0]
        chunkbleed = 160
        #pixel locations
        scxy = [0, 0]
        bchunksize = float(self.chunksize) * 16.0
        schunksize = bchunksize * 16.0
        wchunkwide = schunksize * 12.0
        for i in range(0, 2):
            ipos[i] = int(pos[i]) - (self.viewport[i]/2)
            ofsxy[i] = int(pos[i]) % int(bchunksize)
        start = [ipos[0], ipos[1]]
        print('VIEW -> U7World.view: start coords %s' % str(start))
        sceneobjects = []
        queues = []
        #qstart = [ipos[0] - ofsxy[0], ipos[1] - ofsxy[1]]
        i = ipos[1] - ofsxy[1]
        chunkstart = [ipos[0] - ofsxy[0], ipos[1] - ofsxy[1]]
        ImageOperation('selbounds u7world %d %d 1' % (self.viewport[0], self.viewport[1]))
        objcount = 0
        chunkct = 0

        print('VIEW -> Start')
        while i < (start[1] + self.viewport[1] + chunkbleed):
            j = ipos[0] - ofsxy[0]
            while j < (start[0] + self.viewport[0] + chunkbleed):
                print('  U7World.view: look j, i = [%d,%d]' % (j, i))
                chunknum = self.getchunknum([j, i, 0])
                schunknum = self.getschunknum([j, i, 0])
                if self.iregs[schunknum] is None:
                    print('VIEW -> Loading SCHUNK IREG: {0}'.format(schunknum))
                    self.iregs[schunknum] = U7ireg('blackgate/STATIC/u7ireg%02x' % schunknum, schunknum)
                    barf_mem_usage()
                #if(self.iregs[schunknum] is not None):
                #    self.iregs[schunknum].dump()
                print('VIEW -> Get IregObjs: {0}'.format(schunknum))
                iregobjs = self.iregs[schunknum].getchunkobjs([j, i, 0])
                barf_mem_usage()
                #print('schunk %02x' % (schunknum))
                
                chunkimg = 'hd/chunk_%03d.png' % chunknum
                #chunkimg = 'hd/chunk_fix.png'
                
                ImageOperation('selsquare u7world %s 0 0 %d %d of %d %d' % (chunkimg, int(bchunksize), int(bchunksize), j-start[0], i - start[1]))
                barf_mem_usage()
                
                chunk = self.readchunk(chunknum)
                #pass2 = []
                for val in chunk:
                    #jx = k%16
                    #jy = (k-jx)/16
                    jx = val[0]
                    jy = val[1]
                    zscore = 0
                    zx = jx+j - start[0]
                    zy = jy+i - start[1]
                    #print('(%d,%d) shape%03x_%02d' % (jx,jy,val[0],val[1]))
                    #print('  > zx(%d) zy(%d)' % (zx, zy))
                    zscore = 0
                    #if(zy>zx):
                    #    zscore = zy + 1
                    #else:
                    #    zscore = zx
                    #zscore *= 12
                    #zscore = int(zscore)
                    #if(_debug):
                    #    print('(%d,%d) shape%03x_%02d' % (jx,jy,val[0],val[1]))
                    mval = self.chunksize
                    #if(_mini):
                    #    mval = 1
                    pxx = (jx * mval)+j-start[0]
                    pxy = (jy * mval)+i-start[1]
                    #sf = None
                    if val[2] > 150:
                        jp = int(((j - chunkstart[0]) / bchunksize) * 16)
                        ip = int(((i - chunkstart[1]) / bchunksize) * 16)
                        shapename = shapesman.getshapename(val[2])
                        #sceneobjects.append([sf,val[3],[jx+jp,jy+ip,0],pxx,pxy,False])
                        print('  CHUNK_OBJ: %s(%d-%d): %s' % (shapename, val[2], val[3], str([jx+jp, jy+ip, 0])))
                        #(self, shapenum, framenum, lpos, pxofs, chunkobj, index)
                        sceneobjects.append(U7SceneObject(val[2], val[3], [jx+jp, jy+ip, 0], [pxx, pxy], False, objcount))
                        objcount += 1
                            
                        #sf = shapesman.shape_frame_get(val[2],val[3])
                        #if(sf is not None):
                            #if(len(queues)<=zscore):
                            #    for m in range(len(queues),zscore+1):
                            #        queues.append([])
                            #if(zscore==chunkct):
                            #size = sf.framexy[val[3]]
                            #pxo = sf.framepxo[val[3]]
                            #if(size is not None):
                            #    pass
                                #sf.blitFrame(val[3],pxx,pxy)
                                #qx = int(jx + j - qstart[0])
                                #qy = int(jy + i - qstart[1])
                                #qz = 0
                                #major = qx
                                #minor = qy
                                #major = qy
                                #minor = qx
                                #minut = qz
                                #if(len(queues)<=major):
                                #    for m in range(len(queues),major+1):
                                #        queues.append([])
                                #que = queues[major]
                                #if(len(que)<=minor):
                                #    for m in range(len(que),minor+1):
                                #        que.append([])
                                #if(len(que[minor])<=minut):
                                #    for m in range(len(que[minor]),minut+1):
                                #        que[minor].append([])
                                #xdif = (pxo[2] - size[0]) * 2
                                #ydif = (pxo[1] - size[1]) * 2
                                #CHUNK OBJECTS
                                #que[minor][minut].append([sf,val[3],pxx,pxy,None])
                
                for obj in iregobjs:
                    shapename = shapesman.getshapename(obj.shapenum)
                    if obj.exclude is True:
                        print('  IREG EXCLUDE: %s(%d-%d): %s' % (shapename, obj.shapenum, obj.framenum, str(obj.lpos)))
                        pass
                    else:
                        print('  IREG: %s(%d-%d): %s' % (shapename, obj.shapenum, obj.framenum, str(obj.lpos)))
                        jx = obj.lpos[0]
                        jy = obj.lpos[1]
                        jz = obj.lpos[2]
                        zscore = 0
                        zx = jx+j - start[0]
                        zy = jy+i - start[1]
                        #print('(%d,%d) shape%03x_%02d' % (jx,jy,val[0],val[1]))
                        #print('  > zx(%d) zy(%d)' % (zx, zy))
                        #if(zy>zx):
                        #    zscore = zy + 1
                        #else:
                        #    zscore = zx
                        #zscore *= 12
                        #zscore = int(zscore)
                        #zscore += int((jz*4) + 1)
                        mval = self.chunksize
                        pxx = (jx * mval)+j-start[0]
                        pxy = (jy * mval)+i-start[1]
                        pxx -= (mval/2) * jz
                        pxy -= (mval/2) * jz
                        
                        jp = int(((j - chunkstart[0]) / bchunksize) * 16)
                        ip = int(((i - chunkstart[1]) / bchunksize) * 16)
                        sceneobjects.append(U7SceneObject(obj.shapenum, obj.framenum, [jx+jp, jy+ip, jz], [pxx, pxy], True, objcount))
                        objcount += 1
                        #sceneobjects.append([sf,obj.framenum,[jx+jp,jy+ip,jz],pxx,pxy,True])
                        #sf = None
                        #sf = shapesman.shape_frame_get(obj.shapenum,obj.framenum)
                        #if(sf is not None):
                        #    size = sf.framexy[obj.framenum]
                            #pxo = sf.frameofs[obj.framenum]
                            #if(size is not None):
                            #    pass
                                #if(size[0]!=16):
                                #print('trying to blit large chunk %d %d' % (val[2], val[3]))
                                #pass2.append([sf,val[3],pxx,pxy])
                                #sf.blitFrame(obj.framenum,pxx,pxy)
                                #qx = int(jx + j - qstart[0])
                                #qy = int(jy + i - qstart[1])
                                #qz = jz
                                #major = qx
                                #minor = qy
                                
                                #major = qy
                                #minor = qx
                                #minut = qz
                                
                                #if(len(queues)<=zscore):
                                #    for m in range(len(queues),zscore+1):
                                #        queues.append([])
                                #if(zscore==chunkct):
                                #queues[zscore].append([sf,obj.framenum,pxx,pxy,obj.lpos])
                                ##jp = int(((j - chunkstart[0]) / bchunksize) * 16)
                                ##ip = int(((i - chunkstart[1]) / bchunksize) * 16)
                                ##sceneobjects.append([sf,obj.framenum,[jx+jp,jy+ip,jz],pxx,pxy,True])
                                
                                #UNCOMMENT NEXT LINES TO ADD IREG OBJECTS BACK IN
                                #if(len(queues)<=major):
                                #    for m in range(len(queues),major+1):
                                #        queues.append([])
                                #que = queues[major]
                                #if(len(que)<=minor):
                                #    for m in range(len(que),minor+1):
                                #        que.append([])
                                #if(len(que[minor])<=minut):
                                #    for m in range(len(que[minor]),minut+1):
                                #        que[minor].append([])
                                #IREG OBJECTS
                                #que[minor][minut].append([sf,obj.framenum,pxx,pxy,obj.lpos])
                                
                                #que[minor][minut].append([sf,obj.framenum,pxx,pxy])
                                #if(obj.debug is True):
                                #    print(' drawing object DEBUG: %d %d' % (pxx, pxy))
                                #    self.texts.append([pxx,pxy,obj.name+'\n(%d, %d)' % (pxx,pxy)])
                                #if(jz<1):
                                #    que[minor].append([sf,obj.framenum,pxx,pxy])
                                #print('draw %d,%d,%d' % (jx,jy,jz))
                                #else:
                                #    print('trying to blit small chunk %d %d' % (val[2], val[3]))
                                #    pass
                                #    #sf.blitFrame(val[3],pxx,pxy,_mini)
                #print('square sel fin')
                chunkct += 1
                j += bchunksize
            i += bchunksize
        print('VIEW -> SceneObjects: %d' % (len(sceneobjects)))
        barf_mem_usage()
        #caculate bounds
        minbounds = [None, None, None]
        maxbounds = [None, None, None]
        for so in sceneobjects:
            for m in range(0, 3):
                mval = so.lpos[m]
                if minbounds[m] is None:
                    minbounds[m] = mval
                    maxbounds[m] = mval+1
                else:
                    if mval < minbounds[m]:
                        minbounds[m] = mval
                    if mval >= maxbounds[m]:
                        maxbounds[m] = mval+1
        for m in range(0, 3):
            if minbounds[m] is None:
                minbounds[m] = 0
            if maxbounds[m] is None:
                maxbounds[m] = 0
        print('VIEW -> SPACES ALLOCATE min %s %s %s' % (minbounds[0], minbounds[1], minbounds[2]))
        print('VIEW -> SPACES ALLOCATE max %s %s %s' % (maxbounds[0], maxbounds[1], maxbounds[2]))
        xdiff = maxbounds[0]-minbounds[0]
        ydiff = maxbounds[1]-minbounds[1]
        #zdiff = maxbounds[2]-minbounds[2]
        zdiff = 8
        print('VIEW -> SPACES ALLOCATE xyz %d %d %d' % (xdiff, ydiff, zdiff))
        barf_mem_usage()
        #print(xdiff)
        #print(ydiff)
        #print(zdiff)
        spaces = []
        for l in range(0, xdiff+1):
            spaces.append([])
            for m in range(0, ydiff+1):
                spaces[l].append([])
                for n in range(0, zdiff+1):
                    spaces[l][m].append(None)
        #sceneobjects[44].postdrawn = True
        #sceneobjects[45].postdraws.append(44)

        for so in sceneobjects:
            pos = so.lpos
            for i in range(0, 3):
                pos[i] = pos[i] - minbounds[i]
            space = so.space
            pos[0] = pos[0] - space[0]
            pos[1] = pos[1] - space[1]
            keeper = [pos[0], pos[1], pos[2]]
            for l in range(0, space[2]):
                keeper[2] = pos[2] + l
                #bpos = [keeper[2],0]
                #while(bpos[0]>=rowmax):
                #    bpos[0]-=rowmax
                #    bpos[1]+=1
                #boxstart = [3+((xdiff+4)*bpos[0]),3+((ydiff+4)*bpos[1])]
                for m in range(0, space[1]):
                    keeper[0] = pos[0]
                    keeper[1] = pos[1] + m
                    for n in range(0, space[0]):
                        keeper[0] = pos[0] + n
                        x = keeper[0] - minbounds[0]
                        y = keeper[1] - minbounds[1]
                        z = keeper[2] - minbounds[2]
                        dot_go = True
                        if x < 0:
                            dot_go = False
                        if y < 0:
                            dot_go = False
                        if x > xdiff:
                            dot_go = False
                        if y > ydiff:
                            dot_go = False
                        borkline = ''
                        borked = False
                        if dot_go:
                            borkline += 'U7World view: spaces check %d %d %d\n' % (x, y, z)
                            borkline += 'len spaces X is %d\n' % (len(spaces))
                            if len(spaces) <= xdiff:
                                borked = True
                            borkline += 'len spaces Y is %d\n' % (len(spaces[x]))
                            if len(spaces[x]) <= ydiff:
                                borked = True
                            borkline += 'len spaces Z is %d\n' % (len(spaces[x][y]))
                            if len(spaces[x][y]) <= zdiff:
                                borked = True
                            if z >= len(spaces[x][y]):
                                borkline += 'Z too Large %d vs %d\n' % (z, len(spaces[x][y]))
                                borked = True
                            else:
                                if spaces[x][y][z] is None:
                                    spaces[x][y][z] = so.index
                        if borked:
                            print(borkline)
        dobjs = []
        print('----')
        barf_mem_usage()
        print('VIEW -> LOOP SCENE OBJECTS')
        sonum = 0
        for so in sceneobjects:
            if so.sf is not None:
                rvals = so.sf.drawSize(so.framenum, so.px[0], so.px[1])
                boundstest = bounds_check(rvals, self.viewport)
                pos = [so.lpos[0], so.lpos[1], so.lpos[2]]
                print('SO[{0}]: PREPOS IS {1} {2} {3}'.format(sonum, pos[0], pos[1], pos[2]))
                print('SO[{0}]: MINBOUNDS IS {1} {2} {3}'.format(sonum, minbounds[0], minbounds[1], minbounds[2]))
                for i in range(0, 3):
                    pos[i] = pos[i] - minbounds[i]
                if pos[2] > 0:
                    print('SO[{0}]: POSTPOS IS {1} {2} {3} (larger than zero)'.format(sonum, pos[0], pos[1], pos[2]))
                    topof = spaces[pos[0]][pos[1]][pos[2]-1]
                    if topof is not None:
                        so.zscore = (so.lpos[1] * zdiff * ydiff) + (so.lpos[2] * ydiff) + so.lpos[0]
                        so.drawpos(rvals)
                        so.postdrawn = True
                        so.parent = topof
                        sceneobjects[topof].postdraws.append(so.index)
                elif pos[2] == 0:
                    #try:
                    coord_good = True
                    for i in range(0, 3):
                        if pos[i] < 0:
                            coord_good = False
                    if coord_good:
                        if pos[0] < len(spaces):
                            if pos[1] < len(spaces[pos[0]]):
                                if pos[2] < len(spaces[pos[0]][pos[1]]):
                                    pass
                                else:
                                    coord_good = False
                            else:
                                coord_good = False
                        else:
                            coord_good = False
                    if coord_good:
                        print('SO[{0}]: POS IS {1} {2} {3} (is zero)'.format(sonum, pos[0], pos[1], pos[2]))
                        topof = spaces[pos[0]][pos[1]][pos[2]]
                        if topof is not None and topof != so.index:
                            so.zscore = (so.lpos[1] * zdiff * ydiff) + (so.lpos[2] * ydiff) + so.lpos[0]
                            so.drawpos(rvals)
                            so.postdrawn = True
                            so.parent = topof
                            #sceneobjects[topof].postdraws.append(so.index)
                            #so.zscore = (so.lpos[1] * zdiff * ydiff) + (so.lpos[2] * ydiff) + so.lpos[0] 
                            inserted = False
                            if len(sceneobjects[topof].postdraws) == 0:
                                sceneobjects[topof].postdraws.append([so.index, so.zscore])
                                inserted = True
                            m = 0
                            while inserted is False:
                                for m in range(0, len(sceneobjects[topof].postdraws)):
                                    #print(('testing ... %d %d' % (m, so.index)))
                                    if inserted is False:
                                        if so.zscore < sceneobjects[topof].postdraws[m]:
                                            sceneobjects[topof].postdraws.insert(m, [so.index, so.zscore])
                                            inserted = True
                                if inserted is False:
                                    sceneobjects[topof].postdraws.append([so.index, so.zscore])
                                    inserted = True
                    else:
                        print('SO[{0}]: FAILPOS {1} {2} {3} (is zero)'.format(sonum, pos[0], pos[1], pos[2]))
                    #except:
                    #    
                    #    for i in range(0, 3):
                    #        if pos[i] < 0:
                    #            print('POS {0} less than 0'.format(i))
                    #        else:
                    #            print('POS {0} greater than 0'.format(i))
                    #    #print('FAIL POS len spaces XY is %d' % (len(spaces[x][y])))
                if rvals[1] is not None and boundstest is True and so.postdrawn is False:
                #if(rvals[1] is not None and boundstest is True):
                    so.drawpos(rvals)
                    if so.zscore is not None:
                        so.zscore = (so.lpos[1] * zdiff * ydiff) + (so.lpos[2] * ydiff) + so.lpos[0] 
                        inserted = False
                        if len(dobjs) == 0:
                            dobjs.append([so.index, so.zscore])
                            inserted = True
                        m = 0
                        while inserted is False:
                            for m in range(0, len(dobjs)):
                                #print(('testing ... %d %d' % (m, so.index)))
                                if inserted is False:
                                    if so.zscore < dobjs[m][1]:
                                        dobjs.insert(m, [so.index, so.zscore])
                                        inserted = True
                            if inserted is False:
                                dobjs.append([so.index, so.zscore])
                                inserted = True
                    #print(so.dump())
            sonum += 1
        print('----')
        barf_mem_usage()
        print('VIEW -> LOOP DRAW OBJECTS')
        for doj in dobjs:
            if len(doj) != 2:
                print('DOJ LEN: {0}'.format(len(doj)))
            else:
            #for k in range(0, len(doj)):
                # ZERO is the index, ONE is the z-score
                draw_sceneobject(sceneobjects, doj[0])
            pass
        barf_mem_usage()
            #so = sceneobjects[doj[0]]
            #if(so.drawn is False):
            #    ImageOperation('selappend %s u7world of %d %d sc 2' % (so.sf.frames[so.framenum], so.px[0], so.px[1]))
            #    #print('obj[%d] - draw' % (doj[0]))
            #    so.drawn = True
            #    for dop in so.postdraws:
            #        sop = sceneobjects[dop]
            #        ImageOperation('selappend %s u7world of %d %d sc 2' % (sop.sf.frames[sop.framenum], sop.px[0], sop.px[1]))
            #        #print('obj[%d] - draw' % (dop))
            #        sop.drawn = True
            #dumpu7world()
            #        #ImageOperation('selsquare u7world %s 0 0 %d %d of %d %d' % (chunkimg,int(bchunksize),int(bchunksize),j-start[0],i-start[1]))
            #
            #            #print('so[%d] %s(%d): %s - (%d %d) - (%d %d)' % (so.index, so.name, so.framenum, str(so.chunkobj), rvals[0][0], rvals[0][1], rvals[1][0], rvals[1][1]))

        if 0:  # unreachable code
            rowmax = 3
            #draw boxes for Z
            for k in range(0, zdiff):
                bpos = [k, 0]
                while bpos[0] >= rowmax:
                    bpos[0] -= rowmax
                    bpos[1] += 1
                boxsize = [xdiff+2, ydiff+2]
                boxstart = [2+((xdiff+4)*bpos[0]), 2+((ydiff+4)*bpos[1])]
                drawbox('u7world', boxstart, boxsize)
            #iterate objects and draw spaces
            for so in sceneobjects:
                pos = so.lpos
                for i in range(0, 3):
                    pos[i] = pos[i] - minbounds[i]
                space = so.space
                pos[0] = pos[0] - space[0]
                pos[1] = pos[1] - space[1]
                #pos[2] = pos[2] + space[2]
                keeper = [pos[0], pos[1], pos[2]]
                for l in range(0, space[2]):
                    keeper[2] = pos[2] + l
                    bpos = [keeper[2], 0]
                    while bpos[0] >= rowmax:
                        bpos[0] -= rowmax
                        bpos[1] += 1
                    boxstart = [3+((xdiff+4)*bpos[0]), 3+((ydiff+4)*bpos[1])]
                    for m in range(0, space[1]):
                        keeper[0] = pos[0]
                        keeper[1] = pos[1] + m
                        for n in range(0, space[0]):
                            keeper[0] = pos[0] + n
                            x = keeper[0] - minbounds[0] + boxstart[0]
                            y = keeper[1] - minbounds[1] + boxstart[1]
                            dot_go = True
                            if x < boxstart[0]:
                                dot_go = False
                            if y < boxstart[1]:
                                dot_go = False
                            if x > boxstart[0] + xdiff:
                                dot_go = False
                            if y > boxstart[1] + ydiff:
                                dot_go = False
                            if dot_go:
                                tiny_dot('u7world', x, y)

                #x = pos[0] - minbounds[0] +
                #y = pos[1] - minbounds[1]
                #tiny_dot('u7world',x+boxstart[0],y+boxstart[1])

            if 0:  # unreachable code
                zdepth = maxbounds[1] - minbounds[1]
                #if(maxbounds[0] > maxbounds[1]):
                #    zdepth = maxbounds[0] - minbounds[0]
                zwide = maxbounds[0] - minbounds[0]
                zmult = maxbounds[2] - minbounds[2] + 1
                zdepth = int(zdepth * zmult)
                for m in range(0, zdepth):
                    zscore = m
                    if len(queues) <= zscore:
                        for m in range(len(queues), zscore+1):
                            queues.append([])
                    for so in sceneobjects:
                        pos = so[2]
                        mval = pos[1]
                        if pos[0] > mval:
                            mval = pos[0]
                        mval = int(mval * zmult)
                        if so[5] is True:
                            mval += 1
                        mval += pos[2]
                        if mval == m:
                            #sceneobjects.  append([sf,obj.framenum,pxx,pxy,None])
                            #queues[zscore].append([sf,obj.framenum,pxx,pxy,obj.lpos])
                            print('SO: %s' % (str(so)))
                            #if(so[5] is True):
                            queues[zscore].append([so[0], so[1], so[3], so[4], so[5]])
                print('scene bounds: %s - %s' % (str(minbounds), str(maxbounds)))
                print('    Processing queues!')
                print(' > Chunks: %d' % chunkct)
                drawnval = 0
                drawlimit = 200
                qnum = 0
                for que in queues:
                    print('Q[%d] length %d' % (qnum, len(que)))
                    for qq in que:
                        if drawnval < drawlimit:
                            #print('QQ: %s' % (str(qq)))
                            if qq[0].blitFrame(qq[1], self.viewport, qq[2], qq[3]) is True:
                                shapename = shapesman.getshapename(qq[0].index)
                                print('Q[%d] %s(%d): %s - %d %d' % (qnum, shapename, qq[1], str(qq[4]), qq[2], qq[3]))
                                drawnval += 1
                                dumpu7world()
                    qnum += 1
                #    for qo in que:
                #        for qp in qo:
                #            for qq in qp:
                #                if(qq[4] is None):
                #                    if(qq[0].blitFrame(qq[1],self.viewport,qq[2],qq[3]) is True):
                #                        shapename = shapesman.getshapename(qq[0].index)
                #                        print('%s(%d): %s - %d %d' % (shapename,qq[1],str(qq[4]),qq[2],qq[3]))
                #                        #dumpu7world()
                #print('    Processing queues!')
                #for que in queues:
                #    for qo in que:
                #        for qp in qo:
                #            for qq in qp:
                #                if(qq[4] is None):
                #                    if(qq[0].blitFrame(qq[1],self.viewport,qq[2],qq[3]) is True):
                #                        shapename = shapesman.getshapename(qq[0].index)
                #                        print('%s(%d): %s - %d %d' % (shapename,qq[1],str(qq[4]),qq[2],qq[3]))
                #                        #dumpu7world()
                #    for qo in que:
                #        for qp in qo:
                #            for qq in qp:
                #                if(qq[4] is not None):
                #                    if(qq[0].blitFrame(qq[1],self.viewport,qq[2],qq[3]) is True):
                #                        shapename = shapesman.getshapename(qq[0].index)
                #                        print('%s(%d): %s - %d %d' % (shapename,qq[1],str(qq[4]),qq[2],qq[3]))
                #                        #dumpu7world()

                print('    Queues processed!  Show me that picture!')
                #return
                #for val in pass2:
                #    print('blitting %d %d' % (val[0].index,val[1]))
                #    sf = val[0]
                #    sf.blitFrame(val[1],val[2],val[3])
                #ImageOperation('selcrop -i u7world -st %d %d -sz %d %d' % (start[0],start[1],self.viewport[0],self.viewport[1]))

                if 0:  # unreachable code
                    print(bchunksize)
                    print(schunksize)
                    print(wchunkwide)
                    for i in range(0, 2):
                        ipos[i] = pos[i] - self.viewport[i]
                        while ipos[i] < 0.0:
                            ipos[i] += wchunkwide
                        while ipos[i] >= wchunkwide:
                            ipos[i] -= wchunkwide

                        keep = ipos[i]
                        while keep > schunksize:
                            keep -= schunksize
                            schunkxy[i] += 1

                        scxy[i] = (schunkxy[i] * schunksize)
                        keep = ipos[i] - scxy[i]
                        while keep > bchunksize:
                            keep -= bchunksize
                            bchunkxy[i] += 1
                        ofsxy[i] = keep
                    print(schunkxy)
                    print(bchunkxy)
                    print(ofsxy)


def chunk_dump(world, hd=True):
    cks = 8
    fld = 'img_out'
    if hd is True:
        cks = 16
        fld = 'hd'
    #for i in range(0,16):
    for i in range(0, world.numchunks):
        chunkimg = '%s/chunk_%03d.png' % (fld,i)
        if file_exists(chunkimg) is False:
            chunk = world.readchunk(i)
            j = 0
            for val in chunk:
                jx = j % 16
                jy = (j-jx)/16
                px = jx * cks
                py = jy * cks
                imgfile = '%s/shape%03x_%02d.png' % (fld, val[0], val[1])
                if file_exists(imgfile) is True:
                    ImageOperation('selsquare u7world %s 0 0 %d %d of %d %d' % (imgfile,cks,cks,px,py))
                j += 1
            ImageOperation('selsave u7world %s' % chunkimg)
            ImageOperation('selwipe u7world')
        garbageman.checkrun()
        if file_exists(chunkimg) is True:
            targus = '%s/chunk_%03d.png' % ('thumb', i)
            if file_exists(targus) is False:
                ImageOperation('resize -i %s -o %s -w 16 -m bicubic' % (chunkimg, targus))
            else:
                if file_exists(chunkimg) is not True:
                    print('shape image %s not exist!' % chunkimg)


def minimap_glue():
    global garbageman
    imgfile = 'u7world_mini_all.png'
    print('glue')
    if file_exists(imgfile) is False:
        print('time for pain')
        ImageOperation('selsquare u7world u7world_mini_1.4.png 0 0 3072 768 of 0 0')
        print('un')
        ImageOperation('selsquare u7world u7world_mini_2.4.png 0 0 3072 768 of 0 768')
        print('du')
        #ImageOperation('selsquare u7world u7world_mini_3.4.png 0 0 3072 768 of 1536 0')
        #print('twu')
        #ImageOperation('selsquare u7world u7world_mini_4.4.png 0 0 3072 768 of 2304 0')
        #print('ku')
        ImageOperation('selsave u7world %s' % imgfile)
        ImageOperation('selwipe u7world')

        if 0:  # unreachable code
            for i in range(12, 16):
                px = (i % 4) * 768
                py = ((i-(i % 4))/4) * 768
                print(i)
                ImageOperation('selsquare u7world u7world_mini_%02d.png 0 0 768 768 of %d %d' % (i, px, py))
                #ImageOperation('selappend map%02d u7world %d %d' % (i,px,py))
                #ImageOperation('selwipe map%02d' % (i))
                garbageman.checkrun()
                print(px)
                print(py)
            ImageOperation('selsave u7world %s' % imgfile)
            ImageOperation('selwipe u7world')

            if 0:  # unreachable code
                ImageOperation('selappend map01 u7world 768 0')
                ImageOperation('selappend map02 u7world 1536 0')
                ImageOperation('selappend map03 u7world 2304 0')
                ImageOperation('selappend map04 u7world 0 768')
                ImageOperation('selappend map05 u7world 768 768')
                ImageOperation('selappend map06 u7world 1536 768')
                ImageOperation('selappend map07 u7world 2304 768')
                ImageOperation('selappend map08 u7world 0 1536')
                ImageOperation('selappend map09 u7world 768 1536')
                ImageOperation('selappend map10 u7world 1536 1536')
                ImageOperation('selappend map11 u7world 2304 1536')
                ImageOperation('selappend map12 u7world 0 2304')
                ImageOperation('selappend map13 u7world 768 2304')
                ImageOperation('selappend map14 u7world 1536 2304')
                ImageOperation('selappend map15 u7world 2304 2304')
                ImageOperation('selsave u7world %s' % imgfile)
                ImageOperation('selwipe u7world')


def minimap_dump(world):
    middle = []
    middle.append(13)
    middle.append(16)
    middle.append(19)
    middle.append(22)
    middle.append(49)
    middle.append(52)
    middle.append(55)
    middle.append(58)
    middle.append(85)
    middle.append(88)
    middle.append(91)
    middle.append(94)
    middle.append(121)
    middle.append(124)
    middle.append(127)
    middle.append(130)
    for i in range(0, len(middle)):
        scs = []
        val = middle[i]
        scs.append(val-13)
        scs.append(val-12)
        scs.append(val-11)
        scs.append(val-1)
        scs.append(val)
        scs.append(val+1)
        scs.append(val+11)
        scs.append(val+12)
        scs.append(val+13)
        imgfile = 'u7world_mini_%02x.png' % i
        if file_exists(imgfile) is False:
            for j in scs:
                world.readschunk(j, 0)
            ImageOperation('selsave u7world %s' % imgfile)
            ImageOperation('selwipe u7world')
        for j in range(0,len(scs)):
            scs.pop(0)
        garbageman.checkrun()
    thumbsize = 384
    for i in range(0,16):
        imgfile = 'u7world_mini_%02x.png' % i
        print('%s' % imgfile)
        
        targus = 'thumb/u7bg_mini_%02x.png' % i
        if file_exists(imgfile) is True and file_exists(targus) is False:
            ImageOperation('resize -i %s -o %s -w %d -m bicubic' % (imgfile, targus, thumbsize))
        garbageman.checkrun()

    for i in range(0, 16):
        imgfile = 'thumb/u7bg_mini_%02x.png' % i
        px = (i % 4) * thumbsize
        py = ((i - (i % 4)) / 4) * thumbsize
        print('%s: %d %d' % (imgfile,px,py))
        ImageOperation('selsquare u7world %s 0 0 %d %d of %d %d' % (imgfile,thumbsize,thumbsize,px,py))
        garbageman.checkrun()
    return


shapesman = None
memusage = 0


def checkFiles():
    filesRoot = ''
    inPath = 'fileslist.txt'
    inFW = FileWerks(inPath)
    fileInfoPath = 'u7.fileInfo.yaml'
    fileInfo = None
    fileInfoChanged = False
    if os.path.exists(fileInfoPath):
        fileInfo = yamlRead('u7.fileInfo.yaml')
    if fileInfo is None:
        fileInfo = {}
        fileInfoChanged = True
    if inFW.exists is True:
        lines = inFW.getLines()
        for line in lines:
            if len(line) > 0:
                lvals = line.split('/')
                #print(line)
                filePath = '{0}{1}'.format(filesRoot, line)
                if os.path.isdir(filePath):
                    #print(filePath)
                    pass
                else:
                    #print(filePath)
                    if os.path.exists(filePath):
                        if line in fileInfo:
                            pass
                        else:
                            fileInfo[line] = {}
                            fileInfo[line]['type'] = 'ignore'
                            if stringMatch(lvals[0], 'Ultima 7'):
                                fileInfo[line]['game'] = 'U7'
                            elif stringMatch(lvals[0], 'Ultima 7 - Serpent Isle'):
                                fileInfo[line]['game'] = 'SI'
                            fileInfoChanged = True
    for fileKey in fileInfo:
        lineVals = fileKey.split('/')
        #print(fileInfo[fileKey])
        fileType = dictGetValue(fileInfo[fileKey], 'type')
        if stringMatch(fileType, 'ignore'):
            #print(fileKey)
            if len(lineVals) == 0:
                pass
            elif len(lineVals) == 1:
                print(lineVals)
            elif len(lineVals) == 2:
                #print(lineVals[1])
                if stringMatchEnd(lineVals[1].lower(), '.exe'):
                    fileInfo[fileKey]['type'] = 'executable'
                    fileInfoChanged = True
                elif stringMatchEnd(lineVals[1].lower(), '.u7'):
                    fileInfo[fileKey]['type'] = 'savegame'
                    fileInfoChanged = True
            #elif len(lineVals) == 3:
            else:
                if stringMatch(lineVals[1].lower(), 'static'):
                    if stringMatchStart(lineVals[2].lower(), 'u7ifix'):
                        fileInfo[fileKey]['type'] = 'ifix'
                        fileInfoChanged = True
                    else:
                        if len(lineVals) == 3:
                            if stringMatchEnd(lineVals[2].lower(), '.cfg'):
                                fileInfo[fileKey]['type'] = 'config'
                                fileInfoChanged = True
                            elif stringMatchEnd(lineVals[2].lower(), '.dat'):
                                fileInfo[fileKey]['type'] = 'dat_'
                                fileInfoChanged = True
                            elif stringMatchEnd(lineVals[2].lower(), '.vga'):
                                fileInfo[fileKey]['type'] = 'vga_'
                                fileInfoChanged = True
                            elif stringMatchEnd(lineVals[2].lower(), '.pal'):
                                fileInfo[fileKey]['type'] = 'pal_'
                                fileInfoChanged = True
                            elif stringMatchEnd(lineVals[2].lower(), '.flx'):
                                fileInfo[fileKey]['type'] = 'flx_'
                                fileInfoChanged = True
                            elif stringMatchEnd(lineVals[2].lower(), '.adv'):
                                fileInfo[fileKey]['type'] = 'adv_'
                                fileInfoChanged = True
                            elif stringMatchEnd(lineVals[2].lower(), '.xmi'):
                                fileInfo[fileKey]['type'] = 'xmi_'
                                fileInfoChanged = True
                            elif stringMatchEnd(lineVals[2].lower(), '.spc'):
                                fileInfo[fileKey]['type'] = 'speech'
                                fileInfoChanged = True
                            elif stringMatchEnd(lineVals[2].lower(), '.flg'):
                                fileInfo[fileKey]['type'] = 'flg_'
                                fileInfoChanged = True
                            elif stringMatch(lineVals[2].lower(), 'usecode'):
                                fileInfo[fileKey]['type'] = 'usecode'
                                fileInfoChanged = True
                            elif stringMatch(lineVals[2].lower(), 'u7map'):
                                fileInfo[fileKey]['type'] = 'map'
                                fileInfoChanged = True
                            elif stringMatch(lineVals[2].lower(), 'u7chunks'):
                                fileInfo[fileKey]['type'] = 'chunks'
                                fileInfoChanged = True
                            else:
                                print(lineVals)
                            pass
                        else:
                            print(lineVals[2].lower())
                        pass
                elif stringMatch(lineVals[1].lower(), 'gamedat'):
                    if stringMatchStart(lineVals[2].lower(), 'u7ireg'):
                        fileInfo[fileKey]['type'] = 'ireg'
                        fileInfoChanged = True
                    else:
                        if len(lineVals) == 3:
                            #print(lineVals[2].lower())
                            if stringMatchEnd(lineVals[2].lower(), '.cfg'):
                                fileInfo[fileKey]['type'] = 'config'
                                fileInfoChanged = True
                            elif stringMatchEnd(lineVals[2].lower(), '.dat'):
                                fileInfo[fileKey]['type'] = 'dat_'
                                fileInfoChanged = True
                            elif stringMatchEnd(lineVals[2].lower(), '.flg'):
                                fileInfo[fileKey]['type'] = 'flg_'
                                fileInfoChanged = True
                            elif stringMatch(lineVals[2].lower(), 'flaginit'):
                                fileInfo[fileKey]['type'] = 'flaginit'
                                fileInfoChanged = True
                            elif stringMatch(lineVals[2].lower(), 'identity'):
                                fileInfo[fileKey]['type'] = 'identity'
                                fileInfoChanged = True
                            elif stringMatch(lineVals[2].lower(), 'party'):
                                fileInfo[fileKey]['type'] = 'party'
                                fileInfoChanged = True
                            else:
                                print(lineVals)
                        else:
                            print(lineVals[2].lower())
                    pass
                elif stringMatch(lineVals[1].lower(), 'dosbox'):
                    pass
                elif stringMatch(lineVals[1].lower(), '!downloads'):
                    pass
                else:
                    print(lineVals[1])
                #pass
                #print(len(lineVals))
                #print(lineVals)
    if fileInfoChanged is True:
        yamlWrite(fileInfoPath, fileInfo)


def gameFiles(gameName):
    fileList = []
    filesRoot = ''
    diskRoot = f'{filesRoot}disks/U7BG/ULTIMA7/'
    fileInfoPath = 'u7.fileInfo.yaml'
    fileInfo = None
    fileInfoChanged = False
    hashKeep = {}
    dataTypes = []
    if os.path.exists(fileInfoPath):
        fileInfo = yamlRead('u7.fileInfo.yaml')
    if fileInfo is None:
        fileInfo = {}
        fileInfoChanged = True
    for fileKey in fileInfo:
        lineVals = fileKey.split('/')
        #print(fileInfo[fileKey])
        fileGame = dictGetValue(fileInfo[fileKey], 'game')
        #fileType = dictGetValue(fileInfo[fileKey], 'type')
        if stringMatch(gameName, fileGame):
            listAdd(fileList, fileKey)
    for fileKey in sorted(fileList):
        fileType = dictGetValue(fileInfo[fileKey], 'type')
        fileMD5 = dictGetValue(fileInfo[fileKey], 'md5hash')
        fileCompare = dictGetValue(fileInfo[fileKey], 'compare')
        if stringMatch(fileType, 'ignore'):
            pass
        else:
            filePath = '{0}{1}'.format(filesRoot, fileKey)
            print('{0} [{1}]'.format(fileKey, fileType))
            fileFW = FileWerks(filePath)
            if fileFW.exists is True:
                if fileMD5 is None:
                    fileInfo[fileKey]['md5hash'] = fileFW.getMd5Hash()
                    fileInfoChanged = True
                    fileMD5 = dictGetValue(fileInfo[fileKey], 'md5hash')
                #print('  {0}'.format(fileMD5))
                if stringMatchStart(fileKey, 'Ultima 7/'):
                    fileOfs = stringStripStart(fileKey, 'Ultima 7/')
                    diskPath = '{0}{1}'.format(diskRoot, fileOfs)
                    diskFW = FileWerks(diskPath)
                    if diskFW.exists is True:
                        diskMD5 = diskFW.getMd5Hash()
                        if stringMatch(fileMD5, diskMD5):
                            print('  MATCHED MD5')
                            if fileCompare is None:
                                fileInfo[fileKey]['compare'] = 'matched'
                                fileInfoChanged = True
                            pass
                        else:
                            print('  MISMATCHED MD5')
                            print('  {0}'.format(fileMD5))
                            print('  {0}'.format(diskMD5))
                            if fileCompare is None:
                                fileInfo[fileKey]['compare'] = diskMD5
                                fileInfoChanged = True
                    else:
                        print('  {0}'.format(fileMD5))
                        if fileCompare is None:
                            fileInfo[fileKey]['compare'] = 'notfound'
                            fileInfoChanged = True
                    if fileMD5 is not None:
                        if fileCompare is not None:
                            if stringMatch(fileCompare, 'notfound'):
                                pass
                            else:
                                if stringMatch(fileType, 'xmi_'):
                                    pass
                                elif stringMatch(fileType, 'ad_xmidi'):
                                    pass
                                elif stringMatch(fileType, 'mt_xmidi'):
                                    pass
                                elif stringMatch(fileType, 'adv_adlib'):
                                    pass
                                elif stringMatch(fileType, 'adv_mt32mpu'):
                                    pass
                                elif stringMatch(fileType, 'adv_sbdig'):
                                    pass
                                elif stringMatch(fileType, 'dat_intrordm'):
                                    pass
                                elif stringMatch(fileType, 'dat_introsound'):
                                    pass
                                elif stringMatch(fileType, 'dat_mt32mus'):
                                    pass
                                elif stringMatch(fileType, 'dat_mt32sfx'):
                                    pass
                                elif stringMatch(fileType, 'dat_wgtvol'):
                                    pass
                                elif stringMatch(fileType, 'dat_wihh'):
                                    pass
                                elif stringMatch(fileType, 'drv_strax'):
                                    pass
                                elif stringMatch(fileType, 'linkdep1'):
                                    pass
                                elif stringMatch(fileType, 'linkdep2'):
                                    pass
                                elif stringMatch(fileType, 'speech'):
                                    pass
                                elif stringMatch(fileType, 'tbl_xform'):
                                    pass
                                elif stringMatch(fileType, 'tim_intro'):
                                    pass
                                elif stringMatch(fileType, 'executable'):
                                    pass
                                elif stringMatch(fileType, 'chunks'):
                                    pass
                                elif stringMatch(fileType, 'ifix'):
                                    pass
                                else:
                                    addLine = '{0} {1}'.format(fileKey, fileType)
                                    listAdd(dataTypes, fileType)
                                    if fileMD5 in hashKeep:
                                        listAdd(hashKeep[fileMD5], addLine)
                                    else:
                                        hashKeep[fileMD5] = [addLine]
    if fileInfoChanged is True:
        yamlWrite(fileInfoPath, fileInfo)
    for md5Key in hashKeep:
        print('{0}'.format(md5Key))
        for fileKey in hashKeep[md5Key]:
            print('  {0}'.format(fileKey))
    #for fileType in sorted(dataTypes):
    #    print(fileType)


chunkShapes = []


def getU7Chunk(chunkRef):
    chunkShapesYaml = 'data/U7BG/STATIC/U7CHUNK.shapes.{0:04d}.yaml'.format(chunkRef)
    if os.path.exists(chunkShapesYaml):
        return yamlRead(chunkShapesYaml)
    return None


def processU7Palette(paletteYaml):
    retObj = []
    blockWide = 8
    blockHigh = 24
    funcName = 'processU7Palette'
    mapInfo = None
    drawPalette = False
    seltarg = 'u7palette'
    outNum = 0
    finished = False
    outpath = 'process_u7palette.{0:04d}.png'.format(outNum)
    if drawPalette is True:
        while finished is False:
            outpath = 'process_u7palette.{0:04d}.png'.format(outNum)
            if os.path.exists(outpath):
                pass
            else:
                finished = True
            outNum += 1
    paletteDat = yamlRead(paletteYaml)
    for i in range(0, paletteDat['recordCount']):
        while len(retObj) < (i+1):
            retObj.append([])
        palette = paletteDat['record'][i]
        if isinstance(palette, tuple):
            for j in range(0, int(len(palette) / 3)):
                while len(retObj[i]) < (j+1):
                    retObj[i].append([0, 0, 0])
                yPos = i * blockHigh
                xPos = j * blockWide
                color = [palette[j*3], palette[(j*3)+1], palette[(j*3)+2], 255]
                if j < 255:
                    for k in range(0, 3):
                        if color[k] > 63:
                            print('PALETTE {0}, index {1}'.format(i, j))
                        else:
                            color[k] = int(4.047619047619047619047619047619 * float(color[k]))
                retObj[i][j] = list(color)
                if drawPalette is True:
                    for k in range(0, blockHigh):
                        for l in range(0, blockWide):
                            adddot(seltarg, [xPos+l, yPos+k], color, 1.0)
    #for key in paletteDat:
    #    print(key)
        #
    print(len(retObj))
    if drawPalette is True:
        print('saving file {0}'.format(outpath))
        ImageOperation('selsave {0} {1} a a 16 16 16'.format(seltarg, outpath))
    return retObj


def processU7Text(textYaml):
    retObj = []
    blockWide = 8
    blockHigh = 24
    funcName = 'processU7Text'
    mapInfo = None
    #seltarg = 'u7palette'
    outNum = 0
    finished = False
    #outpath = 'process_u7palette.{0:04d}.png'.format(outNum)
    #while finished is False:
    #    outpath = 'process_u7palette.{0:04d}.png'.format(outNum)
    #    if os.path.exists(outpath):
    #        pass
    #    else:
    #        finished = True
    #    outNum += 1
    textDat = yamlRead(textYaml)
    for i in range(0, textDat['recordCount']):
        while len(retObj) < (i+1):
            retObj.append([])
        textBin = textDat['record'][i]
        if isinstance(textBin, tuple):
            recordString = ''
            for val in textBin:
                if (val >= 32) and (val < 127):
                    #print(val)
                    recordString += '{0}'.format(chr(val))
                elif val == 9:
                    recordString += '    '
                elif val == 0:
                    pass
                else:
                    print(val)
            #print('[{0}] [{1}]'.format(i, recordString))
            if len(recordString) > 0:
                retObj[i] = recordString
            #textVal = ''
            #for j in range(0, len(textBin)):
            #    print(textBin[j])
    #print(len(retObj))
    return retObj


def processU7RawChunk(chunkRef):
    global chunkShapes
    chunkRefYaml = 'data/U7BG/STATIC/U7CHUNK.raw.{0:04d}.yaml'.format(chunkRef)
    chunkShapesYaml = 'data/U7BG/STATIC/U7CHUNK.shapes.{0:04d}.yaml'.format(chunkRef)
    chunkRefShapes = []
    if os.path.exists(chunkShapesYaml):
        return
    if os.path.exists(chunkRefYaml):
        chunkDat = yamlRead(chunkRefYaml)
        #print(type(chunkDat))
        if isinstance(chunkDat, list):
            #print(len(chunkDat))
            refIndex = 0
            for chunkShort in chunkDat:
                byte2 = (chunkShort & 255)
                byte1 = (chunkShort >> 8)
                #byte2 = 256 * ((chunkShort >> 8) & 3)
                #shapenum = data[i+3] + 256*(data[i+4] & 3)
                
                ## original order?
                #shapenum = byte1 + (256 * (byte2 & 3))
                #framenum = (byte2 >> 2)
                ## reverse order
                mantissa = byte1 >> 7
                shapenum = byte2 + (256 * (byte1 & 3))
                framenum = (byte1 >> 2) & 31
                chunkRefShape = {}
                chunkRefShape['flag'] = mantissa
                chunkRefShape['shapeNum'] = shapenum
                chunkRefShape['frameNum'] = framenum
                #print('{0} | {1} | {2}'.format(chunkRef, byte1, byte2))
                interesting = True
                if shapenum <= 149:
                    interesting = False
                if shapenum == 179:
                    ## lightning
                    interesting = False
                elif shapenum == 181:
                    ## tree
                    interesting = False
                elif shapenum == 184:
                    ## cadelite meteor
                    interesting = False
                elif shapenum == 185:
                    ## dead tree
                    interesting = False
                elif shapenum == 191:
                    ## fortress
                    interesting = False
                elif shapenum == 192:
                    ## fortress
                    interesting = False
                elif shapenum == 195:
                    ## mountain
                    interesting = False
                elif shapenum == 196:
                    ## mountain
                    interesting = False
                elif shapenum == 197:
                    ## mountain
                    interesting = False
                elif shapenum == 205:
                    ## wall
                    interesting = False
                elif shapenum == 216:
                    ## broken wall
                    interesting = False
                elif shapenum == 217:
                    ## broken wall
                    interesting = False
                elif shapenum == 218:
                    ## broken wall
                    interesting = False
                elif shapenum == 253:
                    ## 
                    interesting = False
                elif shapenum == 254:
                    ## 
                    interesting = False
                elif shapenum == 255:
                    ## 
                    interesting = False
                elif shapenum == 256:
                    ## 
                    interesting = False
                elif shapenum == 260:
                    ## 
                    interesting = False
                elif shapenum == 263:
                    ## 
                    interesting = False
                elif shapenum == 266:
                    ## 
                    interesting = False
                elif shapenum == 273:
                    ## 
                    interesting = False
                elif shapenum == 279:
                    ## 
                    interesting = False
                elif shapenum == 302:
                    ## 
                    interesting = False
                elif shapenum == 306:
                    ## evergreen
                    interesting = False
                elif shapenum == 308:
                    ## 
                    interesting = False
                elif shapenum == 309:
                    ## 
                    interesting = False
                elif shapenum == 310:
                    ## 
                    interesting = False
                elif shapenum == 313:
                    ## 
                    interesting = False
                elif shapenum == 314:
                    ## weeds
                    interesting = False
                elif shapenum == 315:
                    ## 
                    interesting = False
                elif shapenum == 316:
                    ## 
                    interesting = False
                elif shapenum == 320:
                    ## 
                    interesting = False
                elif shapenum == 321:
                    ## 
                    interesting = False
                elif shapenum == 323:
                    ## cattails
                    interesting = False
                elif shapenum == 325:
                    ## 
                    interesting = False
                elif shapenum == 326:
                    ## 
                    interesting = False
                elif shapenum == 327:
                    ## 
                    interesting = False
                elif shapenum == 328:
                    ## 
                    interesting = False
                elif shapenum == 331:
                    ## rock
                    interesting = False
                elif shapenum == 332:
                    ## 
                    interesting = False
                elif shapenum == 334:
                    ## 
                    interesting = False
                elif shapenum == 335:
                    ## 
                    interesting = False
                elif shapenum == 341:
                    ## rock
                    interesting = False
                elif shapenum == 342:
                    ## 
                    interesting = False
                elif shapenum == 343:
                    ## 
                    interesting = False
                elif shapenum == 344:
                    ## 
                    interesting = False
                elif shapenum == 345:
                    ## 
                    interesting = False
                elif shapenum == 346:
                    ## 
                    interesting = False
                elif shapenum == 347:
                    ## 
                    interesting = False
                elif shapenum == 348:
                    ## 
                    interesting = False
                elif shapenum == 349:
                    ## 
                    interesting = False
                elif shapenum == 350:
                    ## 
                    interesting = False
                elif shapenum == 351:
                    ## 
                    interesting = False
                elif shapenum == 352:
                    ## 
                    interesting = False
                elif shapenum == 355:
                    ## 
                    interesting = False
                elif shapenum == 356:
                    ## 
                    interesting = False
                elif shapenum == 357:
                    ## 
                    interesting = False
                elif shapenum == 358:
                    ## 
                    interesting = False
                elif shapenum == 359:
                    ## 
                    interesting = False
                elif shapenum == 362:
                    ## 
                    interesting = False
                elif shapenum == 371:
                    ## 
                    interesting = False
                elif shapenum == 373:
                    ## 
                    interesting = False
                elif shapenum == 374:
                    ## 
                    interesting = False
                elif shapenum == 384:
                    ## 
                    interesting = False
                elif shapenum == 389:
                    ## 
                    interesting = False
                elif shapenum == 390:
                    ## 
                    interesting = False
                elif shapenum == 391:
                    ## 
                    interesting = False
                elif shapenum == 393:
                    ## wall
                    interesting = False
                elif shapenum == 395:
                    ## 
                    interesting = False
                elif shapenum == 396:
                    ## 
                    interesting = False
                elif shapenum == 404:
                    ## 
                    interesting = False
                elif shapenum == 419:
                    ## 
                    interesting = False
                elif shapenum == 423:
                    ## 
                    interesting = False
                elif shapenum == 425:
                    ## 
                    interesting = False
                elif shapenum == 453:
                    ## tree
                    interesting = False
                elif shapenum == 497:
                    ## 
                    interesting = False
                elif shapenum == 516:
                    ## 
                    interesting = False
                elif shapenum == 531:
                    ## 
                    interesting = False
                elif shapenum == 610:
                    ## 
                    interesting = False
                elif shapenum == 611:
                    ## 
                    interesting = False
                elif shapenum == 612:
                    ## waves
                    interesting = False
                elif shapenum == 613:
                    ## waves
                    interesting = False
                elif shapenum == 619:
                    ## 
                    interesting = False
                elif shapenum == 631:
                    ## 
                    interesting = False
                elif shapenum == 632:
                    ## waves
                    interesting = False
                elif shapenum == 669:
                    ## 
                    interesting = False
                elif shapenum == 670:
                    ## 
                    interesting = False
                elif shapenum == 672:
                    ## 
                    interesting = False
                elif shapenum == 673:
                    ## 
                    interesting = False
                elif shapenum == 674:
                    ## 
                    interesting = False
                elif shapenum == 683:
                    ## 
                    interesting = False
                elif shapenum == 694:
                    ## 
                    interesting = False
                elif shapenum == 699:
                    ## waves
                    interesting = False
                elif shapenum == 736:
                    ## 
                    interesting = False
                elif shapenum == 737:
                    ## 
                    interesting = False
                elif shapenum == 751:
                    ## 
                    interesting = False
                elif shapenum == 780:
                    ## 
                    interesting = False
                elif shapenum == 808:
                    ## 
                    interesting = False
                elif shapenum == 817:
                    ## 
                    interesting = False
                elif shapenum == 834:
                    ## 
                    interesting = False
                elif shapenum == 853:
                    ## 
                    interesting = False
                elif shapenum == 875:
                    ## 
                    interesting = False
                elif shapenum == 905:
                    ## 
                    interesting = False
                elif shapenum == 907:
                    ## 
                    interesting = False
                elif shapenum == 911:
                    ## 
                    interesting = False
                elif shapenum == 918:
                    ## 
                    interesting = False
                elif shapenum == 922:
                    ## small bush
                    interesting = False
                elif shapenum == 924:
                    ## 
                    interesting = False
                elif shapenum == 925:
                    ## 
                    interesting = False
                elif shapenum == 926:
                    ## 
                    interesting = False
                elif shapenum == 927:
                    ## 
                    interesting = False
                elif shapenum == 928:
                    ## 
                    interesting = False
                elif shapenum == 930:
                    ## 
                    interesting = False
                elif shapenum == 938:
                    ## 
                    interesting = False
                elif shapenum == 939:
                    ## wall
                    interesting = False
                elif shapenum == 940:
                    ## wall
                    interesting = False
                elif shapenum == 943:
                    ## wall
                    interesting = False
                elif shapenum == 953:
                    ## wall
                    interesting = False
                elif shapenum == 967:
                    ## 
                    interesting = False
                elif shapenum == 972:
                    ## 
                    interesting = False
                elif shapenum == 980:
                    ## wall
                    interesting = False
                elif shapenum == 985:
                    ## 
                    interesting = False
                elif shapenum == 996:
                    ## 
                    interesting = False
                elif shapenum == 1005:
                    ## 
                    interesting = False
                elif shapenum == 1006:
                    ## 
                    interesting = False
                elif shapenum == 1007:
                    ## 
                    interesting = False
                elif shapenum == 1008:
                    ## 
                    interesting = False
                elif shapenum == 1009:
                    ## 
                    interesting = False
                elif shapenum == 1012:
                    ## wall
                    interesting = False
                elif shapenum == 1019:
                    ## 
                    interesting = False
                elif shapenum == 1020:
                    ## 
                    interesting = False
                elif shapenum == 1022:
                    ## 
                    interesting = False
                if interesting is True:
                    print(chunkShort)
                    print('{0}'.format(bytestr_to_binstr(chunkShort.to_bytes(2, 'big'))))
                    print('{0}'.format(bytestr_to_binstr(byte1.to_bytes(2, 'big'))))
                    print('{0}'.format(bytestr_to_binstr(byte2.to_bytes(2, 'big'))))
                    print('Shape {0}, frame {1}'.format(shapenum, framenum))
                    print('{0}'.format(bytestr_to_binstr(shapenum.to_bytes(2, 'big'))))
                    print('{0}'.format(bytestr_to_binstr(framenum.to_bytes(2, 'big'))))
                    print('{0}'.format(bytestr_to_binstr(mantissa.to_bytes(2, 'big'))))
                    if shapenum in chunkShapes:
                        pass
                    else:
                        listAdd(chunkShapes, shapenum)
                chunkRefShapes.append(chunkRefShape)
                refIndex += 1
            yamlWrite(chunkShapesYaml, chunkRefShapes)
        


def processU7Chunks(yamlPath):
    funcName = 'processU7Chunks'
    chunkInfo = None
    #seltarg = 'u7map'
    #outpath = 'process_u7map.png'
    yamlFW = FileWerks(yamlPath)
    if yamlFW.exists is True:
        chunkInfo = yamlRead(yamlPath)
    if chunkInfo is not None:
        chunkRefs = dictGetValue(chunkInfo, 'chunkRefs')
        print(type(chunkRefs))
        if isinstance(chunkRefs, list):
            print(len(chunkRefs))
            for i in range(0, len(chunkRefs)):
                chunkRef = list(chunkRefs[i])
                print('[{0}] {1}: {2}'.format(funcName, i, len(chunkRef)))
                chunkRefYaml = 'data/U7BG/STATIC/U7CHUNK.raw.{0:04d}.yaml'.format(i)
                print(chunkRefYaml)
                yamlWrite(chunkRefYaml, chunkRef)



def processU7Map(yamlPath):
    funcName = 'processU7Map'
    mapInfo = None
    seltarg = 'u7map'
    outNum = 0
    finished = False
    outpath = 'process_u7map.{0:04d}.png'.format(outNum)
    while finished is False:
        outpath = 'process_u7map.{0:04d}.png'.format(outNum)
        if os.path.exists(outpath):
            pass
        else:
            finished = True
        outNum += 1
    yamlFW = FileWerks(yamlPath)
    if yamlFW.exists is True:
        mapInfo = yamlRead(yamlPath)
    if mapInfo is not None:
        #print('yass')
        for key in mapInfo:
            print(key)
            schunkList = dictGetValue(mapInfo, 'schunk')
            #print(type(schunkList))
            chunksLandUpdate = False
            chunksWaterUpdate = False
            landChunks = []
            waterChunks = []
            missedChunks = []
            if 0:
                if os.path.exists('chunksLand.yaml'):
                    landChunks = yamlRead('chunksLand.yaml')
                else:
                    landChunks.append(8)
                    landChunks.append(9)
                    landChunks.append(11)
                    landChunks.append(15)
                    landChunks.append(35)
                    landChunks.append(42)
                    landChunks.append(58)
                    landChunks.append(63)
                    landChunks.append(81)
                    landChunks.append(87)
                    landChunks.append(96)
                    landChunks.append(101)
                    landChunks.append(102)
                    landChunks.append(1164)
                    landChunks.append(1165)
                    landChunks.append(1794)
                    landChunks.append(1797)
                    landChunks.append(1798)
                    landChunks.append(1825)
                    landChunks.append(1826)
                    landChunks.append(1827)
                    landChunks.append(1828)
                    landChunks.append(1829)
                    landChunks.append(1830)
                    landChunks.append(2191)
                    landChunks.append(2193)
                    landChunks.append(2585)
                    landChunks.append(2586)
                    landChunks.append(2682)
                    landChunks.append(22)
                    landChunks.append(24)
                    landChunks.append(25)
                    landChunks.append(32)
                    landChunks.append(33)
                    landChunks.append(39)
                    landChunks.append(80)
                    landChunks.append(82)
                    landChunks.append(108)
                    landChunks.append(115)
                    landChunks.append(141)
                    landChunks.append(156)
                    landChunks.append(736)
                    landChunks.append(737)
                    landChunks.append(742)
                    landChunks.append(743)
                    landChunks.append(745)
                    landChunks.append(912)
                    landChunks.append(1155)
                    landChunks.append(1156)
                    landChunks.append(1157)
                    landChunks.append(1158)
                    landChunks.append(1159)
                    landChunks.append(1855)
                    landChunks.append(2024)
                    landChunks.append(2030)
                    landChunks.append(2035)
                    landChunks.append(2074)
                    landChunks.append(2580)
                    landChunks.append(2582)
                    landChunks.append(2583)
                    landChunks.append(2650)
                    landChunks.append(2651)
                    landChunks.append(2652)
                    landChunks.append(2653)
                    landChunks.append(2654)
                    landChunks.append(2655)
                    landChunks.append(2680)
                    landChunks.append(2696)
                    landChunks.append(2697)
                    landChunks.append(2698)
                    landChunks.append(2699)
                    landChunks.append(2700)
                    landChunks.append(2701)
                    landChunks.append(2702)
                    landChunks.append(2725)
                    landChunks.append(2823)
                    landChunks.append(2914)
                    landChunks.append(2916)
                    landChunks.append(2917)
                    landChunks.append(48)
                    landChunks.append(50)
                    landChunks.append(12)
                    landChunks.append(105)
                    landChunks.append(111)
                    landChunks.append(259)
                    landChunks.append(264)
                    landChunks.append(267)
                    landChunks.append(320)
                    landChunks.append(321)
                    landChunks.append(322)
                    landChunks.append(323)
                    landChunks.append(324)
                    landChunks.append(326)
                    landChunks.append(336)
                    landChunks.append(342)
                    landChunks.append(343)

                if os.path.exists('chunksWater.yaml'):
                    waterChunks = yamlRead('chunksWater.yaml')
                else:
                    waterChunks.append(0)
                    waterChunks.append(4)
                    waterChunks.append(5)
                    waterChunks.append(6)
                    waterChunks.append(45)
                    waterChunks.append(47)
                    waterChunks.append(53)
                    waterChunks.append(55)
                    waterChunks.append(56)
                    waterChunks.append(61)
                    waterChunks.append(64)
                    waterChunks.append(69)
                    waterChunks.append(260)
                    waterChunks.append(285)
                    waterChunks.append(286)
                    waterChunks.append(287)
                    waterChunks.append(909)
                    waterChunks.append(1580)
                    waterChunks.append(1581)
                    waterChunks.append(1582)
                    waterChunks.append(1583)
                    waterChunks.append(2023)
                    waterChunks.append(2136)
                    waterChunks.append(2137)
                    waterChunks.append(2138)
                    waterChunks.append(2667)
                    waterChunks.append(2670)
                    waterChunks.append(2940)
                    waterChunks.append(2941)
                    waterChunks.append(2942)
                    waterChunks.append(2943)
                    waterChunks.append(2956)
                    waterChunks.append(2957)
                    waterChunks.append(2958)
                    waterChunks.append(2959)
                    waterChunks.append(3008)
                    waterChunks.append(3009)
                    waterChunks.append(3010)
                    waterChunks.append(3011)
                    waterChunks.append(3012)
                    waterChunks.append(3013)
                    waterChunks.append(3014)
                    waterChunks.append(3015)
                    waterChunks.append(3029)
                    waterChunks.append(3035)
                    waterChunks.append(3036)
                    waterChunks.append(3045)
            if isinstance(schunkList, list):
                print(len(schunkList))
                schunkX = 0
                schunkY = 0
                for schunkId in range(0, len(schunkList)):
                    print('SChunkId is {0}'.format(schunkId))
                    schunk = schunkList[schunkId]
                    schunkX = schunkId % 12
                    if schunkX == 0:
                        if schunkId > 0:
                            schunkY += 1
                    #print(type(schunk))
                    #print(len(schunk))
                    if isinstance(schunk, tuple):
                        #print('ok')
                        chunkRefNum = 0
                        chunkY = -1
                        for chunkRef in schunk:
                            #print(chunkRef)
                            chunkX = chunkRefNum % 16
                            if chunkX == 0:
                                chunkY += 1
                                print('  row {0}'.format(chunkY))
                            byte1 = chunkRef | 255
                            byte2 = chunkRef | (255 << 8)
                            if schunkId == 53:
                                if chunkRef > 0:
                                    if chunkRef in waterChunks:
                                        pass
                                    elif chunkRef in landChunks:
                                        pass
                                    else:
                                        #print('landChunks.append({0})'.format(chunkRef))
                                        #print('{0} | {1} | {2}'.format(chunkRef, byte1, byte2))
                                        #print('{0}'.format(bytestr_to_binstr(chunkRef.to_bytes(2, 'big'))))
                                        #print('{0}'.format(bytestr_to_binstr(byte1.to_bytes(2, 'big'))))
                                        #print('{0}'.format(bytestr_to_binstr(byte2.to_bytes(2, 'big'))))
                                        if chunkRef in missedChunks:
                                            pass
                                        else:
                                            missedChunks.append(chunkRef)
                            #shapenum = data[val] + 256*(data[val+1] & 3)
                            #framenum = (data[val+1] >> 2) % 32
                            chunkShapes = None
                            if chunkRef < 3073:
                                chunkShapes = getU7Chunk(chunkRef)
                            chunkHandled = False
                            if 0:
                                if chunkRef in waterChunks:
                                    adddot(seltarg, [(schunkX * 16) + chunkX, (schunkY * 16) + chunkY], [0, 32, 192, 255], 0.5)
                                    chunkHandled = True
                                elif chunkRef in landChunks:
                                    adddot(seltarg, [(schunkX * 16) + chunkX, (schunkY * 16) + chunkY], [32, 192, 32, 255], 0.5)
                                    chunkHandled = True
                                else:
                                    if chunkRef in missedChunks:
                                        pass
                                    else:
                                        missedChunks.append(chunkRef)
                                    if chunkX == 0:
                                        #adddot(seltarg, [(schunkX * 16) + chunkX, (schunkY * 16) + chunkY], [96, 96, 96, 255], 0.5)
                                        pass
                                    else:
                                        if chunkY == 0:
                                            #adddot(seltarg, [(schunkX * 16) + chunkX, (schunkY * 16) + chunkY], [96, 96, 96, 255], 0.5)
                                            pass
                            schunkPosX = schunkX * 256
                            chunkPosX = chunkX * 16
                            schunkPosY = schunkY * 256
                            chunkPosY = chunkY * 16
                            if chunkPosX == 0:
                                adddot(seltarg, [schunkPosX + chunkPosX, schunkPosY + chunkPosY], [96, 96, 96, 255], 0.5)
                                pass
                            else:
                                if chunkPosY == 0:
                                    adddot(seltarg, [schunkPosX + chunkPosX, schunkPosY + chunkPosY], [96, 96, 96, 255], 0.5)
                                    pass
                            if chunkShapes is not None:
                                refPosX = 0
                                refPosY = -1
                                for shapePos in range(0, 256):
                                    refPosX = shapePos % 16
                                    if refPosX == 0:
                                        refPosY += 1
                                    flag = dictGetValue(chunkShapes[shapePos], 'flag')
                                    if flag == 0:
                                        pass
                                    elif flag == 1:
                                        adddot(seltarg, [schunkPosX + chunkPosX + refPosX, schunkPosY + chunkPosY + refPosY], [0, 32, 192, 255], 0.5)
                                    else:
                                        adddot(seltarg, [schunkPosX + chunkPosX + refPosX, schunkPosY + chunkPosY + refPosY], [0, 192, 32, 255], 0.5)
                            #if chunkRef == 0:
                            #    adddot(seltarg, [(schunkX * 16) + chunkX, (schunkY * 16) + chunkY], [0, 32, 192, 255], 0.5)
                            #elif chunkRef == 4:
                            #    adddot(seltarg, [(schunkX * 16) + chunkX, (schunkY * 16) + chunkY], [0, 32, 192, 255], 0.5)
                            #elif chunkRef == 5:
                            #    adddot(seltarg, [(schunkX * 16) + chunkX, (schunkY * 16) + chunkY], [0, 32, 192, 255], 0.5)
                            #elif chunkRef == 6:
                            #    adddot(seltarg, [(schunkX * 16) + chunkX, (schunkY * 16) + chunkY], [0, 32, 192, 255], 0.5)
                            #if chunkRef == 55:
                            #    adddot(seltarg, [(schunkX * 16) + chunkX, (schunkY * 16) + chunkY], [0, 32, 192, 255], 0.5)
                            #elif chunkRef == 260:
                            #    adddot(seltarg, [(schunkX * 16) + chunkX, (schunkY * 16) + chunkY], [0, 32, 192, 255], 0.5)
                            #elif chunkRef == 285:
                            #    adddot(seltarg, [(schunkX * 16) + chunkX, (schunkY * 16) + chunkY], [0, 32, 192, 255], 0.5)
                            #elif chunkRef == 286:
                            #    adddot(seltarg, [(schunkX * 16) + chunkX, (schunkY * 16) + chunkY], [0, 32, 192, 255], 0.5)
                            #elif chunkRef == 1580:
                            #    adddot(seltarg, [(schunkX * 16) + chunkX, (schunkY * 16) + chunkY], [0, 32, 192, 255], 0.5)
                            #elif chunkRef == 2667:
                            #    adddot(seltarg, [(schunkX * 16) + chunkX, (schunkY * 16) + chunkY], [0, 32, 192, 255], 0.5)
                            #elif chunkRef == 2958:
                            #    adddot(seltarg, [(schunkX * 16) + chunkX, (schunkY * 16) + chunkY], [0, 32, 192, 255], 0.5)
                            if chunkHandled is False:
                                if schunkId == 0:
                                    #print(chunkRef)
                                    pass

                            chunkRefNum += 1
            ## this is to find missing chunks
            #for chunkRef in sorted(missedChunks):
            #    print('landChunks.append({0})'.format(chunkRef))
            #if chunksWaterUpdate is True:
            #    yamlWrite('chunksWater.yaml', sorted(waterChunks))
            #if chunksLandUpdate is True:
            #    yamlWrite('chunksLand.yaml', sorted(landChunks))
            #yamlWrite('chunksMissed.yaml', sorted(missedChunks))
    print('saving file {0}'.format(outpath))
    ImageOperation('selsave {0} {1} a a 16 16 16'.format(seltarg, outpath))


def readHex(filePath, keepOfs=0, jumpSize=16, outPath=None):
    outData = ''
    funcName = 'readHex'
    print('[{0}] init for path {1}'.format(funcName, filePath))
    fileFW = FileWerks(filePath)
    fileSize = fileFW.getSize()
    print('[{0}]   size {1}'.format(funcName, fileSize))
    #ireg_filesize = os.stat(ireg_path)[6]
    #print('ireg_read -> IREG: %s (%d bytes)' % (ireg_path, ireg_filesize))
    inf = openBinaryFileRead(filePath)
    data = []
    for i in range(0, fileSize):
        data.append(struct.unpack("B", inf.read(1))[0])
    if keepOfs > 0:
        if keepOfs >= fileSize:
            # default if we screw up the ofset size
            keepOfs = 0
            jumpSize = 16
        else:
            keeper = 0
            hexString = bytestr_to_hexstr(data[keeper:keeper+keepOfs])
            intString = bytestr_to_intstr(data[keeper:keeper+keepOfs])
            chrString = bytestr_to_charstr(data[keeper:keeper+keepOfs])
            outData += '{0}|{1}|{2}|\n'.format(hexString, intString, chrString)

    keeper = keepOfs
    #jumpSize = 21
    while keeper < fileSize:
        bytesCount = jumpSize
        bytesRemaining = fileSize - keeper
        if bytesRemaining < jumpSize:
            bytesCount = bytesRemaining
        hexString = bytestr_to_hexstr(data[keeper:keeper+bytesCount])
        #print(hexString)
        while len(hexString) < ((jumpSize * 3) - 1):
            hexString += ' '
        intString = bytestr_to_intstr(data[keeper:keeper+bytesCount])
        #print(hexString)
        while len(intString) < ((jumpSize * 4) - 1):
            intString += ' '
        #print(len(hexString))
        chrString = bytestr_to_charstr(data[keeper:keeper+bytesCount])
        while len(chrString) < jumpSize:
            chrString += ' '
        #print('{0}|{1}|{2}|'.format(hexString, intString, chrString))
        outData += '{0}|{1}|{2}|\n'.format(hexString, intString, chrString)
        keeper += jumpSize
    if outPath is not None:
        stringToFile(outPath, outData)
    #print(bytestr_to_hexstr(data[4:4]))
    inf.close()


def readU7TFA(filePath, yamlPath):
    funcName = 'readU7TFA'
    print('[{0}] init for path {1}'.format(funcName, filePath))
    fileFW = FileWerks(filePath)
    fileSize = fileFW.getSize()
    print('[{0}]   size {1}'.format(funcName, fileSize))
    retObj = {}
    inf = openBinaryFileRead(filePath)
    fmtTFA = "<{0}B".format(fileSize)
    binData = inf.read(struct.calcsize(fmtTFA))
    TFAData = struct.unpack(fmtTFA, binData)
    shapeCount = 1024
    if isinstance(TFAData, tuple):
        outString = ''
        pos = 0
        shapeNum = 0
        while(pos+3 < (shapeCount * 3)+1):
            #val = TFAData[pos]
            retObj[shapeNum] = {}
            retObj[shapeNum]['b1'] = TFAData[pos]
            retObj[shapeNum]['b2'] = TFAData[pos+1]
            retObj[shapeNum]['b3'] = TFAData[pos+2]
            #frameData = struct.unpack(fmt5UShort, tmpdata)
            retObj[shapeNum]['m_hasSoundEffect'] = retObj[shapeNum]['b1'] & 1
            retObj[shapeNum]['m_rotatable'] = (retObj[shapeNum]['b1'] >> 1) & 1
            retObj[shapeNum]['m_isAnimated'] = (retObj[shapeNum]['b1'] >> 2) & 1
            retObj[shapeNum]['m_isNotWalkable'] = (retObj[shapeNum]['b1'] >> 3) & 1
            retObj[shapeNum]['m_isWater'] = (retObj[shapeNum]['b1'] >> 4) & 1
            retObj[shapeNum]['m_height'] = (retObj[shapeNum]['b1'] >> 5) & 0x07
            retObj[shapeNum]['m_shapeType'] = (retObj[shapeNum]['b2'] >> 4) & 0x0F
            retObj[shapeNum]['m_isTrap'] = (retObj[shapeNum]['b2'] >> 8) & 1
            retObj[shapeNum]['m_isDoor'] = (retObj[shapeNum]['b2'] >> 9) & 1
            retObj[shapeNum]['m_isVehiclePart'] = (retObj[shapeNum]['b2'] >> 10) & 1
            retObj[shapeNum]['m_isNotSelectable'] = (retObj[shapeNum]['b2'] >> 11) & 1
            retObj[shapeNum]['m_width'] = ((retObj[shapeNum]['b3']) & 0x07) + 1
            retObj[shapeNum]['m_depth'] = ((retObj[shapeNum]['b3'] >> 3) & 0x07) + 1
            retObj[shapeNum]['m_isLightSource'] = (retObj[shapeNum]['b3'] >> 6) & 1
            retObj[shapeNum]['m_isTranslucent'] = (retObj[shapeNum]['b3'] >> 7) & 1
            retObj[shapeNum]['nib'] = None
		#TFAfile.read((char*)&weight, sizeof(char));
		#g_objectTable[i].m_weight = float(weight) / .10f;
		#unsigned char volume;
		#TFAfile.read((char*)&volume, sizeof(char));
		#g_objectTable[i].m_volume = float(volume);
            #[TFAData[pos], TFAData[pos+1]]
            #if (val >= 32) and (val < 127):
            #    #print(val)
            #    outString += '{0}'.format(chr(val))
            #elif val == 9:
            #    outString += '    '
            #elif val == 0:
            #    print(outString)
            #    outString = ''
            #else:
            #print(val)
            shapeNum += 1
            pos += 3
        shapeNum = 0
        while(pos < fileSize):
            binStr = bytestr_to_binstr([TFAData[pos]])
            nib1 = TFAData[pos] & 15
            nib2 = TFAData[pos] >> 4
            if TFAData[pos] > 0:
                #print(f'POS {pos} {TFAData[pos]} {binStr}')
                if(nib1) > 0:
                    #print(f'  {shapeNum}:{nib1}')
                    retObj[shapeNum]['nib'] = nib1
                if(nib2) > 0:
                    #print(f'  {shapeNum+1}:{nib2}')
                    retObj[shapeNum+1]['nib'] = nib2
            else:
                retObj[shapeNum]['nib'] = 0
                retObj[shapeNum+1]['nib'] = 0
            #print('ireg_read -> iChk[{0}]: BINARY({1})\t{2}'.format(cur_chunk, bytestr_to_binstr(data[i:i+skipper]), vals[0]))
            shapeNum += 2
            pos += 1
        print(outString)
        #retObj['headerString'] = headerData[0].decode('ascii')
        #print(retObj['headerString'])
    inf.close()
    yamlWrite(yamlPath, retObj)


def readU7WgtVol(filePath, yamlPath):
    funcName = 'readU7WgtVol'
    print('[{0}] init for path {1}'.format(funcName, filePath))
    fileFW = FileWerks(filePath)
    fileSize = fileFW.getSize()
    print('[{0}]   size {1}'.format(funcName, fileSize))
    retObj = {}
    inf = openBinaryFileRead(filePath)
    fmtWgtVol = "<{0}B".format(fileSize)
    binData = inf.read(struct.calcsize(fmtWgtVol))
    wgtvolData = struct.unpack(fmtWgtVol, binData)
    if isinstance(wgtvolData, tuple):
        outString = ''
        pos = 0
        shapeNum = 0
        while(pos < fileSize):
            #val = wgtvolData[pos]
            retObj[shapeNum] = {}
            retObj[shapeNum]['weight'] = wgtvolData[pos] * 0.10
            retObj[shapeNum]['volume'] = wgtvolData[pos+1]
            #retObj[shapeNum]['weight'] = struct.unpack('<f', binData[pos].to_bytes(4))[0]
            #retObj[shapeNum]['volume'] = struct.unpack('<f', binData[pos+1].to_bytes(4))[0]
		#wgtvolfile.read((char*)&weight, sizeof(char));
		#g_objectTable[i].m_weight = float(weight) / .10f;
		#unsigned char volume;
		#wgtvolfile.read((char*)&volume, sizeof(char));
		#g_objectTable[i].m_volume = float(volume);
            #[wgtvolData[pos], wgtvolData[pos+1]]
            #if (val >= 32) and (val < 127):
            #    #print(val)
            #    outString += '{0}'.format(chr(val))
            #elif val == 9:
            #    outString += '    '
            #elif val == 0:
            #    print(outString)
            #    outString = ''
            #else:
            #print(val)
            shapeNum += 1
            pos += 2
        print(outString)
        #retObj['headerString'] = headerData[0].decode('ascii')
        #print(retObj['headerString'])
    inf.close()
    yamlWrite(yamlPath, retObj)


def readU7Usecode(filePath, yamlPath):
    funcName = 'readU7Usecode'
    print('[{0}] init for path {1}'.format(funcName, filePath))
    fileFW = FileWerks(filePath)
    fileSize = fileFW.getSize()
    print('[{0}]   size {1}'.format(funcName, fileSize))
    retObj = {}
    inf = openBinaryFileRead(filePath)
    fmtUsecode = "<{0}B".format(fileSize)
    binData = inf.read(struct.calcsize(fmtUsecode))
    usecodeData = struct.unpack(fmtUsecode, binData)
    if isinstance(usecodeData, tuple):
        outString = ''
        for i in range(0, fileSize):
            val = usecodeData[i]
            if (val >= 32) and (val < 127):
                #print(val)
                outString += '{0}'.format(chr(val))
            elif val == 9:
                outString += '    '
            elif val == 0:
                print(outString)
                outString = ''
            else:
                print(val)
        print(outString)
        #retObj['headerString'] = headerData[0].decode('ascii')
        #print(retObj['headerString'])

def readU7Flex(filePath, yamlPath):
    funcName = 'readU7Flex'
    print('[{0}] init for path {1}'.format(funcName, filePath))
    fileFW = FileWerks(filePath)
    fileSize = fileFW.getSize()
    print('[{0}]   size {1}'.format(funcName, fileSize))
    retObj = {}
    #ireg_filesize = os.stat(ireg_path)[6]
    #print('ireg_read -> IREG: %s (%d bytes)' % (ireg_path, ireg_filesize))
    inf = openBinaryFileRead(filePath)
    fmtHeader = "<80s"
    fmtUWord = "<1I"
    fmt2UWord = "<2I"
    fmtID3 = "<36B"
    #fmt_chunk = "<512B"
    ## header
    retObj['headerString'] = None
    retObj['id1'] = None
    retObj['id2'] = None
    retObj['id3'] = None
    retObj['recordCount'] = None
    retObj['recordInfo'] = []
    retObj['record'] = []

    binData = inf.read(struct.calcsize(fmtHeader))
    headerData = struct.unpack(fmtHeader, binData)
    ## 

    if isinstance(headerData, tuple):
        retObj['headerString'] = headerData[0].decode('ascii')
        print(retObj['headerString'])
    
    binData = inf.read(struct.calcsize(fmtUWord))
    data = struct.unpack(fmtUWord, binData)
    if isinstance(data, tuple):
        retObj['id1'] = data[0]
    binData = inf.read(struct.calcsize(fmtUWord))
    data = struct.unpack(fmtUWord, binData)
    if isinstance(data, tuple):
        retObj['recordCount'] = data[0]
    binData = inf.read(struct.calcsize(fmtUWord))
    data = struct.unpack(fmtUWord, binData)
    if isinstance(data, tuple):
        retObj['id2'] = data[0]
    binData = inf.read(struct.calcsize(fmtID3))
    data = struct.unpack(fmtID3, binData)
    if isinstance(data, tuple):
        retObj['id3'] = data
    if isinstance(retObj['recordCount'], int):
        for i in range(0, retObj['recordCount']):
            while len(retObj['recordInfo']) <= i:
                retObj['recordInfo'].append({})
            retObj['recordInfo'][i]['ofs'] = 0
            retObj['recordInfo'][i]['len'] = 0
            while len(retObj['record']) <= i:
                retObj['record'].append(None)
            ## populate offset info
            binData = inf.read(struct.calcsize(fmt2UWord))
            data = struct.unpack(fmt2UWord, binData)
            if isinstance(data, tuple):
                retObj['recordInfo'][i]['ofs'] = data[0]
                retObj['recordInfo'][i]['len'] = data[1]
        for i in range(0, retObj['recordCount']):
            if retObj['recordInfo'][i]['len'] > 0:
                if retObj['recordInfo'][i]['ofs'] < fileSize:
                    inf.seek(retObj['recordInfo'][i]['ofs'])
                    fmtBlob = "<{0}B".format(retObj['recordInfo'][i]['len'])
                    if (retObj['recordInfo'][i]['ofs'] + retObj['recordInfo'][i]['len']) <= fileSize:
                        binData = inf.read(struct.calcsize(fmtBlob))
                        data = struct.unpack(fmtBlob, binData)
                        if isinstance(data, tuple):
                            retObj['record'][i] = data
                            if 0:
                                recordString = ''
                                for val in data:
                                    if (val >= 32) and (val < 127):
                                        #print(val)
                                        recordString += '{0}'.format(chr(val))
                                    elif val == 9:
                                        recordString += '    '
                                    elif val == 0:
                                        pass
                                    else:
                                        print(val)
                                print('[{0}] [{1}]'.format(i, recordString))
                    else:
                        print('offset and data requested larger than filesize {0}'.format(fileSize))


    if 0:
        data = []
        numChunkRefs = int(fileSize / 512)
        print(numChunkRefs)
        fmtSChunk = "<256H"
        retObj['chunkRefs'] = []
        for i in range(0, numChunkRefs):
            binData = inf.read(struct.calcsize(fmtSChunk))
            data = struct.unpack(fmtSChunk, binData)
            retObj['chunkRefs'].append(data)
    inf.close()
    yamlWrite(yamlPath, retObj)


def readU7Shapes(filePath, yamlPath):
    funcName = 'readU7Shapes'
    print('[{0}] init for path {1}'.format(funcName, filePath))
    fileFW = FileWerks(filePath)
    fileSize = fileFW.getSize()
    print('[{0}]   size {1}'.format(funcName, fileSize))
    paletteData = processU7Palette('data/data/u7/STATIC/PALETTES.FLX.yaml')
    imgPrefix = 'shape'
    if stringMatchEnd(filePath.lower(), 'fonts.vga'):
        imgPrefix = 'font'
    elif stringMatchEnd(filePath.lower(), 'faces.vga'):
        imgPrefix = 'face'
    elif stringMatchEnd(filePath.lower(), 'gumps.vga'):
        imgPrefix = 'gump'
    elif stringMatchEnd(filePath.lower(), 'shapes.vga'):
        imgPrefix = 'shape'
    elif stringMatchEnd(filePath.lower(), 'sprites.vga'):
        imgPrefix = 'sprite'
    outPath = 'out/img/{0}'.format(imgPrefix)
    if os.path.isdir(outPath) is False:
        os.makedirs(outPath)
    retObj = {}
    #ireg_filesize = os.stat(ireg_path)[6]
    #print('ireg_read -> IREG: %s (%d bytes)' % (ireg_path, ireg_filesize))
    inf = openBinaryFileRead(filePath)
    fmtHeader = "<80s"
    fmtUWord = "<1I"
    fmt2UWord = "<2I"
    fmt5UShort = "<5H"
    fmt2Short = "<2h"
    fmt1UByte = "<1B"
    fmtID3 = "<36B"
    #fmt_chunk = "<512B"
    ## header
    retObj['headerString'] = None
    retObj['id1'] = None
    retObj['id2'] = None
    retObj['id3'] = None
    retObj['recordCount'] = None
    retObj['recordInfo'] = []
    retObj['record'] = []
    shapes = []
    shapeNum = 3

    binData = inf.read(struct.calcsize(fmtHeader))
    headerData = struct.unpack(fmtHeader, binData)
    ## 

    if isinstance(headerData, tuple):
        retObj['headerString'] = headerData[0].decode('ascii')
        print(retObj['headerString'])
    
    binData = inf.read(struct.calcsize(fmtUWord))
    data = struct.unpack(fmtUWord, binData)
    if isinstance(data, tuple):
        retObj['id1'] = data[0]
    binData = inf.read(struct.calcsize(fmtUWord))
    data = struct.unpack(fmtUWord, binData)
    if isinstance(data, tuple):
        retObj['recordCount'] = data[0]
    binData = inf.read(struct.calcsize(fmtUWord))
    data = struct.unpack(fmtUWord, binData)
    if isinstance(data, tuple):
        retObj['id2'] = data[0]
    binData = inf.read(struct.calcsize(fmtID3))
    data = struct.unpack(fmtID3, binData)
    if isinstance(data, tuple):
        retObj['id3'] = data
    if isinstance(retObj['recordCount'], int):
        for i in range(0, retObj['recordCount']):
            while len(retObj['recordInfo']) <= i:
                retObj['recordInfo'].append({})
            retObj['recordInfo'][i]['ofs'] = 0
            retObj['recordInfo'][i]['len'] = 0
            while len(retObj['record']) <= i:
                retObj['record'].append(None)
                shapes.append({})
            ## populate offset info
            binData = inf.read(struct.calcsize(fmt2UWord))
            data = struct.unpack(fmt2UWord, binData)
            if isinstance(data, tuple):
                retObj['recordInfo'][i]['ofs'] = data[0]
                retObj['recordInfo'][i]['len'] = data[1]
        #for i in range(0, retObj['recordCount']):
        for i in range(0, retObj['recordCount']):
            if retObj['recordInfo'][i]['len'] > 0:
                print('[{0}] shapeNum {1}'.format(funcName, i))
                if retObj['recordInfo'][i]['ofs'] < fileSize:
                    inf.seek(retObj['recordInfo'][i]['ofs'])
                    fmtBlob = "<{0}B".format(retObj['recordInfo'][i]['len'])
                    if (retObj['recordInfo'][i]['ofs'] + retObj['recordInfo'][i]['len']) <= fileSize:
                        ofsformat = "<2I"
                        #keepos = retObj['recordInfo'][i]['ofs']
                        tmpdata = inf.read(struct.calcsize(ofsformat))
                        data = struct.unpack(ofsformat, tmpdata)
                        print('  Read at OFS {0}: {1}, len for data is {2}'.format(retObj['recordInfo'][i]['ofs'], data, retObj['recordInfo'][i]['len']))
                        if data[0] == retObj['recordInfo'][i]['len']:
                            shapes[i]['numFrames'] = int(data[1] / 4) - 1
                            print('  numFrames: {0}'.format(shapes[i]['numFrames']))
                            for j in range(0, shapes[i]['numFrames']):
                                if 'frames' in shapes[i]:
                                    pass
                                else:
                                    shapes[i]['frames'] = []
                                shapes[i]['frames'].append({})
                                shapes[i]['frames'][j]['ofset'] = 0
                                shapes[i]['frames'][j]['yAbove'] = None
                                shapes[i]['frames'][j]['yBelow'] = None
                                shapes[i]['frames'][j]['xLeft'] = None
                                shapes[i]['frames'][j]['xRight'] = None
                            ofsFormat = "<{0}I".format(shapes[i]['numFrames'])
                            inf.seek(retObj['recordInfo'][i]['ofs'] + 4)
                            tmpdata = inf.read(struct.calcsize(ofsFormat))
                            data = struct.unpack(ofsFormat, tmpdata)
                            debugShapeInfo = True
                            #if i == shapeNum:
                            if 1:
                                for j in range(0, shapes[i]['numFrames']):
                                    shapes[i]['frames'][j]['ofset'] = retObj['recordInfo'][i]['ofs'] + data[j]
                                for j in range(0, shapes[i]['numFrames']):
                                    if j < (shapes[i]['numFrames'] - 1):
                                        shapes[i]['frames'][j]['len'] = shapes[i]['frames'][j+1]['ofset'] - shapes[i]['frames'][j]['ofset']
                                    else:
                                        shapes[i]['frames'][j]['len'] = (retObj['recordInfo'][i]['ofs'] + retObj['recordInfo'][i]['len']) - shapes[i]['frames'][j]['ofset']
                                    #if shapes[i]['frames'][j]['len'] > 10:
                                    inf.seek(shapes[i]['frames'][j]['ofset'])
                                    tmpdata = inf.read(struct.calcsize(fmt5UShort))
                                    frameData = struct.unpack(fmt5UShort, tmpdata)
                                    if frameData[4] > 0:
                                        posOfs = shapes[i]['frames'][j]['ofset'] % 16
                                        lineNumber = int(((shapes[i]['frames'][j]['ofset'] - posOfs) - 80) / 16) + 2
                                        if debugShapeInfo is True:
                                            print('  shape {0} frame {1} ofs[{2}|{2:04x}] len[{3}] (line{4}+{5})'.format(i, j, shapes[i]['frames'][j]['ofset'], shapes[i]['frames'][j]['len'], lineNumber, posOfs))

                                        blockLength = frameData[4] >> 1
                                        blockType = frameData[4] & 1
                                        if debugShapeInfo is True:
                                            print('  blockLength: {0}'.format(blockLength))
                                            print('  blockType: {0}'.format(blockType))
                                        ## OK so everything is a lie, cool cool cool
                                        blockType = 1
                                        if blockLength > 0:
                                            shapes[i]['frames'][j]['xLeft'] = frameData[0]
                                            shapes[i]['frames'][j]['xRight'] = frameData[1]
                                            shapes[i]['frames'][j]['yAbove'] = frameData[2]
                                            shapes[i]['frames'][j]['yBelow'] = frameData[3]
                                            if debugShapeInfo is True:
                                                for k in range(0, 4):
                                                    print('  {0} | {1}'.format(frameData[k], bytestr_to_binstr(frameData[k].to_bytes(2, 'big'))))
                                                print('  has pixel data')
                                                print('  size is {0} {1}'.format(shapes[i]['frames'][j]['xLeft'] + shapes[i]['frames'][j]['xRight'] + 1, shapes[i]['frames'][j]['yAbove'] + shapes[i]['frames'][j]['yBelow'] + 1))
                                            #
                                            numShorts = (shapes[i]['frames'][j]['len'] - 8) / 2
                                            numBytes = int(shapes[i]['frames'][j]['len'] - 8)
                                            if debugShapeInfo is True:
                                                print('  numShorts = {0}'.format(numShorts))
                                                print('  numBytes = {0}'.format(numBytes))

                                            inf.seek(shapes[i]['frames'][j]['ofset'] + 8)

                                            ## fer the shorts
                                            #fmtRun = "<{0}H".format(int(numShorts))
                                            #fmtRun = "<{0}h".format(int(numShorts))
                                            #tmpdata = inf.read(struct.calcsize(fmtRun))
                                            #runData = struct.unpack(fmtRun, tmpdata)

                                            ## fer the bytes
                                            #fmtRun = "<{0}B".format(int(numBytes))
                                            #fmtRun = "<{0}b".format(int(numBytes))
                                            #tmpdata = inf.read(struct.calcsize(fmtRun))
                                            #runData = struct.unpack(fmtRun, tmpdata)
                                            debugShapeBlit = False
                                            generateImage = True

                                            if blockType == 0:
                                                print('  uncompressed')
                                                tmpdata = inf.read(struct.calcsize(fmt2Short))
                                                runData = struct.unpack(fmt2Short, tmpdata)
                                                runXPos = runData[0]
                                                runYPos = runData[1]
                                                if debugShapeBlit is True:
                                                    print('    run X pos {0:04d}'.format(runXPos))
                                                    print('    run Y pos {0:04d}'.format(runYPos))
                                                ## seeking pos
                                                inf.seek(shapes[i]['frames'][j]['ofset'] + 8)
                                                framePixelsLength = int(shapes[i]['frames'][j]['len'] - 8)
                                                if debugShapeBlit is True:
                                                    print('    ----')
                                                    print('      framePixelsLength {0}'.format(framePixelsLength))
                                                    print('    ----')
                                                if i == shapeNum:
                                                    if (j >= 0) and (j < shapes[i]['numFrames']):
                                                        blockHigh = 4
                                                        blockWide = 4
                                                        outpath = 'out/img/{2}/{2}_shape_{0}_frame_{1}.png'.format(i, j, imgPrefix)
                                                        if os.path.exists(outpath):
                                                            print('skipping {0}'.format(outpath))
                                                            generateImage = False
                                                        seltarg = '{2}_shape_{0}_frame_{1}'.format(i, j, imgPrefix)
                                                        xKeep = 0
                                                        yKeep = 0
                                                        fmtURun = "<{0}B".format(int(framePixelsLength))
                                                        tmpdata = inf.read(struct.calcsize(fmtURun))
                                                        runUData = struct.unpack(fmtURun, tmpdata)
                                                        
                                                        inf.seek(shapes[i]['frames'][j]['ofset'] + 8)
                                                        fmtSRun = "<{0}b".format(int(framePixelsLength))
                                                        tmpdata = inf.read(struct.calcsize(fmtSRun))
                                                        runSData = struct.unpack(fmtSRun, tmpdata)
                                                        inRunHeader = True
                                                        headerXKeep = 0
                                                        headerYKeep = 0
                                                        headerRunType = 0
                                                        headerRunLength = 0
                                                        pixelCount = 0
                                                        nonRLECount = 0
                                                        justDidRLE = False
                                                        k = 0
                                                        while k < framePixelsLength:
                                                            runUVal = runUData[k]
                                                            runSVal = runSData[k]
                                                            #print('    [{3}] {0:04d} | {1:04d} | {2}'.format(runUData[k], runSData[k], bytestr_to_binstr(runUData[k].to_bytes(2, 'big')), k))
                                                            if inRunHeader is True:
                                                                if debugShapeBlit is True:
                                                                    print('    [Header] k {0} out of {1}'.format(k, len(runUData)))
                                                                if k + 5 >= len(runUData):
                                                                    k += 5
                                                                else:
                                                                    headerSpot0 = runUData[k+0]
                                                                    headerXKeep = runSData[k+2]
                                                                    headerYKeep = runSData[k+4]
                                                                    if debugShapeBlit is True:
                                                                        for l in range(k, k+5):
                                                                            print('    [{3}] {0:04d} | {1:04d} | {2}'.format(runUData[l], runSData[l], bytestr_to_binstr(runUData[l].to_bytes(2, 'big')), l))
                                                                    headerSpot5 = 255
                                                                    if k+5 < len(runUData):
                                                                        headerSpot5 = runUData[k+5]
                                                                        if debugShapeBlit is True:
                                                                            print('    [{3}] {0:04d} | {1:04d} | {2}'.format(runUData[k+5], runSData[k+5], bytestr_to_binstr(runUData[k+5].to_bytes(2, 'big')), k+5))
                                                                    if (headerSpot5 == 255) or (headerSpot5 == 0):
                                                                        k += 5
                                                                        #headerRunType = headerSpot0 & 1
                                                                        headerRunType = 0
                                                                        headerRunLength = headerSpot0 >> 1
                                                                        didRLE = False
                                                                        xKeep = headerXKeep
                                                                        if debugShapeBlit is True:
                                                                            print('      run type {0}'.format(headerRunType))
                                                                            print('      run length {0}'.format(headerRunLength))
                                                                            print('      x pixel start {0}'.format(headerXKeep))
                                                                            print('      y pixel start {0}'.format(headerYKeep))
                                                                        #if headerRunType == 1:
                                                                        #    justDidRLE = True
                                                                        pixelCount = 0
                                                                        inRunHeader = False
                                                                    else:
                                                                        #k += 1
                                                                        pass
                                                            else:
                                                                if debugShapeBlit is True:
                                                                    print('    [{3}] {0:04d} | {1:04d} | {2}'.format(runUVal, runSVal, bytestr_to_binstr(runUVal.to_bytes(2, 'big')), k))
                                                                drawThis = True
                                                                if pixelCount >= headerRunLength:
                                                                    if debugShapeBlit is True:
                                                                        print('            at pos k {0}, going back to header mode, drew pixels {1} of {2}'.format(k, pixelCount, headerRunLength))
                                                                    pixelCount = 0
                                                                    drawThis = False
                                                                    justDidRLE = False
                                                                    k -= 1
                                                                    inRunHeader = True
                                                                if drawThis is True:
                                                                    paletteColor = paletteData[0][runUVal]
                                                                    runCount = 1
                                                                    if debugShapeBlit is True:
                                                                        print('      Drawing {0} Pixels of {1} Color'.format(runCount, paletteColor))
                                                                    for drawIter in range(0, runCount):
                                                                        if generateImage is True:
                                                                            for l in range(0, blockHigh-2):
                                                                                for m in range(0, blockWide-2):
                                                                                    adddot(seltarg, [(xKeep * blockWide) + m, (headerYKeep * blockHigh) + l], [paletteColor[0], paletteColor[1], paletteColor[2], 255], 1.0)
                                                                        pixelCount += 1
                                                                        xKeep += 1
                                                            k += 1
                                                        if generateImage is True:
                                                            print('saving file {0}'.format(outpath))
                                                            ImageOperation('selsave {0} {1} a a 16 192 16'.format(seltarg, outpath))
                                                            ImageOperation('selwipe {0}'.format(seltarg))
                                            elif blockType == 1:
                                                if debugShapeBlit is True:
                                                    print('  compressed')
                                                tmpdata = inf.read(struct.calcsize(fmt2Short))
                                                runData = struct.unpack(fmt2Short, tmpdata)
                                                runXPos = runData[0]
                                                runYPos = runData[1]
                                                if debugShapeBlit is True:
                                                    print('    run X pos {0:04d}'.format(runXPos))
                                                    print('    run Y pos {0:04d}'.format(runYPos))
                                                ## seeking pos
                                                inf.seek(shapes[i]['frames'][j]['ofset'] + 8)
                                                framePixelsLength = int(shapes[i]['frames'][j]['len'] - 8)
                                                #for runVal in runData:
                                                #    print('    {0:04d}'.format(runVal))
                                                #    #print('    {0:04d} | {1}'.format(runVal, bytestr_to_binstr(runVal.to_bytes(2, 'big'))))
                                                #tmpdata = inf.read(struct.calcsize(fmt1UByte))
                                                #runData = struct.unpack(fmt1UByte, tmpdata)
                                                #runLength = runData[0]
                                                #runLength = runData[0] >> 1
                                                #runType = runData[0] & 1
                                                if debugShapeBlit is True:
                                                    print('    ----')
                                                    #for runVal in runData:
                                                    #    print('    {0:04d}'.format(runVal))
                                                    #    #print('    {0:04d} | {1}'.format(runVal, bytestr_to_binstr(runVal.to_bytes(2, 'big'))))
                                                    print('      framePixelsLength {0}'.format(framePixelsLength))
                                                    print('    ----')
                                                #if i == shapeNum:
                                                if 1:
                                                    #if (j >= 40) and (j < 41):
                                                    if (j >= 0) and (j < shapes[i]['numFrames']):
                                                        after255 = False
                                                        blockHigh = 4
                                                        blockWide = 4
                                                        outpath = 'out/img/{2}/{2}_shape_{0}_frame_{1}.png'.format(i, j, imgPrefix)
                                                        if os.path.exists(outpath):
                                                            print('skipping {0}'.format(outpath))
                                                            generateImage = False
                                                        seltarg = '{2}_shape_{0}_frame_{1}'.format(i, j, imgPrefix)
                                                        xKeep = 0
                                                        yKeep = 0
                                                        didRLE = False
                                                        
                                                        fmtURun = "<{0}B".format(int(framePixelsLength))
                                                        tmpdata = inf.read(struct.calcsize(fmtURun))
                                                        runUData = struct.unpack(fmtURun, tmpdata)
                                                        
                                                        inf.seek(shapes[i]['frames'][j]['ofset'] + 8)
                                                        fmtSRun = "<{0}b".format(int(framePixelsLength))
                                                        tmpdata = inf.read(struct.calcsize(fmtSRun))
                                                        runSData = struct.unpack(fmtSRun, tmpdata)
                                                        inRunHeader = True
                                                        headerXKeep = 0
                                                        headerYKeep = 0
                                                        headerRunType = 0
                                                        headerRunLength = 0
                                                        pixelCount = 0
                                                        nonRLECount = 0
                                                        justDidRLE = False
                                                        k = 0
                                                        while k < framePixelsLength:
                                                        #for k in range(0, runLength):
                                                            runUVal = runUData[k]
                                                            runSVal = runSData[k]
                                                            if inRunHeader is True:
                                                                if debugShapeBlit is True:
                                                                    print('    [Header] k {0} out of {1}'.format(k, len(runUData)))
                                                                if k + 5 >= len(runUData):
                                                                    k += 5
                                                                else:
                                                                    headerSpot0 = runUData[k+0]
                                                                    headerXKeep = runSData[k+2]
                                                                    headerYKeep = runSData[k+4]
                                                                    if debugShapeBlit is True:
                                                                        for l in range(k, k+5):
                                                                            print('    [{3}] {0:04d} | {1:04d} | {2}'.format(runUData[l], runSData[l], bytestr_to_binstr(runUData[l].to_bytes(2, 'big')), l))
                                                                    headerSpot5 = 255
                                                                    if k+5 < len(runUData):
                                                                        headerSpot5 = runUData[k+5]
                                                                        if debugShapeBlit is True:
                                                                            print('    [{3}] {0:04d} | {1:04d} | {2}'.format(runUData[k+5], runSData[k+5], bytestr_to_binstr(runUData[k+5].to_bytes(2, 'big')), k+5))
                                                                    if (headerSpot5 == 255) or (headerSpot5 == 0):
                                                                        k += 5
                                                                        headerRunType = headerSpot0 & 1
                                                                        headerRunLength = headerSpot0 >> 1
                                                                        didRLE = False
                                                                        xKeep = headerXKeep
                                                                        if debugShapeBlit is True:
                                                                            print('      run type {0}'.format(headerRunType))
                                                                            print('      run length {0}'.format(headerRunLength))
                                                                            print('      x pixel start {0}'.format(headerXKeep))
                                                                            print('      y pixel start {0}'.format(headerYKeep))
                                                                        if headerRunType == 1:
                                                                            justDidRLE = True
                                                                        pixelCount = 0
                                                                        inRunHeader = False
                                                                    else:
                                                                        #k += 1
                                                                        pass
                                                                pass
                                                            else:
                                                                if debugShapeBlit is True:
                                                                    print('    [{3}] {0:04d} | {1:04d} | {2}'.format(runUVal, runSVal, bytestr_to_binstr(runUVal.to_bytes(2, 'big')), k))
                                                                drawThis = True
                                                                if pixelCount >= headerRunLength:
                                                                    if debugShapeBlit is True:
                                                                        print('            at pos k {0}, going back to header mode, drew pixels {1} of {2}'.format(k, pixelCount, headerRunLength))
                                                                    pixelCount = 0
                                                                    drawThis = False
                                                                    justDidRLE = False
                                                                    k -= 1
                                                                    inRunHeader = True
                                                                #if runUVal == 255:
                                                                #    for l in range(0, blockHigh):
                                                                #        for m in range(0, blockWide):
                                                                #            adddot(seltarg, [(xKeep * blockWide) + m, (yKeep * blockHigh) + l], [255, 0, 0, 255], 1.0)
                                                                #    yKeep += 1
                                                                #    xKeep = headerXKeep
                                                                #    drawThis = False
                                                                #    #xKeep = runSData[k-1]
                                                                #    after255 = True
                                                                if drawThis is True:
                                                                    drawRLE = False
                                                                    if headerRunType == 1:
                                                                        drawRLE = True
                                                                    runCount = 1
                                                                    if nonRLECount > 0:
                                                                        drawRLE = False
                                                                        if debugShapeBlit is True:
                                                                            print('      non RLE count is {0}'.format(nonRLECount))
                                                                        nonRLECount -= 1
                                                                    if headerRunType == 1:
                                                                        if nonRLECount == 0:
                                                                            drawRLE = True
                                                                            justDidRLE = True
                                                                    if drawRLE is True:
                                                                        if didRLE is True:
                                                                            drawRLE = False
                                                                        else:
                                                                            if justDidRLE is True:
                                                                                if (runUVal & 1) == 0:
                                                                                    nonRLECount = runUVal >> 1
                                                                                    if debugShapeBlit is True:
                                                                                        print('      previously did RLE run, now seeing that we should do {0} pixels of non-RLE?'.format(nonRLECount))
                                                                                    #if justDidRLE is True:
                                                                                    #    
                                                                                    #    
                                                                                    #    drawRLE = False
                                                                                    k += 1
                                                                                    if (k < len(runUData)):
                                                                                        runUVal = runUData[k]
                                                                                        runSVal = runSData[k]
                                                                                        if debugShapeBlit is True:
                                                                                            print('    [{3}] {0:04d} | {1:04d} | {2}'.format(runUVal, runSVal, bytestr_to_binstr(runUVal.to_bytes(2, 'big')), k))
                                                                                    else:
                                                                                        runCount = 0
                                                                                    justDidRLE = False
                                                                                    #else:
                                                                                    drawRLE = False
                                                                                else:
                                                                                    runCount = runUVal >> 1
                                                                                    
                                                                                    ## removing this fix because i think we may be able to ignore it
                                                                                    if runCount > (headerRunLength - pixelCount):
                                                                                        if debugShapeBlit is True:
                                                                                            print('    Setting RunLength 1, runCount was {0}'.format(runCount))
                                                                                        runCount = 1
                                                                                    
                                                                                    ## this bit was added to try to make FONTS.VGA shape 6 work
                                                                                    elif runCount == 0:
                                                                                        if debugShapeBlit is True:
                                                                                            print('    Setting RunLength 1, runCount was 0')
                                                                                        runCount = 1
                                                                                    else:
                                                                                        #justDidRLE = True
                                                                                        k += 1
                                                                                        runUVal = runUData[k]
                                                                                        runSVal = runSData[k]
                                                                                        if debugShapeBlit is True:
                                                                                            print('      Doing RLE run of {0} pixels of {1} index'.format(runCount, runUVal))
                                                                                            print('    [{3}] {0:04d} | {1:04d} | {2}'.format(runUVal, runSVal, bytestr_to_binstr(runUVal.to_bytes(2, 'big')), k))
                                                                                        #didRLE = True
                                                                    paletteColor = paletteData[0][runUVal]
                                                                    if headerRunType == 1:
                                                                        ## this stuff breaks FONTS.VGA shape 6, but is needed for other shapes ... weird
                                                                        if justDidRLE is True:
                                                                            #print('      justDidRLE, so we may want to skip evens?')
                                                                            #if runUVal == 2:
                                                                            #    runCount = 0
                                                                            #if runUVal == 4:
                                                                            #    runCount = 0
                                                                            #if runUVal == 6:
                                                                            #    runCount = 0
                                                                            #if runUVal == 8:
                                                                            #    runCount = 0
                                                                            #if runUVal == 10:
                                                                            #    runCount = 0
                                                                            #if runUVal == 12:
                                                                            #    runCount = 0
                                                                            #if runUVal == 14:
                                                                            #    runCount = 0
                                                                            #if runUVal == 16:
                                                                            #    runCount = 0
                                                                            #if runCount == 0:
                                                                            #    print('        skipping, val was {0}, or {1}'.format(runUVal, runUVal >> 1))
                                                                            #justDidRLE = False
                                                                            pass
                                                                    if debugShapeBlit is True:
                                                                        print('      Drawing {0} Pixels of {1} Color'.format(runCount, paletteColor))
                                                                    for drawIter in range(0, runCount):
                                                                        if generateImage is True:
                                                                            for l in range(0, blockHigh-2):
                                                                                for m in range(0, blockWide-2):
                                                                                    adddot(seltarg, [(xKeep * blockWide) + m, (headerYKeep * blockHigh) + l], [paletteColor[0], paletteColor[1], paletteColor[2], 255], 1.0)
                                                                        pixelCount += 1
                                                                        xKeep += 1
                                                                        if runCount > 1:
                                                                            justDidRLE = True
                                                                    #if after255 is True:
                                                                    #    
                                                                    #    runCount = runUVal >> 1
                                                                    #    print('      {0:04d} | {1}'.format(runType, bytestr_to_binstr(runType.to_bytes(2, 'big'))))
                                                                    #    if runType == 1:
                                                                    #        print('      {0:04d} | {1}'.format(runCount, bytestr_to_binstr(runCount.to_bytes(2, 'big'))))
                                                                    #    if runType == 1:
                                                                    #        drawRLE = True
                                                                    #        k += 1
                                                                    #        runUVal = runUData[k]
                                                                    #        runSVal = runSData[k]
                                                                    #        print('    {0:04d} | {1:04d} | {2}'.format(runUVal, runSVal, bytestr_to_binstr(runUVal.to_bytes(2, 'big'))))
                                                                    #    after255 = False
                                                                    #if drawRLE is False:
                                                                    #    paletteColor = paletteData[0][runUVal]
                                                                    #    for l in range(0, blockHigh):
                                                                    #        for m in range(0, blockWide):
                                                                    #            #adddot(seltarg, [xPos+l, yPos+k], color, 1.0)
                                                                    #            adddot(seltarg, [(xKeep * blockWide) + m, (yKeep * blockHigh) + l], [paletteColor[0], paletteColor[1], paletteColor[2], 255], 1.0)
                                                                    #    xKeep += 1
                                                                    #    #after255 = True
                                                                    #elif drawRLE is True:
                                                                    #    paletteColor = paletteData[0][runUVal]
                                                                    #    for drawIter in range(0, runCount):
                                                                    #        for l in range(0, blockHigh):
                                                                    #            for m in range(0, blockWide):
                                                                    #                adddot(seltarg, [(xKeep * blockWide) + m + drawIter, (yKeep * blockHigh) + l], [paletteColor[0], paletteColor[1], paletteColor[2], 255], 1.0)
                                                                    #        xKeep += 1
                                                                    #    after255 = True
                                                            k += 1
                                                        if generateImage is True:
                                                            print('saving file {0}'.format(outpath))
                                                            ImageOperation('selsave {0} {1} a a 16 192 16'.format(seltarg, outpath))
                                                            ImageOperation('selwipe {0}'.format(seltarg))
                                                #for runVal in runData:
                                                #    #print('    {0:04d}'.format(runVal))
                                                #    print('    {0:04d} | {1}'.format(runVal, bytestr_to_binstr(runVal.to_bytes(2, 'big'))))
                                                ## seeking pos
                                            #tmpdata = inf.read(struct.calcsize(fmtRun))
                                            #runData = struct.unpack(fmtRun, tmpdata)
                                            #fmtRun = "<{0}b".format(int(numBytes))
                                            #tmpdata = inf.read(struct.calcsize(fmtRun))
                                            #runData = struct.unpack(fmtRun, tmpdata)
                                            else:
                                                print('  unknown')
                                            #print('  {0}'.format(frameStart))
                                            print('------------------------')
                                    
                        else:
                            print('  flex blob size does not match {0} vs {1}'.format(retObj['recordInfo'][i]['len'], data[0]))
                        #print(data)
                        #if (i < retObj['recordCount'] - 1):
                        #    ofs[i+1][0] = data[0]+keepos
                        #ofs[i+0][1] = data[1]
                        
                        #print('%d %08x' % (i, ofs[i][0]))
                        if 0:
                            binData = inf.read(struct.calcsize(fmtBlob))
                            data = struct.unpack(fmtBlob, binData)
                            if isinstance(data, tuple):
                                retObj['record'][i] = data
                                if 0:
                                    recordString = ''
                                    for val in data:
                                        if (val >= 32) and (val < 127):
                                            #print(val)
                                            recordString += '{0}'.format(chr(val))
                                        elif val == 9:
                                            recordString += '    '
                                        elif val == 0:
                                            pass
                                        else:
                                            print(val)
                                    print('[{0}] [{1}]'.format(i, recordString))
                    else:
                        print('offset and data requested larger than filesize {0}'.format(fileSize))
            else:
                #print('  Flex blob len is {0}'.format(retObj['recordInfo'][i]['len']))
                pass


    if 0:
        data = []
        numChunkRefs = int(fileSize / 512)
        print(numChunkRefs)
        fmtSChunk = "<256H"
        retObj['chunkRefs'] = []
        for i in range(0, numChunkRefs):
            binData = inf.read(struct.calcsize(fmtSChunk))
            data = struct.unpack(fmtSChunk, binData)
            retObj['chunkRefs'].append(data)
    inf.close()
    yamlWrite(yamlPath, retObj)


def readU7Chunks(filePath, yamlPath):
    funcName = 'readU7Chunks'
    print('[{0}] init for path {1}'.format(funcName, filePath))
    fileFW = FileWerks(filePath)
    fileSize = fileFW.getSize()
    print('[{0}]   size {1}'.format(funcName, fileSize))
    retObj = {}
    #ireg_filesize = os.stat(ireg_path)[6]
    #print('ireg_read -> IREG: %s (%d bytes)' % (ireg_path, ireg_filesize))
    inf = openBinaryFileRead(filePath)
    data = []
    numChunkRefs = int(fileSize / 512)
    print(numChunkRefs)
    fmtSChunk = "<256H"
    retObj['chunkRefs'] = []
    for i in range(0, numChunkRefs):
        binData = inf.read(struct.calcsize(fmtSChunk))
        data = struct.unpack(fmtSChunk, binData)
        retObj['chunkRefs'].append(data)
    inf.close()
    yamlWrite(yamlPath, retObj)


def readU7Map(filePath, yamlPath):
    funcName = 'readU7Map'
    print('[{0}] init for path {1}'.format(funcName, filePath))
    fileFW = FileWerks(filePath)
    fileSize = fileFW.getSize()
    print('[{0}]   size {1}'.format(funcName, fileSize))
    retObj = {}
    #ireg_filesize = os.stat(ireg_path)[6]
    #print('ireg_read -> IREG: %s (%d bytes)' % (ireg_path, ireg_filesize))
    inf = openBinaryFileRead(filePath)
    data = []
    numSChunks = int(fileSize / 512)
    print(numSChunks)
    fmtSChunk = "<256H"
    retObj['schunk'] = []
    for i in range(0, numSChunks):
        binData = inf.read(struct.calcsize(fmtSChunk))
        data = struct.unpack(fmtSChunk, binData)
        retObj['schunk'].append(data)
    if 0:
        for i in range(0, fileSize):
            data.append(struct.unpack("B", inf.read(1))[0])
        if keepOfs > 0:
            if keepOfs >= fileSize:
                # default if we screw up the ofset size
                keepOfs = 0
                jumpSize = 16
            else:
                keeper = 0
                hexString = bytestr_to_hexstr(data[keeper:keeper+keepOfs])
                intString = bytestr_to_intstr(data[keeper:keeper+keepOfs])
                chrString = bytestr_to_charstr(data[keeper:keeper+keepOfs])
                outData += '{0}|{1}|{2}|\n'.format(hexString, intString, chrString)

        keeper = keepOfs
        #jumpSize = 21
        while keeper < fileSize:
            bytesCount = jumpSize
            bytesRemaining = fileSize - keeper
            if bytesRemaining < jumpSize:
                bytesCount = bytesRemaining
            hexString = bytestr_to_hexstr(data[keeper:keeper+bytesCount])
            #print(hexString)
            while len(hexString) < ((jumpSize * 3) - 1):
                hexString += ' '
            intString = bytestr_to_intstr(data[keeper:keeper+bytesCount])
            #print(hexString)
            while len(intString) < ((jumpSize * 4) - 1):
                intString += ' '
            #print(len(hexString))
            chrString = bytestr_to_charstr(data[keeper:keeper+bytesCount])
            while len(chrString) < jumpSize:
                chrString += ' '
            #print('{0}|{1}|{2}|'.format(hexString, intString, chrString))
            outData += '{0}|{1}|{2}|\n'.format(hexString, intString, chrString)
            keeper += jumpSize
        if outPath is not None:
            stringToFile(outPath, outData)
        #print(bytestr_to_hexstr(data[4:4]))
    inf.close()
    yamlWrite(yamlPath, retObj)


def runLengthEncoding(input):
      
    # Generate ordered dictionary of all lower
    # case alphabets, its output will be 
    # dict = {'w':0, 'a':0, 'd':0, 'e':0, 'x':0}
    dict=OrderedDict.fromkeys(input, 0)
  
    # Now iterate through input string to calculate 
    # frequency of each character, its output will be 
    # dict = {'w':4,'a':3,'d':1,'e':1,'x':6}
    for ch in input:
        dict[ch] += 1
  
    # now iterate through dictionary to make 
    # output string from (key,value) pairs
    output = ''
    for key,value in dict.items():
         output = output + key + str(value)
    return output


def rleWork():
    input="wwwwaaadexxxxxx"
    print (runLengthEncoding(input))
    pass


def main(argv):
    global shapesman
    global memusage
    #rendersize = [640, 400]
    #rendersize = [640, 480]
    rendersize = [1280, 720]
    #rendersize = [1920, 1080]
    #rendersize = [16, 16]
    picnum = 32
    #Banner
    #checkFiles()
    #gameFiles('U7')
    #readHex('WEAPONS.DAT')
    #vals = glob.glob('u7files\gamefiles\U7BG\*')
    datFiles = {}
    datFilesChanged = False
    dirPaths = []
    if os.path.exists('datFiles.yaml'):
        datFiles = yamlRead('datFiles.yaml')
    listAdd(dirPaths, 'data/u7')
    listAdd(dirPaths, 'data/u7/STATIC/')
    for dirPath in dirPaths:
        vals = glob.glob('{0}*'.format(dirPath))
        #print('data/u7/*')
        for val in vals:
            val = val.replace('\\', '/')
            #print(val)
            #listAdd(datFiles, val)
            if val in datFiles:
                pass
            else:
                if os.path.isdir(val):
                    pass
                else:
                    datFiles[val] = {}
                    datFiles[val]['readmethod'] = 'hex'
                    datFiles[val]['dataOfs'] = 0
                    datFiles[val]['dataBlockSize'] = 16
                    datPath = stringStripStart(val, 'gamefiles/')
                    paths = datPath.split('/')
                    fileName = paths[len(paths)-1]
                    dataPath = 'data/{0}'.format(stringStripEnd(datPath, fileName))
                    if os.path.isdir(dataPath):
                        pass
                    else:
                        os.makedirs(dataPath)
                    #print(dataPath)
                    #print(paths)
                    datFiles[val]['outhex'] = '{0}hex.{1}.txt'.format(dataPath, fileName)
                    datFiles[val]['outyaml'] = '{0}{1}.yaml'.format(dataPath, fileName)
                    datFilesChanged = True
    if datFilesChanged is True:
        yamlWrite('datFiles.yaml', datFiles)
    
    #ok
    ourFiles = []
    #listAdd(ourFiles, 'data/u7/STATIC/U7CHUNKS')
    #listAdd(ourFiles, 'data/u7/STATIC/PALETTES.FLX')
    #listAdd(ourFiles, 'data/u7/STATIC/TEXT.FLX')
    #listAdd(ourFiles, 'data/u7/STATIC/ENDSHAPE.FLX')
    #listAdd(ourFiles, 'data/u7/STATIC/MAINSHP.FLX')
    #listAdd(ourFiles, 'data/u7/STATIC/U7VOICE.FLX')
    #listAdd(ourFiles, 'data/u7/STATIC/XFORM.TBL')
    #listAdd(ourFiles, 'data/u7/STATIC/FACES.VGA')
    #listAdd(ourFiles, 'data/u7/STATIC/FONTS.VGA')
    #listAdd(ourFiles, 'data/u7/STATIC/GUMPS.VGA')
    #listAdd(ourFiles, 'data/u7/STATIC/SHAPES.VGA')
    #listAdd(ourFiles, 'data/u7/STATIC/WGTVOL.DAT')
    listAdd(ourFiles, 'data/u7/STATIC/TFA.DAT')
    #listAdd(ourFiles, 'data/u7/STATIC/SPRITES.VGA')
    #listAdd(ourFiles, 'data/u7/STATIC/USECODE')
    #rleWork()
    for val in ourFiles:
        if val in datFiles:
            print(val)
            print(datFiles[val])
            if stringMatch(datFiles[val]['readmethod'], 'hex'):
                readHex(val, datFiles[val]['dataOfs'], datFiles[val]['dataBlockSize'], datFiles[val]['outhex'])
            elif stringMatch(datFiles[val]['readmethod'], 'u7map'):
                readU7Map(val, datFiles[val]['outyaml'])
            elif stringMatch(datFiles[val]['readmethod'], 'u7chunks'):
                readU7Chunks(val, datFiles[val]['outyaml'])
            elif stringMatch(datFiles[val]['readmethod'], 'flex'):
                readU7Flex(val, datFiles[val]['outyaml'])
            elif stringMatch(datFiles[val]['readmethod'], 'shape'):
                readU7Shapes(val, datFiles[val]['outyaml'])
            elif stringMatch(datFiles[val]['readmethod'], 'usecode'):
                readU7Usecode(val, datFiles[val]['outyaml'])
            elif stringMatch(datFiles[val]['readmethod'], 'wgtvol'):
                readU7WgtVol(val, datFiles[val]['outyaml'])
            elif stringMatch(datFiles[val]['readmethod'], 'tfa'):
                readU7TFA(val, datFiles[val]['outyaml'])
        else:
            print(f'FILE NOT IN DAT: {val}')
    if 0:
        #processU7Chunks('data/U7BG/STATIC/U7CHUNKS.yaml')
        global chunkShapes
        for i in range(0, 3072):
            processU7RawChunk(i)
        for shapeNum in sorted(chunkShapes):
            print('{0}'.format(shapeNum))
    #thisNum = 31
    #print('{0}'.format(bytestr_to_binstr(thisNum.to_bytes(2, 'big'))))
    if 1:
        #processU7Palette('data/U7BG/STATIC/PALETTES.FLX.yaml')
        #processU7Palette('data/U7BG/STATIC/XFORM.TBL.yaml')
        #processU7Text('data/U7BG/STATIC/TEXT.FLX.yaml')
        pass
    if 0:
        #this is wonky
        processU7Map('data/U7BG/STATIC/U7MAP.yaml')
    #val = 1029
    #binStr = bytestr_to_binstr(val.to_bytes(2, 'big'))
    #print(binStr)
    #listAdd(datFiles, 'NPCFLAG.DAT')
    #listAdd(datFiles, 'ADLIBMUS.DAT')
    #listAdd(datFiles, 'ADLIBSFX.DAT')
    #listAdd(datFiles, 'AMMO.DAT')
    #listAdd(datFiles, 'ARMOR.DAT')
    #listAdd(datFiles, 'ENDGAME.DAT')
    #listAdd(datFiles, 'EQUIP.DAT')
    #listAdd(datFiles, 'INITGAME.DAT')
    #listAdd(datFiles, 'INTROADM.DAT')
    #listAdd(datFiles, 'INTROPAL.DAT')
    #listAdd(datFiles, 'INTRORDM.DAT')
    #listAdd(datFiles, 'INTROSND.DAT')
    #listAdd(datFiles, 'MONSTERS.DAT')
    #listAdd(datFiles, 'MT32MUS.DAT')
    #listAdd(datFiles, 'MT32SFX.DAT')
    #listAdd(datFiles, 'NPCFLAG.DAT')
    #listAdd(datFiles, 'OCCLUDE.DAT')
    #listAdd(datFiles, 'READY.DAT')
    #listAdd(datFiles, 'SCHEDULE.DAT')
    #listAdd(datFiles, 'SHPDIMS.DAT')
    #listAdd(datFiles, 'TFA.DAT')
    #listAdd(datFiles, 'WEAPONS.DAT')
    #listAdd(datFiles, 'WGTVOL.DAT')
    #listAdd(datFiles, 'WIHH.DAT')
    #for datName in datFiles:
        # 42 is for NPCFLAG.DAT
    #    print(datName)
        #readHex(datName, 1, 13, 'data/hex.{0}.txt'.format(datName))
    return
    print('-------------------------------')
    print('  Asset Inspector')
    print('  Ultima VII: The Black Gate')
    print('-------------------------------')
    print('\tloading blackgate/STATIC/SHAPES.VGA')
    #readshapes('blackgate/STATIC/SHAPES.VGA')
    if shapesman is not None:
        print('ERROR: Shapes Manager not in READY state!')
        return
    shapesman = shapeTop('blackgate/STATIC/SHAPES.VGA')
    shapesman.readShapeTFA('blackgate/STATIC/TFA.DAT')
    shapesman.readShapeTFA('data/u7/STATIC/TFA.DAT')
    shapesman.readFlexText('blackgate/STATIC/TEXT.FLX')
    print('\tloading blackgate/STATIC/U7MAP')
    world = U7World('blackgate/STATIC/U7MAP')
    #super-chunks are 12x12, 144 in all
    print('\tloading blackgate/STATIC/U7CHUNKS')
    world.chunk('blackgate/STATIC/U7CHUNKS')
    return
    #for i in range(0, 144):
    #    U7ireg('blackgate\STATIC\u7ireg%02x' % i, i)

    #ImageOperation('selbounds u7world 3072 1536 1')
    if 0:
        print('    loading blackgate/STATIC/u7ireg* files')
        for i in range(0, 144):
            print('    loading blackgate/STATIC/u7ireg%02x' % (i))
            ireg = U7ireg('blackgate/STATIC/u7ireg%02x' % (i), i)
    #imgfile = 'u7world_iregs_test.png'
    #ImageOperation('selsave u7world %s' % (imgfile))
    #ImageOperation('selwipe u7world')
    #chunks are 16x16, shorts, so 512 bytes per chunk
    #readshapesizes()
    #chunk_dump(world)
    #return

    schunknum = 13
    scmin = None
    if len(argv) == 1:
        schunknum = int(argv[0])
        scmin = 0
    elif len(argv) == 2:
        schunknum = int(argv[0])
        scmin = int(argv[1])
    else:
        #minimap_glue()
        #return
        pass

    #world.readschunk(schunknum,scmin)
    #world.readschunk(schunknum,scmin)

    print('\tdraw me a picture [%d x %d]' % (rendersize[0], rendersize[1]))
    world.viewport_set(rendersize)
    #newmemusage = current_mem_usage()
    #deltamemusage = newmemusage - memusage
    #memusage = newmemusage
    #print('MEM: {0}KB DELTA: {1}KB'.format(in_kilobytes(memusage), in_kilobytes(deltamemusage)))
    barf_mem_usage()
    
    #LB's castle
    #viewstart = [15200.0, 18600.0,0.0]
    
    #Trinsic Bar - see 17752-ultima-vii-the-black-gate-dos-screenshot-eating-and-drinking.gif
    #viewstart = [17280.0, 35744.0, 0.0]
    #viewstop = [17280.0, 35744.0, 0.0]
    
    #viewstart = [14808.0, 18600.0, 0.0]
    #viewstop = [14808.0, 18600.0, 0.0]
    viewstart = [4096.0, 5120.0, 0.0]
    viewstop = [5120.0,  6144.0, 0.0]
    keep = [0.0, 0.0, 0.0]
    dif = [0.0, 0.0, 0.0]
    steps = 128
    
    #text_for_render = "Yeah, c'mon, all right, we can do it"
    for i in range(0, 3):
        keep[i] = viewstart[i]
        if steps == 1:
            dif[i] = viewstop[i] - viewstart[i]
        elif steps > 1:
            dif[i] = (viewstop[i] - viewstart[i]) / float(steps-1)
        else:
            dif[i] = 0.0
            pass
    
    for j in range(0, steps):
        print('\tframe %d' % j)
        imgpath = 'u7world_viewtest_%02d.%03d.dev.png' % (picnum, j)
        stillpath = 'stills/u7world_frame_%04d.png' % (j)
        if file_exists(imgpath) is False:
            #ImageOperation('selbounds u7world %d %d' % (rendersize[0],rendersize[1]))
            world.view(keep)
            #for text in world.texts:
            #    textBlock( 'u7world', text[2], [text[0],text[1]], [0,0,0,255], [236,233,216,128] )
            #textBlock( 'u7world', text_for_render, [160,120], [0,0,0,255] )
            ImageOperation('selsave u7world %s' % imgpath)
            ImageOperation('selwipe u7world')
        if file_exists(imgpath):
            if os.path.exists(stillpath) is False:
                shutil.copyfile(imgpath, stillpath)
        for i in range(0, 3):
            keep[i] += dif[i]
        #newmemusage = current_mem_usage()
        #deltamemusage = newmemusage - memusage
        #memusage = newmemusage
        #print('MEM: {0}KB DELTA: {1}KB'.format(in_kilobytes(memusage), in_kilobytes(deltamemusage)))
        barf_mem_usage()
    #minimap_dump(world)

    if 0:  # unreachable code
        #for i in range(0,0x096):
        #    shape = shape_frame_get(i,None)
        #    for j in range(0,shape.numframes):
        #        shape = shape_frame_get(i,j)
        #dumpshapes()
        scs = []
        val = 58
        scs.append(val-13)
        scs.append(val-12)
        scs.append(val-11)
        scs.append(val-1)
        scs.append(val)
        scs.append(val+1)
        scs.append(val+11)
        scs.append(val+12)
        scs.append(val+13)
        #imgfile = 'u7world_mini_07.png'  # not used
        #for i in range(0,144):
        #if(file_exists(imgfile) is False):
        #    for i in scs:
        #        world.readschunk(i,0)
        #    ImageOperation('selsave u7world %s' % (imgfile))
        #return
        print(schunknum)
        print(scmin)
        if scmin is not None:
            imgfile = 'u7world_sc_%03d.%d.dv0.png' % (schunknum, scmin)
            if file_exists(imgfile) is False:
                world.readschunk(schunknum, scmin)
                ImageOperation('selsave u7world %s' % imgfile)
                ImageOperation('selwipe u7world')
        else:
            if schunknum is not None:
                for i in range(1, 5):
                    scmin = i
                    imgfile = 'u7world_sc_%03d.%d.dev.png' % (schunknum,scmin)
                    if file_exists(imgfile) is False:
                        world.readschunk(schunknum, scmin)
                        ImageOperation('selsave u7world %s' % imgfile)
                        ImageOperation('selwipe u7world')
        #for i in range(0,world.numchunks):
        #    world.readchunk(i)
        dumpshapes()
    #newmemusage = current_mem_usage()
    #deltamemusage = newmemusage - memusage
    #memusage = newmemusage
    #print('MEM: {0}KB DELTA: {1}KB'.format(in_kilobytes(memusage), in_kilobytes(deltamemusage)))
    barf_mem_usage()
    return 1

if __name__ == '__main__':
    #global memusage
    #memusage = current_mem_usage()
    #barf_mem_usage()
    #global memusage
    #memusage = current_mem_usage()
    #print(memusage)
    sys.exit(main(sys.argv[1:]))
