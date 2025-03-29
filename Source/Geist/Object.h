///////////////////////////////////////////////////////////////////////////
//
// Name:     OBJECT.H
// Author:   Anthony Salter
// Date:     11/13/17
// Purpose:  Class for the representation of all in-game objects. An
//           object is defined as anything that can be created at run-time
//           can be drawn and updates itself, and can be destroyed at
//           run-time. This is an abstract class and cannot be instantiated
//           itself, which is why it has no associated CPP file.  All
//           objects derived from Object should have a unique numeric ID.
//
///////////////////////////////////////////////////////////////////////////

#ifndef _OBJECT_H_
#define _OBJECT_H_

#include <string>

//  This class has been rewritten with C++11/14/17 move semantics in mind.
//  It uses the default destructor, copy constructor, assignment operator,
//  move constructor and move assignment operator.  As long as you (and I
//  mean the you deriving subclasses from this class) write your classes
//  in such a way that they do not need a custom destructor, the defaults
//  will work perfectly.  If you DO have to write a custom destructor, you
//  will need to write all the other functions as well.  So do your best
//  not to do that.
//
//  This class defines two constructors as a template for subclasses. The
//  first constructor takes no parameters and constructs the object using
//  default parameters.  The second takes a string naming a file that has
//  custom parameters.  If the file cannot be loaded, the constructor
//  throws an exception.  This is the most desireable behavior since
//  constructors can't return pass/fail values.
class Object
{
public:
	Object() { };
	explicit Object(const std::string& file) { };
	Object(const Object&) = default;             //  Default copy constructor
	Object(Object&&) = default;                  //  Default move constructor
	Object& operator=(const Object&) = default;  //  Default assignment operator
	Object& operator=(Object&&) = default;       //  Default move operator
	virtual ~Object() = default;                 //  Default destructor

	virtual void Init() { Init(std::string("")); }
	virtual void Init(const std::string& data) = 0;
	virtual void Update() = 0;
	virtual void Draw() = 0;

	int m_ID = -1;
};

#endif