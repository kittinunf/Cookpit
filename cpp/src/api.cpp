#include "api.hpp"

#include <iostream>
#include <lmdb++.h>

static cookpit::api_impl instance_;

namespace cookpit
{
void api::set_path(const string& path) { instance_.path(path); }

api_impl& api_impl::instance() { return instance_; }

string api_impl::path() const { return path_; }
void api_impl::path(const string& path) { path_ = path; }

lmdb::env api_impl::db(const string& name) {
  auto env = lmdb::env::create();
  auto db_path = path_ + "/" + name;
  env.open(db_path.c_str(), MDB_NOSUBDIR);
  env.set_mapsize(1 * 1024 * 1024);
  return env;
}
}
