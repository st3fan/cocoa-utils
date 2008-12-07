/*
 * Copyright 2008 Stefan Arentz <stefan@arentz.nl>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "NSMutableArrayAdditions.h"

@implementation NSMutableArray (RowMoving)

- (void) moveRowAtIndex: (NSUInteger) from toIndex: (NSUInteger) to
{
   if (from < [self count] && to < [self count] && from != to) {
      if (abs(from - to) == 1) {
         [self exchangeObjectAtIndex: from withObjectAtIndex: to];
      } else {
         NSMutableIndexSet* indexes = [NSMutableIndexSet new];
         NSMutableArray* objects = [NSMutableArray new];
         if (from > to) {
            [indexes addIndex: to];
            [objects addObject: [self objectAtIndex: from]];
            for (NSUInteger i = to + 1; i <= from; i++) {
               [indexes addIndex: i];
               [objects addObject: [self objectAtIndex: i - 1]];
            }
         } else {
            for (NSUInteger i = from; i <= to - 1; i++) {
               [indexes addIndex: i];
               [objects addObject: [self objectAtIndex: i + 1]];
            }
            [indexes addIndex: to];
            [objects addObject: [self objectAtIndex: from]];
         }
         [self replaceObjectsAtIndexes: indexes withObjects: objects];
         [indexes release];
         [objects release];
      }
   }
}

@end
