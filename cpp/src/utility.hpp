#pragma once

#include <curl/curl.h>
#include <string>
#include <unordered_map>

using namespace std;

namespace cookpit
{
string construct_flickr_image_url(int farm, const string& server, const string& photo_id, const string& secret);

string construct_flickr_avatar_url(int farm, const string& server, const string& ns_id);

size_t write_to_string(void* ptr, size_t size, size_t count, void* stream);

string convert_to_query_param_string(const std::unordered_map<string, string>& queries);

void curl_get(CURL* curl_handler, const string& base_url, const unordered_map<string, string>& params,
              std::function<void(int, const string&)> success_callback,
              std::function<void(int, const string&)> failure_callback);
}
