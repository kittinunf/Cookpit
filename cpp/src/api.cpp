#include "api.hpp"

static cookpit::api instance_;

namespace cookpit
{
void Api::set_path(const std::string& path) { instance_.path(path); }

void Api::set_http(const std::shared_ptr<Http>& http) { instance_.client(http); }

api& api::instance() { return instance_; }

string api::path() const { return path_; }
void api::path(const string& path) { path_ = path; }

shared_ptr<Http> api::client() const { return http_client_; }
void api::client(const shared_ptr<cookpit::Http>& http_client) { http_client_ = http_client; }
}
