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

#ifndef ARCIEM_RANDOM_HPP
#define ARCIEM_RANDOM_HPP

namespace arciem {

// seeds the random number generator from the system clock
void seed_random();

// returns random value in range [0..1)
double random_flat();

// returns random value in range [lo..hi)
double random_range(double lo, double hi);

// returns random value with gaussian distribution, mean 0.0 and standard deviation 1.0
double random_gaussian();

void slongrand(unsigned long seed);	    /* to seed it */
long longrand(void);			    /* return next random long */

} // namespace

#endif // ARCIEM_RANDOM_HPP
