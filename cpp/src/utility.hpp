#pragma once

#include <curl/curl.h>
#include <experimental/optional>
#include <functional>
#include <string>

using namespace std;
using namespace std::experimental;

namespace cookpit
{
string construct_flickr_image_url(int farm, const string& server, const string& photo_id, const string& secret);

string construct_flickr_avatar_url(int farm, const string& server, const string& ns_id);

size_t write_to_string(void* ptr, size_t size, size_t count, void* stream);

template <typename T>
string convert_to_query_param_string(const T& queries);

void curl_get(CURL* curl_handler, const string& url, function<void(const string&, int, const string&)> success_callback,
              function<void(const string&, int, const string&)> failure_callback);

void curl_get(CURL* curl_handler, const string& url, const optional<string>& proxy,
              function<void(const string&, int, const string&)> success_callback,
              function<void(const string&, int, const string&)> failure_callback);
}
