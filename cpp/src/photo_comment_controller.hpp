#pragma once

#include <curl/curl.h>
#include <vector>

#include "gen/photo_comment_controller.hpp"
#include "gen/photo_comment_detail_view_data.hpp"

using namespace std;

namespace cookpit
{
class photo_comment_controller_impl : public photo_comment_controller,
                                      public enable_shared_from_this<photo_comment_controller_impl> {
 public:
  photo_comment_controller_impl(const string& id);

  void subscribe(const shared_ptr<photo_comment_controller_observer>& observer) override;
  void unsubscribe() override;

  void request_comments() override;

 private:
  std::unique_ptr<CURL, decltype(&curl_easy_cleanup)> curl_;
  shared_ptr<photo_comment_controller_observer> observer_;
  vector<photo_comment_detail_view_data> items_;
  string id_;

  void on_failure(const string& reason);
  void on_success(const string& data);
};
}
