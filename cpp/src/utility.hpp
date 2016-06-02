#pragma once

#include <string>

using namespace std;

namespace cookpit
{
string construct_flickr_image_url(int farm, const string& server, const string& photo_id, const string& secret);

string construct_flickr_avatar_url(int farm, const string& server, const string& ns_id);
}
