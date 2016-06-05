#pragma once

#include <vector>

#include "gen/http_observer.hpp"
#include "gen/photo_comment_detail_view_data.hpp"
#include "gen/photo_comment_controller.hpp"

using namespace std;

namespace cookpit
{
class photo_comment_controller_impl : public photo_comment_controller,
                                     public http_observer,
                                     public enable_shared_from_this<photo_comment_controller_impl> {
 public:
  void subscribe(const shared_ptr<photo_comment_controller_observer>& observer) override;
  void unsubscribe() override;

  void id(const string& id);
  void request_comments() override;

 private:
  shared_ptr<photo_comment_controller_observer> observer_;
  vector<photo_comment_detail_view_data> items_;
  string id_;

  void on_failure(const string& reason) override;
  void on_success(const string& data) override;
};
}
