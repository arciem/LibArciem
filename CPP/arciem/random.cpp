/*******************************************************************************
 
 Copyright 2011 Arciem LLC
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 *******************************************************************************/

#include "random.hpp"
#include "math_utils.hpp"

#include <stdlib.h>
#include <time.h>
#include <iostream>
#include <cmath>

namespace arciem {

void seed_random()
{
	unsigned s = (unsigned)time(NULL);
//	std::cout << "seed_random:" << s << std::endl;
    srand(s);
}

double random_flat()
{
    return rand() / (((double)RAND_MAX) + 1.0);
}

double random_range(double lo, double hi)
{
    return denormalize(random_flat(), lo, hi);
}

// http://www.taygeta.com/random/gaussian.html
double random_gaussian()
{
    return std::sqrt( -2.0 * std::log(random_flat()) ) * std::cos( 2.0 * M_PI * random_flat() );
}

/* +++Date last modified: 05-Jul-1997 */

/*
**  longrand() -- generate 2**31-2 random numbers
**
**  public domain by Ray Gardner
** 
**  based on "Random Number Generators: Good Ones Are Hard to Find",
**  S.K. Park and K.W. Miller, Communications of the ACM 31:10 (Oct 1988),
**  and "Two Fast Implementations of the 'Minimal Standard' Random
**  Number Generator", David G. Carta, Comm. ACM 33, 1 (Jan 1990), p. 87-88
**
**  linear congruential generator f(z) = 16807 z mod (2 ** 31 - 1)
**
**  uses L. Schrage's method to avoid overflow problems
*/

#define a 16807		/* multiplier */
#define m 2147483647L	/* 2**31 - 1 */
#define q 127773L		/* m div a */
#define r 2836		/* m mod a */

long nextlongrand(long seed)
{
	unsigned long lo, hi;

	lo = a * (long)(seed & 0xFFFF);
	hi = a * (long)((unsigned long)seed >> 16);
	lo += (hi & 0x7FFF) << 16;
	if (lo > m)
	{
		lo &= m;
		++lo;
	}
	lo += hi >> 15;
	if (lo > m)
	{
		lo &= m;
		++lo;
	}
	return (long)lo;
}

static long randomnum = 1;

long longrand(void)			    /* return next random long */
{
	randomnum = nextlongrand(randomnum);
	return randomnum;
}

void slongrand(unsigned long seed)	    /* to seed it */
{
	randomnum = seed ? (seed & m) : 1;	/* nonzero seed */
}

} // namespace