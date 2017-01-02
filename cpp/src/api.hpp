#pragma once

#include "gen/api.hpp"

#include <lmdb++.h>

using namespace std;

namespace cookpit
{
class api_impl : public api {
 public:
  static api_impl& instance();

  string path() const;
  void path(const string& path);

  lmdb::env db(const string& name);

 private:
  string path_;
};
}
