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

#include <arciem/geometry/areai.hpp>

#include <algorithm>
#include <arciem/stringstreams.hpp>
#include <iostream>

#include <arciem/math_utils.hpp>

using namespace std;

namespace arciem {

areai const& areai::zero() { static areai* a = new areai(); return *a; }

int areai::inset(int min, int size, int inset)
{
	int halfSize = size / 2;
	if(inset > halfSize) {
		inset = halfSize;
	}
	return inset;
}

areai areai::inset(int x_inset, int y_inset) const
{
	int x_min = this->x_min();
	int y_min = this->y_min();
	x_inset = inset(x_min, size.dx, x_inset);
	y_inset = inset(y_min, size.dy, y_inset);
	int newXMin = x_min + x_inset;
	int newYMin = y_min + y_inset;
	int newXMax = x_max() - x_inset;
	int newYMax = y_max() - y_inset;
	return areai(newXMin, newYMin, newXMax, newYMax, 0);
}

areai areai::union_no_empty(areai const& a) const
{
	return areai(
		min(x_min(), a.x_min()),
		min(y_min(), a.y_min()),
		max(x_max(), a.x_max()),
		max(y_max(), a.y_max()),
		0
	);
}

areai areai::union_with_empty(areai const& a) const
{
	if(a.empty()) {
		if(empty()) {
			return areai::zero();
		} else {
			return *this;
		}
	} else {
		if(empty()) {
			return a;
		} else {
			return union_no_empty(a);
		}
	}
}

areai::areai(point2i const& corner1, point2i const& corner2)
{
	int x_min = min(corner1.x, corner2.x);
	int x_max = max(corner1.x, corner2.x);
	int y_min = min(corner1.y, corner2.y);
	int y_max = max(corner1.y, corner2.y);
	origin.x = x_min;
	origin.y = y_min;
	size.dx = x_max - x_min - 1;
	size.dy = y_max - y_min - 1;
}

bool areai::contains(areai const& a) const
{
	return a.x_min() >= x_min() && a.x_max() <= x_max() && a.y_min() >= y_min() && a.y_max() <= y_max();
}

bool areai::overlap(areai const& a) const
{
	return x_min() <= a.x_max() && x_max() >= a.x_min() && y_min() <= a.y_max() && y_max() >= a.y_min();
}

string areai::to_string() const
{
	outputstringstream o;
	
	o << "[origin:" << origin.to_string() << " size:" << size.to_string() << "]";
	
	return o.extract();
}

areai areai::set_x_center(int x) const
{
	areai a(*this);
	a.origin.x += x - x_center();
	return a;
}

areai areai::set_y_center(int y) const
{
	areai a(*this);
	a.origin.y += y - y_center();
	return a;
}

areai areai::set_center(point2i const& p) const
{
	areai a(*this);
	a.origin.x += p.x - x_center();
	a.origin.y += p.y - y_center();
	return a;
}

areai areai::flip_relative_to(areai const& a) const
{
	areai r(*this);
	r.origin.y = -r.size.dy - r.origin.y + a.size.dy + a.origin.y;
    return r;
}

areai areai::set_x_min(int x, bool flexible) const
{
	if(flexible) {
		return areai(x, y_min(), x_max(), y_max(), 0);
	} else {
		return areai(x, origin.y, size.dx, size.dy);
	}
}

areai areai::set_y_min(int y, bool flexible) const
{
	if(flexible) {
		return areai(x_min(), y, x_max(), y_max(), 0);
	} else {
		return areai(origin.x, y, size.dx, size.dy);
	}
}

areai areai::set_x_max(int x, bool flexible) const
{
	if(flexible) {
		return areai(x_min(), y_min(), x, y_max(), 0);
	} else {
		return areai(x - size.dx, origin.y, size.dx, size.dy);
	}
}

areai areai::set_y_max(int y, bool flexible) const
{
	if(flexible) {
		return areai(x_min(), y_min(), x_max(), y, 0);
	} else {
		return areai(origin.x, y - size.dy, size.dx, size.dy);
	}
}

areai areai::set_dx(int n, bool flexible_max) const
{
	if(flexible_max) {
		return areai(origin, delta2i(n, size.dy));
	} else {
		return areai(x_max() - n, y_min(), x_max(), y_max(), 0);
	}
}

areai areai::set_dy(int n, bool flexible_max) const
{
	if(flexible_max) {
		return areai(origin, delta2i(size.dx, n));
	} else {
		return areai(x_min(), y_max() - n, x_max(), y_max(), 0);
	}
}

areai areai::set_origin(point2i const& o, bool flexible_max) const
{
	if(flexible_max) {
		return areai(o, size);
	} else {
		return areai(o.x, o.y, x_max(), y_max(), 0);
	}
}

areai areai::normalize() const
{
	int x1 = x_min(); int x2 = x_max(); order(x1, x2);
	int y1 = y_min(); int y2 = y_max(); order(y1, y2);
	return areai(x1, y1, x2, y2, 0);
}

areai areai::align_to(point2i const& p, align_t align) const
{
	areai result(*this);
	
	if(align & align_x_min) {
		result = result.set_x_min(p.x);
	} else if(align & align_x_center) {
		result = result.set_x_center(p.x);
	} else if(align & align_x_max) {
		result = result.set_x_max(p.x);
	}
	
	if(align & align_y_min) {
		result = result.set_y_min(p.y);
	} else if(align & align_y_center) {
		result = result.set_y_center(p.y);
	} else if(align & align_x_max) {
		result = result.set_y_max(p.y);
	}
	
	return result;
}

areai areai::align_to(areai const& a, align_t align) const
{
	areai result(*this);
	
	if(align & align_x_min) {
		result = result.set_x_min(a.x_min());
	} else if(align & align_x_center) {
		result = result.set_x_center(a.x_center());
	} else if(align & align_x_max) {
		result = result.set_x_max(a.x_max());
	}
	
	if(align & align_y_min) {
		result = result.set_y_min(a.y_min());
	} else if(align & align_y_center) {
		result = result.set_y_center(a.y_center());
	} else if(align & align_x_max) {
		result = result.set_y_max(a.y_max());
	}
	
	return result;
}

}