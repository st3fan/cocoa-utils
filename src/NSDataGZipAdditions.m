/*
 * Copyright 2007 Stefan Arentz <stefan@arentz.nl>
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

#import <Foundation/Foundation.h>
#include <zlib.h>

#import "NSDataGZipAdditions.h"

@implementation NSData (GZip)

+ (id) compressedDataWithBytes: (const void*) bytes length: (unsigned) length
{
   unsigned long compressedLength = compressBound(length);
   unsigned char* compressedBytes = (unsigned char*) malloc(compressedLength);
   
   if (compressedBytes != NULL && compress(compressedBytes, &compressedLength, bytes, length) == Z_OK) {
      char* resizedCompressedBytes = realloc(compressedBytes, compressedLength);
      if (resizedCompressedBytes != NULL) {
         return [NSData dataWithBytesNoCopy: resizedCompressedBytes length: compressedLength freeWhenDone: YES];
      } else {
         return [NSData dataWithBytesNoCopy: compressedBytes length: compressedLength freeWhenDone: YES];
      }
   } else {
      free(compressedBytes);
      return nil;
   }
}

+ (id) compressedDataWithData: (NSData*) data
{
   return [self compressedDataWithBytes: [data bytes] length: [data length]];
}

+ (id) dataWithCompressedBytes: (const void*) bytes length: (unsigned) length
{
   z_stream strm;
   int ret;
   unsigned char out[128 * 1024];
   unsigned char* uncompressedData = NULL;
   unsigned int uncompressedLength = 0;

   strm.zalloc = Z_NULL;
   strm.zfree = Z_NULL;
   strm.opaque = Z_NULL;
   strm.avail_in = 0;
   strm.next_in = Z_NULL;
   
   ret = inflateInit(&strm);
   
   if (ret == Z_OK) {
      strm.avail_in = length;
      strm.next_in = (void*) bytes;

      do {
         strm.avail_out = sizeof(out);
         strm.next_out = out;

         ret = inflate(&strm, Z_NO_FLUSH);
         if (ret != Z_OK && ret != Z_STREAM_END) {
            NSLog(@"inflate: ret != Z_OK %d", ret);
            free(uncompressedData);
            inflateEnd(&strm);
            return nil;
         }

         unsigned int have = sizeof(out) - strm.avail_out;
         
         if (uncompressedData == NULL) {
            uncompressedData = malloc(have);
            memcpy(uncompressedData, out, have);
            uncompressedLength = have;
         } else {
            unsigned char* resizedUncompressedData = realloc(uncompressedData, uncompressedLength + have);
            if (resizedUncompressedData == NULL) {
               free(uncompressedData);
               inflateEnd(&strm);
               return nil;
            } else {
               uncompressedData = resizedUncompressedData;
               memcpy(uncompressedData + uncompressedLength, out, have);
               uncompressedLength += have;
            }
         }
      } while (strm.avail_out == 0);
   } else {
      NSLog(@"ret != Z_OK");
   }

   if (uncompressedData != NULL) {
      return [NSData dataWithBytesNoCopy: uncompressedData length: uncompressedLength freeWhenDone: YES];
   } else {
      return nil;
   }
}

+ (id) dataWithCompressedData: (NSData*) compressedData
{
   return [self dataWithCompressedBytes: [compressedData bytes] length: [compressedData length]];
}

@end
