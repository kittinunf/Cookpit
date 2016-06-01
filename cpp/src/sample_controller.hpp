#pragma once

#include "gen/http_observer.hpp"
#include "gen/sample_controller.hpp"

using namespace std;

namespace cookpit
{
class sample_controller_impl : public sample_controller,
                               public http_observer,
                               public enable_shared_from_this<sample_controller_impl> {
 public:
  void subscribe(const shared_ptr<sample_controller_observer>& observer) override;
  void unsubscribe() override;

 private:
  shared_ptr<sample_controller_observer> observer_;

  void on_failure(const string& reason) override;
  void on_success(const string& data) override;
};
}
