//////////////////////////////////////////////////////////////////////////
//  Name:    RNG.H
//  Author:  Anthony Salter
//  Date:    8/7/08
//  Purpose: This file encapsulates a lightweight random number generator
//           that includes the ability to save and restore the RNG's
//           state.  The actual generation function is the classic
//           Marsenne Twister.
//////////////////////////////////////////////////////////////////////////

#include <random>

#ifndef _RNG_H_
#define _RNG_H_

#define CMATH_N 624
#define CMATH_M 397

class RNG
{
public:
	RNG() : m_SeedTable{0} {}
	void          SeedRNG(unsigned int seed);
	unsigned int  Random(unsigned int range);
	float         RandomFloat(float range);
	int           RandomRange(unsigned int min, unsigned int max);
	float         RandomRangeFloat(float min, float max);
	void          GetRNGState(unsigned int& seed, unsigned int& index);
	void          SetRNGState(unsigned int seed, unsigned int index);
	unsigned int  GetOriginalSeed() { return m_OriginalSeed; } //  Useful for debugging
	void          SeedFromSystemTimer(void);

private:
	unsigned long m_SeedTable[CMATH_N];
	unsigned int  m_SeedIndex = 0;
	unsigned int  m_OriginalSeed = 0;
	unsigned int  m_NumberOfGeneratedNumbers = 0;
};

#endif