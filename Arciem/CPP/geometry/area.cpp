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

#include "area.hpp"
#include "stringstreams.hpp"
#include "math_utils.hpp"

#include <algorithm>
#include <iostream>

using namespace std;
using namespace arciem;

namespace arciem {

area const& area::zero() { static area* a = new area(); return *a; }

double area::inset(double min, double size, double inset)
{
	double halfSize = size / 2.0;
	if(inset > halfSize) {
		inset = halfSize;
	}
	return inset;
}

area area::inset(double x_inset, double y_inset) const
{
	double x_min = this->x_min();
	double y_min = this->y_min();
	x_inset = inset(x_min, size.dx, x_inset);
	y_inset = inset(y_min, size.dy, y_inset);
	double newXMin = x_min + x_inset;
	double newYMin = y_min + y_inset;
	double newXMax = x_max() - x_inset;
	double newYMax = y_max() - y_inset;
	return area(newXMin, newYMin, newXMax, newYMax, 0);
}

area area::union_no_empty(area const& a) const
{
	return area(
		min(x_min(), a.x_min()),
		min(y_min(), a.y_min()),
		max(x_max(), a.x_max()),
		max(y_max(), a.y_max()),
		0
	);
}

area area::union_no_empty(point2 const& p) const
{
	return area(
		min(x_min(), p.x),
		min(y_min(), p.y),
		max(x_max(), p.x),
		max(y_max(), p.y),
		0
	);
}

area area::union_with_empty(area const& a) const
{
	if(a.empty()) {
		if(empty()) {
			return area::zero();
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

bool area::contains(area const& a) const
{
	return a.x_min() >= x_min() && a.x_max() <= x_max() && a.y_min() >= y_min() && a.y_max() <= y_max();
}

bool area::overlap(area const& a) const
{
	return x_min() <= a.x_max() && x_max() >= a.x_min() && y_min() <= a.y_max() && y_max() >= a.y_min();
}

area::area(point2 const& corner1, point2 const& corner2)
{
	double x_min = min(corner1.x, corner2.x);
	double x_max = max(corner1.x, corner2.x);
	double y_min = min(corner1.y, corner2.y);
	double y_max = max(corner1.y, corner2.y);
	origin.x = x_min;
	origin.y = y_min;
	size.dx = x_max - x_min;
	size.dy = y_max - y_min;
}

string area::to_string() const
{
	outputstringstream o;
	
	o << "[origin:" << origin.to_string() << " size:" << size.to_string() << "]";
	
	return o.extract();
}

area area::integral() const
{
	if(empty()) {
		return zero();
	} else {
		return area(floor(x_min()), floor(y_min()), ceil(x_max()), ceil(y_max()), 0);
	}
}

area area::interpolate(area const& a, double fraction) const {
	return area(
		denormalize(fraction, x_min(), a.x_min()),
		denormalize(fraction, y_min(), a.y_min()),
		denormalize(fraction, x_max(), a.x_max()),
		denormalize(fraction, y_max(), a.y_max()),
		0
	);
}

area area::set_x_center(double x) const
{
	area a(*this);
	a.origin.x += x - x_center();
	return a;
}

area area::set_y_center(double y) const
{
	area a(*this);
	a.origin.y += y - y_center();
	return a;
}

area area::set_center(point2 const& p) const
{
	area a(*this);
	a.origin.x += p.x - x_center();
	a.origin.y += p.y - y_center();
	return a;
}

area area::flip_relative_to(area const& a) const
{
	area r(*this);
	r.origin.y = -r.size.dy - r.origin.y + a.size.dy + a.origin.y;
    return r;
}

area area::set_x_min(double x, bool flexible) const
{
	if(flexible) {
		double xMax = x_max();
		return area(std::min(x, xMax), y_min(), xMax, y_max(), 0);
	} else {
		return area(x, origin.y, size.dx, size.dy);
	}
}

area area::set_y_min(double y, bool flexible) const
{
	if(flexible) {
		double yMax = y_max();
		return area(x_min(), std::min(y, yMax), x_max(), yMax, 0);
	} else {
		return area(origin.x, y, size.dx, size.dy);
	}
}

area area::set_x_max(double x, bool flexible) const
{
	if(flexible) {
		double xMin = x_min();
		return area(xMin, y_min(), std::max(x, xMin), y_max(), 0);
	} else {
		return area(x - size.dx, origin.y, size.dx, size.dy);
	}
}

area area::set_y_max(double y, bool flexible) const
{
	if(flexible) {
		double yMin = y_min();
		return area(x_min(), yMin, x_max(), std::max(y, yMin), 0);
	} else {
		return area(origin.x, y - size.dy, size.dx, size.dy);
	}
}

area area::set_dx(double n, bool flexible_max) const
{
	if(flexible_max) {
		return area(origin, delta2(n, size.dy));
	} else {
		return area(x_max() - n, y_min(), x_max(), y_max(), 0);
	}
}

area area::set_dy(double n, bool flexible_max) const
{
	if(flexible_max) {
		return area(origin, delta2(size.dx, n));
	} else {
		return area(x_min(), y_max() - n, x_max(), y_max(), 0);
	}
}

area area::set_origin(point2 const& o, bool flexible_max) const
{
	if(flexible_max) {
		return area(o, size);
	} else {
		return area(o.x, o.y, x_max(), y_max(), 0);
	}
}

area area::normalize() const
{
	double x1 = x_min(); double x2 = x_max(); order(x1, x2);
	double y1 = y_min(); double y2 = y_max(); order(y1, y2);
	return area(x1, y1, x2, y2, 0);
}

area area::align_to(point2 const& p, align_t align) const
{
	area result(*this);
	
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

area area::align_to(area const& a, align_t align) const
{
	area result(*this);
	
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