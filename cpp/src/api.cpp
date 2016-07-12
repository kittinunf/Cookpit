#include "api.hpp"

#include <iostream>
#include <lmdb++.h>

static cookpit::api_impl instance_;

namespace cookpit
{
void api::set_path(const std::string& path) {
  instance_.path(path);

  auto env = lmdb::env::create();
  env.open(path.c_str());

  auto write = lmdb::txn::begin(env);

  auto db = lmdb::dbi::open(write);
  db.put(write, "username", "kittinun.f@gmail.com");
  db.put(write, "token", "eyJhbGciOiJIUzI1NiIs");
  write.commit();

  auto read = lmdb::txn::begin(env, nullptr, MDB_RDONLY);
  auto cursor = lmdb::cursor::open(read, db);
  string key, value;
  while (cursor.get(key, value, MDB_NEXT)) {
    cout << "key: " << key << ", value: " << value << endl;
  }

  cursor.close();
  read.abort();
}

api_impl& api_impl::instance() { return instance_; }

string api_impl::path() const { return path_; }
void api_impl::path(const string& path) { path_ = path; }
}
