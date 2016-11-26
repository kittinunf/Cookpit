#include "utility.hpp"

#include <sstream>
#include <vector>

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

template string convert_to_query_param_string<unordered_map<string, string>>(const unordered_map<string, string>&);
template string convert_to_query_param_string<vector<pair<string, string>>>(const vector<pair<string, string>>&);

template <typename T>
string convert_to_query_param_string(const T& queries) {
  ostringstream ss;
  for_each(queries.cbegin(), queries.cend(), [&ss](const auto& p) { ss << p.first << "=" << p.second << "&"; });
  return ss.str();
}

void curl_get(CURL* curl_handler, const string& url,
              function<void(const string&, int code, const string&)> success_callback,
              function<void(const string&, int code, const string&)> failure_callback) {
  string buffer;
  int code;
  curl_easy_setopt(curl_handler, CURLOPT_URL, url.c_str());
  curl_easy_setopt(curl_handler, CURLOPT_WRITEFUNCTION, write_to_string);
  curl_easy_setopt(curl_handler, CURLOPT_WRITEDATA, &buffer);
  curl_easy_setopt(curl_handler, CURLOPT_SSL_VERIFYPEER, false);
  auto res = curl_easy_perform(curl_handler);
  string response = buffer;
  curl_easy_getinfo(curl_handler, CURLINFO_RESPONSE_CODE, &code);
  if (res == CURLE_OK && code == 200) {
    success_callback(url, code, response);
  } else {
    failure_callback(url, code, response);
  }
}
}
