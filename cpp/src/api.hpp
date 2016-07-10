#pragma once

#include "gen/api.hpp"

using namespace std;

namespace cookpit
{
class api_impl : public api {
 public:
  static api_impl& instance();

  string path() const;
  void path(const string& path);

 private:
  string path_;
};
}
