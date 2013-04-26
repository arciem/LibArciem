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

#ifndef ARCIEM_ALIGN_HPP
#define ARCIEM_ALIGN_HPP

namespace arciem {

typedef int align_t;

static const align_t align_mask_none	= 0;
static const align_t align_mask_min		= 1;
static const align_t align_mask_center	= 2;
static const align_t align_mask_max		= 4;

static const align_t align_shift_x		= 0;
static const align_t align_shift_y		= 3;
static const align_t align_shift_z		= 6;

static const align_t align_x_none	= align_mask_none	<< align_shift_x;
static const align_t align_x_min	= align_mask_min	<< align_shift_x;
static const align_t align_x_center	= align_mask_center	<< align_shift_x;
static const align_t align_x_max	= align_mask_max	<< align_shift_x;

static const align_t align_y_none	= align_mask_none	<< align_shift_y;
static const align_t align_y_min	= align_mask_min	<< align_shift_y;
static const align_t align_y_center	= align_mask_center	<< align_shift_y;
static const align_t align_y_max	= align_mask_max	<< align_shift_y;

static const align_t align_z_none	= align_mask_none	<< align_shift_z;
static const align_t align_z_min	= align_mask_min	<< align_shift_z;
static const align_t align_z_center	= align_mask_center	<< align_shift_z;
static const align_t align_z_max	= align_mask_max	<< align_shift_z;

static const align_t align_all_none			= align_x_none		| align_y_none		| align_z_none;
static const align_t align_all_min			= align_x_min		| align_y_min		| align_z_min;
static const align_t align_all_center		= align_x_center	| align_y_center	| align_z_center;
static const align_t align_all_max			= align_x_max		| align_y_max		| align_z_max;

} 
#endif // ARCIEM_ALIGN_HPP