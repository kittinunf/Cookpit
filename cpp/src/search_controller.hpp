#pragma once

#include <curl/curl.h>
#include <set>
#include <vector>

#include "gen/search_controller.hpp"
#include "gen/search_detail_view_data.hpp"

using namespace std;

namespace cookpit
{
class search_controller_impl : public search_controller, public enable_shared_from_this<search_controller_impl> {
 public:
  search_controller_impl();

  void subscribe(const shared_ptr<search_controller_observer>& observer) override;
  void unsubscribe() override;

  void reset() override;
  vector<string> fetch_recents() override;
  void search(const string& key, int8_t page) override;

 private:
  std::unique_ptr<CURL, decltype(&curl_easy_cleanup)> curl_;
  shared_ptr<search_controller_observer> observer_;

  vector<search_detail_view_data> items_;
  set<string> recent_search_key_;

  void on_failure(const string& reason);
  void on_success(const string& data);
};
}
