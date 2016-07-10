#include "utility.hpp"

#include <sstream>

using namespace string_literals;

namespace cookpit
{
string construct_flickr_image_url(int farm, const string& server, const string& photo_id, const string& secret) {
  ostringstream oss;
  oss << "https://farm"s << farm << ".static.flickr.com/"s << server << "/"s << photo_id << "_" << secret << "_z.jpg"s;
  return oss.str();
}

string construct_flickr_avatar_url(int farm, const string& server, const string& ns_id) {
  ostringstream oss;
  oss << "https://c2.staticflickr.com/"s << farm << "/"s << server << "/"s
      << "buddyicons/" << ns_id << "_l.jpg"s;
  return oss.str();
}

size_t write_to_string(void* ptr, size_t size, size_t count, void* stream) {
  ((string*)stream)->append((char*)ptr, 0, size * count);
  return size * count;
}

string convert_to_query_param_string(const std::unordered_map<string, string>& queries) {
  ostringstream ss;
  for_each(queries.cbegin(), queries.cend(), [&ss](const auto& p) { ss << p.first << "=" << p.second << "&"; });
  return ss.str();
}
}
