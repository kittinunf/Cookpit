#pragma once

#include <curl/curl.h>

#include "gen/http_observer.hpp"
#include "gen/photo_detail_controller.hpp"

using namespace std;

namespace cookpit
{
class photo_detail_controller_impl : public photo_detail_controller,
                                     public enable_shared_from_this<photo_detail_controller_impl> {
 public:
  photo_detail_controller_impl(const string& id);

  void subscribe(const shared_ptr<photo_detail_controller_observer>& observer) override;
  void unsubscribe() override;

  void request_detail() override;

 private:
  std::unique_ptr<CURL, decltype(&curl_easy_cleanup)> curl_;
  shared_ptr<photo_detail_controller_observer> observer_;
  string id_;

  void on_failure(const string& reason);
  void on_success(const string& data);
};
}
