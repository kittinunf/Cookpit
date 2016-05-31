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

  shared_ptr<http> client() const;
  void client(const shared_ptr<http>& http_client);

 private:
  string path_;

  shared_ptr<http> http_client_;
};
}
