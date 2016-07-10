#include "api.hpp"

static cookpit::api_impl instance_;

namespace cookpit
{
void api::set_path(const std::string& path) { instance_.path(path); }

api_impl& api_impl::instance() { return instance_; }

string api_impl::path() const { return path_; }
void api_impl::path(const string& path) { path_ = path; }
}
