#include "RNG.h"
#include <stdlib.h>
#include <time.h>

void RNG::SeedFromSystemTimer(void)
{
	SeedRNG((unsigned int)time(NULL));
}

void RNG::SeedRNG(unsigned int n)
{
	m_SeedTable[0] = n & 0xffffffff;
	for (m_SeedIndex = 1; m_SeedIndex < CMATH_N; m_SeedIndex++)
	{
		m_SeedTable[m_SeedIndex] = (69069 * m_SeedTable[m_SeedIndex - 1]) & 0xffffffff;
	}

	m_OriginalSeed = n;
	m_NumberOfGeneratedNumbers = 0;
}

//  Returns a random number greater than or equal to zero and less than n.
unsigned int RNG::Random(unsigned int n)
{
	unsigned long y;
	static unsigned long mag01[2] = { 0x0,  0x9908b0df };

	if (n == 0)
	{
		return(0);
	}

	if (m_SeedIndex >= CMATH_N)
	{
		int kk;

		if (m_SeedIndex == CMATH_N + 1)
		{
			SeedRNG(32767);
		}

		for (kk = 0; kk < CMATH_N - CMATH_M; kk++)
		{
			y = (m_SeedTable[kk] & 0x80000000) | (m_SeedTable[kk + 1] & 0x7fffffff);
			m_SeedTable[kk] = m_SeedTable[kk + CMATH_M] ^ (y >> 1) ^ mag01[y & 0x1];
		}

		for (; kk < CMATH_N - 1; kk++)
		{
			y = (m_SeedTable[kk] & 0x80000000) | (m_SeedTable[kk + 1] & 0x7fffffff);
			m_SeedTable[kk] = m_SeedTable[kk + (CMATH_M - CMATH_N)] ^ (y >> 1) ^ mag01[y & 0x1];
		}

		y = (m_SeedTable[CMATH_N - 1] & 0x80000000) | (m_SeedTable[0] & 0x7fffffff);
		m_SeedTable[CMATH_N - 1] = m_SeedTable[CMATH_M - 1] ^ (y >> 1) ^ mag01[y & 0x1];

		m_SeedIndex = 0;
	}

	y = m_SeedTable[m_SeedIndex++];
	y ^= (y >> 11);
	y ^= (y << 7) & 0x9d2c5680;
	y ^= (y << 15) & 0xefc60000;
	y ^= (y >> 18);

	++m_NumberOfGeneratedNumbers;

	return (y % n);
}

//  Returns a number between min and max, inclusive.
int RNG::RandomRange(unsigned int min, unsigned int max)
{
	return Random((max - min) + 1) + min;
}

//  Returns a random floating-point number greater than or
//  equal to min and less than max.
//  
//  If you want min and max to be more common, you might want
//  to call RandomRange() with a multiplied min and max and
//  then divide back out.  IE, (RandomRange(0, 11) / 10.0f)
//  for a floating point number between 0 and 1 where 0 and 1
//  actually come up fairly often.
float RNG::RandomRangeFloat(float min, float max)
{
	unsigned int r = Random(0xffffffff);
	float divisor = (float)0xffffffff;
	float multiplicand = (r / divisor);

	return((multiplicand * (max - min)) + min);
}

//  Returns a random floating-point number greater than or
//  equal to zero and less than max.
float RNG::RandomFloat(float max)
{
	return RandomRangeFloat(0, max);
}

void RNG::GetRNGState(unsigned int& seed, unsigned int& index)
{
	seed = m_OriginalSeed;
	index = m_NumberOfGeneratedNumbers;
}

void RNG::SetRNGState(unsigned int seed, unsigned int index)
{
	SeedRNG(seed);
	for (unsigned int i = 0; i < index; ++i)
	{
		Random(0xffffffff);
	}
}