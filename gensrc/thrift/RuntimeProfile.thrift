// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

namespace cpp starrocks
namespace java com.starrocks.thrift

include "Metrics.thrift"

enum TCounterAggregateType {
    // Use sum for both be and fe phases
    SUM,
    // Use avg for both be and fe phases
    AVG,
    // Use sum at be phase and avg at fe phase 
    SUM_AVG,
    // Use avg at be phase and sum at fe phase
    AVG_SUM,
}

enum TCounterMergeType {
    MERGE_ALL, 
    SKIP_ALL,
    SKIP_FIRST_MERGE,
    SKIP_SECOND_MERGE,
}

enum TCounterMinMaxType {
  MIN_MAX_ALL = 0,
  SKIP_ALL = 1
}

struct TCounterStrategy {
    1: required TCounterAggregateType aggregate_type
    2: required TCounterMergeType merge_type
    3: required i64 display_threshold = 0
    4: optional TCounterMinMaxType min_max_type = TCounterMinMaxType.MIN_MAX_ALL
}

// Counter data
struct TCounter {
  1: required string name
  2: required Metrics.TUnit type
  3: required i64 value 
  5: optional TCounterStrategy strategy 
  
  // Added to reduce the total number of counters
  6: optional i64 min_value
  7: optional i64 max_value
}

// A single runtime profile
struct TRuntimeProfileNode {
  1: required string name
  2: required i32 num_children 
  3: required list<TCounter> counters
  // TODO: should we make metadata a serializable struct?  We only use it to
  // store the node id right now so this is sufficient.
  4: required i64 metadata

  // indicates whether the child will be printed with extra indentation;
  // corresponds to indent param of RuntimeProfile::AddChild()
  5: required bool indent

  // map of key,value info strings that capture any kind of additional information 
  // about the profiled object
  6: required map<string, string> info_strings

  // Auxilliary structure to capture the info strings display order when printed
  7: required list<string> info_strings_display_order
  
  // map from parent counter name to child counter name
  8: required map<string, set<string>> child_counters_map

  // The version of this profile
  9: optional i64 version
}

// A flattened tree of runtime profiles, obtained by an
// in-order traversal
struct TRuntimeProfileTree {
  1: required list<TRuntimeProfileNode> nodes
}
