#pragma once

#include <experimental/optional>
#include <lmdb++.h>

#include "gen/api.hpp"

using namespace std;
using namespace std::experimental;

namespace cookpit
{
class api_impl : public api {
 public:
  static api_impl& instance();

  string path() const;
  void path(const string& path);

  optional<string> proxy() const;
  void proxy(const string& proxy);

  lmdb::env db(const string& name);

 private:
  string path_;
  optional<string> proxy_ = {};
};
}
