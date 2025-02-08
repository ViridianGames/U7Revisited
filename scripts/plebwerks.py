#!/usr/bin/env python

import sys
import os.path
import stat
import time
import hashlib
import yaml
from types import *

# simple text and string processing functions, e.g. PlebWerks

def openTextFileRead(fpath, encoding='ascii'):
    if os.path.isfile(fpath):
        return open(fpath, mode='r', encoding=encoding)
    return None


def isStringType(value):
    #if isinstance(value, unicode):
    #    return True
    if isinstance(value, str):
        return True
    return False


def stringStripStart(a, m):
    len_m = len(m)
    if stringMatchStart(a, m):
        return a[len_m:]
    return a


def stringStripEnd(a, m):
    len_a = len(a)
    len_m = len(m)
    if stringMatchEnd(a, m):
        return a[:len_a-len_m]
    return a


def stringEndRemoveNewline(a):
    a_len = len(a)
    if a_len == 0:
        return a
    c = a[a_len-1:]
    n = ord(c)
    while charIsNewline(n):
        a = a[:a_len-1]
        a_len = len(a)
        c = a[a_len-1:]
        if len(c) == 1:
            n = ord(c)
        else:
            n = 0
    return a


def stringEndRemoveWhitespace(a):
    a_len = len(a)
    c = a[a_len-1:]
    if len(c) == 0:
        return a

    n = ord(c)
    while charIsWhitespace(n):
        a = a[:a_len-1]
        a_len = len(a)
        c = a[a_len-1:]
        if len(c) == 1:
            n = ord(c)
        else:
            n = 0
    return a


def stringStartRemoveWhitespace(a):
    a_len = len(a)
    c = a[:1]
    if len(c) == 0:
        return a
    n = ord(c)
    while charIsWhitespace(n):
        a = a[1:]
        a_len = len(a)
        c = a[:1]
        if len(c) == 1:
            n = ord(c)
        else:
            n = 0
    return a


def stringClean(a):
    line = a
    if '\0' in line:
        line = line.replace('\0','')
    line = stringEndRemoveNewline(line)
    line = stringEndRemoveWhitespace(line)
    line = stringStartRemoveWhitespace(line)
    return line


def stringMatch(a, m):
    if isStringType(a) is True:
        pass
    else:
        return False
    if isStringType(m) is True:
        pass
    else:
        return False
    if len(m) != len(a):
        return False
    if a == m:
        return True
    return False


def stringMatchStart(a, m):
    len_a = len(a)
    len_m = len(m)
    if len_m > len_a:
        return False
    q = a[:len_m]
    if q == m:
        return True
    return False


def stringMatchEnd(a, m):
    len_a = len(a)
    len_m = len(m)
    if len_m > len_a:
        return False
    q = a[len(a)-len(m):]
    if q == m:
        return True
    return False


def stringSplitNoEmpty(a, s):
    l = []
    vals = a.split(s)
    for v in vals:
        if len(v) > 0:
            l.append(v)
    return l


def stringProcessDelimited(line, delimiter=None):
    if delimiter is None:
        delimiter = ','
    vals = []
    lvs = line.split(delimiter)
    i = 0
    #print line
    #print len(lvs)
    while i < len(lvs):
        #print 'i({0}) len({1})'.format(i, len(lvs))
        lv = lvs[i]
        qf = lv.find('"')
        #print lv
        if qf >= 0:
            #print 'found quote [{0}] at char({1})'.format(lv, qf)
            if qf == 0:
                lv = lv[1:]
                #qf = lv.find('"')

            #print 'FOUND QUOTE'
            #print qf
            done = False
            sti = i
            #i += 1
            while done is False:
                if i == sti:
                    qf = lv.find('"')
                    if qf == len(lv)-1:
                        done = True
                        #lv = lv.replace('"','')
                        lv = stringStripEnd(lv,'"')
                    else:
                        i += 1
                else:
                    if i < len(lvs):
                        lq = lvs[i]
                        lv += '%s%s' % (delimiter, lq)
                        qf = lq.find('"')
                        if qf == len(lq)-1:
                            done = True
                            #lv = lv.replace('"','')
                            lv = stringStripEnd(lv,'"')
                        else:
                            i += 1
                    else:
                        done = True
        vals.append(lv)
        i += 1
    #print 'Line read - finished'
    return vals


def stringToFile(filename, data, encoding='utf-8'):
    out = openTextFileWrite(filename, 0, encoding)
    if out is not None:
        out.write(data)
        out.close()


def str_from_unicode(a):
    val = ''
    a_len = len(a)
    if a_len == 0:
        return a
    for i in range(0, a_len):
        if ord(a[i]) < 128:
            val += a[i]
        else:
            val += '.'
    return val


def pathAssertExists(path):
    if os.path.isdir(path):
        pass
    else:
        os.makedirs(path)



