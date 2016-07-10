#pragma once

#include <curl/curl.h>
#include <vector>

#include "gen/explore_controller.hpp"
#include "gen/explore_detail_view_data.hpp"

using namespace std;

namespace cookpit
{
class explore_controller_impl : public explore_controller, public enable_shared_from_this<explore_controller_impl> {
 public:
  explore_controller_impl();

  void subscribe(const shared_ptr<explore_controller_observer>& observer) override;
  void unsubscribe() override;

  void reset() override;
  void request(int8_t page) override;

 private:
  std::unique_ptr<CURL, decltype(&curl_easy_cleanup)> curl_;
  shared_ptr<explore_controller_observer> observer_;

  // data
  vector<explore_detail_view_data> items_;

  void on_failure(const string& reason);
  void on_success(const string& data);
};
}
