#pragma once

#include "gen/explore_controller.hpp"
#include "gen/http_observer.hpp"
#include "gen/explore_detail_view_data.hpp"

using namespace std;

namespace cookpit
{
class explore_controller_impl : public explore_controller,
                                public http_observer,
                                public enable_shared_from_this<explore_controller_impl> {
 public:
  void subscribe(const std::shared_ptr<explore_controller_observer>& observer) override;
  void unsubscribe() override;

  void request(int8_t page) override;
 private:
  shared_ptr<explore_controller_observer> observer_;
  vector<explore_detail_view_data> items_;

  void on_failure() override;
  void on_success(const std::string& data) override;
};
}
