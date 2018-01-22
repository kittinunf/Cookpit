#include "api.hpp"

static cookpit::api_impl instance_;

namespace cookpit
{
void api::set_path(const string& path) { instance_.path(path); }

void api::set_proxy(const string& proxy) { instance_.proxy(proxy); }

api_impl& api_impl::instance() { return instance_; }

string api_impl::path() const { return path_; }
void api_impl::path(const string& path) { path_ = path; }

optional<string> api_impl::proxy() const { return proxy_; }
void api_impl::proxy(const string& proxy) { proxy_ = proxy; }

lmdb::env api_impl::db(const string& name) {
  auto env = lmdb::env::create();
  auto db_path = path_ + "/" + name;
  env.open(db_path.c_str(), MDB_NOSUBDIR);
  return env;
}
}
