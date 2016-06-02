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
}
