#include "api.hpp"

static cookpit::api_impl instance_;

namespace cookpit
{
void api::set_path(const std::string& path) { instance_.path(path); }

void api::set_http(const std::shared_ptr<http>& http) { instance_.client(http); }

api_impl& api_impl::instance() { return instance_; }

string api_impl::path() const { return path_; }
void api_impl::path(const string& path) { path_ = path; }

shared_ptr<http> api_impl::client() const { return http_client_; }
void api_impl::client(const shared_ptr<http>& http_client) { http_client_ = http_client; }
}
