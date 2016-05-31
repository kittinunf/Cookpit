#include "api.hpp"

static cookpit::api instance_;

namespace cookpit
{
void Api::set_path(const std::string& path) { instance_.path(path); }

api& api::instance() { return instance_; }

string api::path() const { return path_; }
void api::path(const string& path) { path_ = path; }
}
