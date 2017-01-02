#pragma once

#include <curl/curl.h>

#include "gen/map_controller.hpp"

using namespace std;

namespace cookpit
{
class map_controller_impl : public map_controller, public enable_shared_from_this<map_controller_impl> {
 public:
  map_controller_impl();

  void subscribe(const shared_ptr<map_controller_observer>& observer) override;
  void unsubscribe() override;

  void request() override;

 private:
  unique_ptr<CURL, decltype(&curl_easy_cleanup)> curl_;
  shared_ptr<map_controller_observer> observer_;

  void on_failure(const string& reason);
  void on_success(const string& data);
};
}
