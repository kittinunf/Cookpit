#pragma once

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "coordinate.hpp"

namespace djinni
{
  struct Coordinate {
      using CppType = cookpit::coordinate;
      using ObjcType = NSValue*;

      static CppType toCpp(ObjcType x) {
        CLLocationCoordinate2D coordinate;
        [x getValue:&coordinate];
        return cookpit::coordinate(coordinate.latitude, coordinate.longitude);
      }

      static ObjcType fromCpp(CppType x) {
        CLLocationCoordinate2D coordinate = { x.lat_, x.lng_ };
        return [NSValue valueWithBytes:&coordinate objCType:@encode(CLLocationCoordinate2D)];
      }

      using Boxed = Coordinate;
  };
} // namespace djinni