class FileWerks:
    def __init__(self, fileName):
        self.filePath = fileName
        self.exists = os.path.exists(self.filePath)
        self.isfile = os.path.isfile(self.filePath)
        self.st = None
        if self.exists is True:
            self.st = os.stat(self.filePath)
    
    def getSize(self):
        if self.st is not None:
            return self.st[stat.ST_SIZE]
    
    def getLastModified(self):
        if self.st is not None:
            return self.st[stat.ST_MTIME]
    
    def getMd5Hash(self):
        # Python program to find MD5 hash value of a file
        if self.isfile is True:
            md5_hash = hashlib.md5()
            with open(self.filePath,"rb") as f:
            # Read and update hash in chunks of 4K
                for byte_block in iter(lambda: f.read(4096),b""):
                    md5_hash.update(byte_block)
            return md5_hash.hexdigest()
        return None
    
    def getContents(self):
        data = None
        if self.isfile is True:
            inf = openTextFileRead(self.filePath)
            if inf is not None:
                data = inf.read()
                inf.close()
        return data
    
    def getBinContents(self):
        data = None
        if self.isfile is True:
            inf = openBinaryFileRead(self.filePath)
            if inf is not None:
                data = inf.read()
                inf.close()
        return data
    
    def getLines(self):
        encodings = []
        listAdd(encodings, 'ascii')
        listAdd(encodings, 'utf-8')
        lines = []
        data = None
        if self.isfile is True:
            for encoding in encodings:
                #print(encoding)
                if data is None:
                    inf = openTextFileRead(self.filePath, encoding)
                    if inf is not None:
                        try:
                            data = inf.readlines()
                            for line in data:
                                lines.append(stringEndRemoveNewline(line))
                        except:
                            #print('failed for encoding {0}'.format(encoding))
                            pass
        return lines
    
    def getDelimitedLines(self, delimiter=None):
        if delimiter is None:
            delimiter = ','
        first_row = None
        num_cols = None
        rows = []
        lines = self.getLines()
        for line in lines:
            line = stringClean(line)
            vals = stringProcessDelimited(line, delimiter)
            if first_row is None:
                first_row = vals
                for i in range(0, len(first_row)):
                    first_row[i] = str_from_unicode(first_row[i])
                num_cols = len(first_row)
            else:
                if len(vals) == num_cols:
                    #print ' is same column count {0} vs {1}'.format(len(vals), num_cols)
                    row = dict()
                    for i in range(0, num_cols):
                        row[first_row[i]] = vals[i]
                    rows.append(row)
                else:
                    #if 0:
                        #print 'not same column count {0} vs {1}'.format(len(vals), num_cols)
                        #i = 0
                        #for a in vals:
                        #    print '{0} [{1}]'.format(i, a)
                        #    i += 1
                    pass
        return rows


def listRemoveValue(l, a):
    # updated to while in case the same value is in the list multiple times
    while a in l:
        l.remove(a)


def dictGetKeys(d):
    l = []
    if isinstance(d, dict):
        for b in d:
            listAdd(l, b)
    return sorted(l)


def dictGetValue(d, key):
    if isinstance(d, dict):
        if key in d:
            #print 'has key {0}, returning'.format(key)
            return d[key]
    return None


def yamlRead(yamlPath):
    if os.path.exists(yamlPath):
        yfile = FileWerks(yamlPath)
        return yaml.load(yfile.getContents(), Loader=yaml.FullLoader)


def yamlWrite(yamlPath, dobj):
    if isinstance(dobj, dict):
        out = openTextFileWrite(yamlPath, 0)
        if out is not None:
            yaml.dump(dobj, out, default_flow_style=False)
            out.close()
    elif isinstance(dobj, list):
        out = openTextFileWrite(yamlPath, 0)
        if out is not None:
            yaml.dump(dobj, out, default_flow_style=False)
            out.close()


def timeNow(gimmeInt=False):
    if gimmeInt is True:
        return int(time.time())
    return time.time()


def listContains(l, a):
    if isinstance(l, list):
        for v in l:
            if stringMatch(v, a):
                return True
    return False


def listAdd(l, a):
    for v in l:
        if stringMatch(v, a):
            return l
    l.append(a)
    return l


def listClean(l):
    while len(l) > 0:
        a = l.pop()
    return l


def listGetLast(l):
    return l[len(l)-1]


def openBinaryFileRead(fpath):
    if os.path.isfile(fpath):
        return open(fpath, 'rb')
    return None


def openBinaryFileWrite(fpath):
    return open(fpath, 'wb')


def openTextFileWrite(fpath, mode=None, encoding='ascii'):
    if mode is None:
        mode = 0
    if mode == 1:
        return open(fpath, 'a', encoding=encoding)
    return open(fpath, 'w', encoding=encoding)


def charIsNewline(a):
    if a == 10:
        return True
    elif a == 13:
        return True
    return False


def charIsWhitespace(a):
    if a == 9:
        return True
    elif a == 32:
        return True
    elif a == 254:
        return True
    elif a == 255:
        return True
    return False
