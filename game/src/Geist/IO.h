///////////////////////////////////////////////////////////////////////////////
//
// Name:     IO.H
// Author:   Anthony Salter
// Date:     5/08/18
// Purpose:  This file contains functions, classes and structures for
//           reading from and writing to files.  It covers:
//           
//           Configuration files (Config class): A configuration is a
//           series of key/value pairs (handled as an unordered_map) where
//           the key is a string that denotes the name of the value and
//           the value is the value itself.  This allows parsing of classic
//           "this = that" configuration files.  The configuration system
//           can be used with any file of any file extension, but I use
//           files with the .cfg extension.  Configuration files are meant
//           to be human-readable and modifiable, which is why they are
//           handled differently from serialized files (see below).
//
//           Logging (Log() function): A one-call-does-it-all logging
//           function.  Call Log() with a string you want logged and it
//           gets logged to runlog.txt in the root of the game.  This
//           function uses a static global file handle to do its magic,
//           which is a bit dirty but a small price to pay for the Log()
//           file always being available - even during Engine construction,
//           when nothing has been made yet!
//           
//           Serialization functions (in the IO namespace): these global
//           functions allow serialization and deserialization of the four
//           basic types: ints, floats, bools and strings.
//
//           Here's how to use this system: create a stream that is derived
//           from iostream and pass that into the function along with the
//           data to manipulate and whether or not you're reading or
//           writing (by default you're reading).  The functions will then
//           handle reading/writing to the stream.
//
//           Because you can use any iostream-based stream, you can stream
//           to file streams, string streams - you can even stream to cin
//           and cout if you want!
//
//           Note that these functions are fail-deadly - attempting to write
//           to an input stream or read from an output stream will throw,
//           aborting your program.  I felt this was better than silently
//           failing since that could easily create hard-to-find bugs.
//
///////////////////////////////////////////////////////////////////////////////

#ifndef _IO_H_
#define _IO_H_

#include <vector>
#include <unordered_map>
#include <string>
#include <iostream>

namespace IO
{
	//  Serialization
	void Serialize(std::istream& stream, int& data);
	void Serialize(std::istream& stream, unsigned int& data);
	void Serialize(std::istream& stream, float& data);
	void Serialize(std::istream& stream, bool& data);
	void Serialize(std::istream& stream, std::string& data);

	void Serialize(std::ostream& stream, const int data);
	void Serialize(std::ostream& stream, const unsigned int data);
	void Serialize(std::ostream& stream, const float data);
	void Serialize(std::ostream& stream, const bool data);
	void Serialize(std::ostream& stream, const std::string data);
};
#endif
