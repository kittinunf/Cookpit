#pragma once

#include <set>
#include <vector>

#include "gen/http_observer.hpp"
#include "gen/search_controller.hpp"
#include "gen/search_detail_view_data.hpp"

using namespace std;

namespace cookpit
{
class search_controller_impl : public search_controller,
                               public http_observer,
                               public enable_shared_from_this<search_controller_impl> {
 public:
  void subscribe(const shared_ptr<search_controller_observer>& observer) override;
  void unsubscribe() override;

  void reset() override;
  vector<string> fetch_recents() override;
  void search(const string& key, int8_t page) override;

 private:
  shared_ptr<search_controller_observer> observer_;

  vector<search_detail_view_data> items_;
  set<string> recent_search_key_;

  void on_failure(const string& reason) override;
  void on_success(const string& data) override;
};
}
