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

#include <arciem/geometry/volume.hpp>

#include <arciem/geometry/area.hpp>

namespace arciem {

volume const& volume::zero() { static volume* v = new volume(); return *v; }

void volume::inset(double x_inset, double y_inset, double z_inset)
{
	double x_min = this->x_min();
	double y_min = this->y_min();
	double z_min = this->z_min();
	x_inset = area::inset(x_min, size.dx, x_inset);
	y_inset = area::inset(y_min, size.dy, y_inset);
	z_inset = area::inset(z_min, size.dz, z_inset);
	assign(x_min + x_inset, y_min + y_inset, z_min + z_inset, x_max() - x_inset, y_max() - y_inset, z_max() - z_inset);
}

void volume::inset(double x_inset, double y_inset, double z_inset, volume& dst) const
{
	dst = *this;
	dst.inset(x_inset, y_inset, z_inset);
}

void volume::assign(double x_min, double y_min, double z_min, double x_max, double y_max, double z_max)
{
	origin.assign(x_min, y_min, z_min);
	size.assign(x_max - x_min, y_max - y_min, z_max - z_min);
}

}