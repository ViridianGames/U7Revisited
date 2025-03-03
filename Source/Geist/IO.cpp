//  TODO - Write out config files in the same order they are read in, or as
//  close as possible.

#include "IO.h"
#include <fstream>
#include <sstream>

using namespace std;

//  IN-ONLY
void IO::Serialize(istream& stream, int& data) {
    if (stream.eof())
        throw("STREAM ENDED PREMATURELY!");

    char* joiner = (char*)&data;

    for (int i = 0; i < 4; ++i) {
        stream.get(*joiner);
        ++joiner;
    }
}

void IO::Serialize(istream& stream, unsigned int& data) {
    if (stream.eof())
        throw("STREAM ENDED PREMATURELY!");

    char* joiner = (char*)&data;

    for (int i = 0; i < 4; ++i) {
        stream.get(*joiner);
        ++joiner;
    }
}

void IO::Serialize(istream& stream, float& data) {
    if (stream.eof())
        throw("STREAM ENDED PREMATURELY!");

    char* joiner = (char*)&data;

    for (int i = 0; i < 4; ++i) {
        stream.get(*joiner);
        ++joiner;
    }
}

void IO::Serialize(istream& stream, bool& data) {
    if (stream.eof())
        throw("STREAM ENDED PREMATURELY!");

    int value;
    IO::Serialize(stream, value);
    if (value == 0)
        data = false;
    else if (value == 1)
        data = true;
    else
        throw("Bad data in IO::Serialize bool");
}

void IO::Serialize(istream& stream, string& data) {
    if (stream.eof())
        throw("STREAM ENDED PREMATURELY!");

    int length;
    IO::Serialize(stream, length);
    data.resize(length);
    char input[256];
    stream.get(input, length + 1);
    data.assign(input);
}

//  OUT-ONLY
void IO::Serialize(ostream& stream, const int data) {
    char* splitter = (char*)&data;

    for (int i = 0; i < 4; ++i) {
        stream.put(*splitter);
        ++splitter;
    }

    stream.flush();
}

void IO::Serialize(ostream& stream, const unsigned int data) {
    char* splitter = (char*)&data;

    for (int i = 0; i < 4; ++i) {
        stream.put(*splitter);
        ++splitter;
    }

    stream.flush();
}

void IO::Serialize(ostream& stream, const float data) {
    char* splitter = (char*)&data;

    for (int i = 0; i < 4; ++i) {
        stream.put(*splitter);
        ++splitter;
    }

    stream.flush();
}

//  Bools don't serialize well, so instead we'll just stream out a 0 or 1
//  instead of true or false;
void IO::Serialize(ostream& stream, const bool data) {
    if (data == false)
        IO::Serialize(stream, int(0));
    else
        IO::Serialize(stream, int(1));
}

void IO::Serialize(ostream& stream, const string data) {
    if (data.length() > 255)
        throw("Only strings less than 255 characters can be serialized.");

    IO::Serialize(stream, (unsigned int)data.length());
    for (unsigned int i = 0; i < data.length(); ++i)
        stream.put(data.c_str()[i]);
    stream.flush();
}
