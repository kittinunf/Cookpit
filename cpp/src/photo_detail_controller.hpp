#pragma once

#include "gen/http_observer.hpp"
#include "gen/photo_detail_controller.hpp"

using namespace std;

namespace cookpit
{
class photo_detail_controller_impl : public photo_detail_controller,
                                     public http_observer,
                                     public enable_shared_from_this<photo_detail_controller_impl> {
 public:
  void subscribe(const shared_ptr<photo_detail_controller_observer>& observer) override;
  void unsubscribe() override;

  void id(const string& id);
  void request_detail() override;

 private:
  shared_ptr<photo_detail_controller_observer> observer_;
  string id_;

  void on_failure(const string& reason) override;
  void on_success(const string& data) override;
};
}
