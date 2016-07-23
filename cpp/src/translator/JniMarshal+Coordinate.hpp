#pragma once

#include "djinni_support.hpp"

namespace djinni
{
struct Coordinate
{
  using CppType = cookpit::coordinate;
  using JniType = jobject;

  using Boxed = Coordinate;

  static CppType toCpp(JNIEnv* jniEnv, JniType j)
  {
    assert(j != nullptr);
    const auto& data = JniClass<Coordinate>::get();
    assert(jniEnv->IsInstanceOf(j, data.clazz.get()));
    auto lat = jniEnv->CallDoubleMethod(j, data.method_get_lat);
    auto lng = jniEnv->CallDoubleMethod(j, data.method_get_lng);
    jniExceptionCheck(jniEnv);
    return cookpit::coordinate(lat, lng);
  }

  static LocalRef<JniType> fromCpp(JNIEnv* jniEnv, CppType c)
  {
    const auto& data = JniClass<Coordinate>::get();
    const jdouble lat = static_cast<jdouble>(c.lat_);
    const jdouble lng = static_cast<jdouble>(c.lng_);
    auto j = LocalRef<jobject>(jniEnv, jniEnv->NewObject(data.clazz.get(), data.constructor, lat, lng));
    jniExceptionCheck(jniEnv);
    return j;
  }

private:
  Coordinate() = default;
  friend ::djinni::JniClass<Coordinate>;

  const GlobalRef<jclass> clazz { jniFindClass("com/mapbox/mapboxsdk/geometry/LatLng") };
  const jmethodID constructor { jniGetMethodID(clazz.get(), "<init>", "(DD)V") };
  const jmethodID method_get_lat { jniGetMethodID(clazz.get(), "getLatitude", "()D") };
  const jmethodID method_get_lng { jniGetMethodID(clazz.get(), "getLongitude", "()D") };
};
}
