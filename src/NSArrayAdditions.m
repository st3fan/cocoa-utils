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

#import "NSArrayAdditions.h"

@implementation NSArray (ArrayAdditions)

+ (NSArray*) shuffledArrayWithArray: (NSArray*) array
{
   NSMutableArray* shuffled = [NSMutableArray arrayWithArray: array];
   if (shuffled == nil) {
      return nil;
   }

   NSUInteger n = [array count];
   while (n > 1) {
      NSUInteger k = rand() % n;
      n--;
      [shuffled exchangeObjectAtIndex: n withObjectAtIndex: k];
   }

   return [self arrayWithArray: shuffled];
}

@end

