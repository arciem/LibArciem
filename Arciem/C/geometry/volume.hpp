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

#ifndef ARCIEM_VOLUME_H
#define ARCIEM_VOLUME_H

#include "point3.hpp"
#include "delta3.hpp"

namespace arciem {

class volume {
public:
	point3 origin;
	delta3 size;
	
	volume() { }
	volume(const point3& origin, const delta3& size) : origin(origin), size(size) { }
	volume(const delta3& size) : size(size) { }
	volume(double x, double y, double z, double dx, double dy, double dz) : origin(x, y, z), size(dx, dy, dz) { }
//	volume(const volume& v) : origin(v.origin), size(v.size) { }
	
	double x_min() const { return origin.x; }
	double x_max() const { return origin.x + size.dx; }
	double y_min() const { return origin.y; }
	double y_max() const { return origin.y + size.dy; }
	double z_min() const { return origin.z; }
	double z_max() const { return origin.z + size.dz; }
	
	void inset(double x_inset, double y_inset, double z_inset);
	void inset(double x_inset, double y_inset, double z_inset, volume& dst) const;
	void inset(double n) { inset(n, n, n); }
	void inset(double n, volume &dst) const { inset(n, n, n, dst); }
	
	void assign(double x_min, double y_min, double z_min, double x_max, double y_max, double z_max);
	
	void reflect_z() { origin.z = -(origin.z + size.dz); }
	void reflect_z(volume &dst) const { dst = *this; dst.reflect_z(); }

	static volume const& zero();
};

}

#endif // ARCIEM_VOLUME_H