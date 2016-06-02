#include "search_controller.hpp"

#include <json11.hpp>
#include <set>
#include <sstream>

#include "api.hpp"
#include "constants.hpp"
#include "gen/http.hpp"
#include "gen/recent_search_view_data.hpp"
#include "gen/search_controller_observer.hpp"
#include "gen/search_view_data.hpp"
#include "utility.hpp"

using namespace experimental;

namespace cookpit
{
shared_ptr<search_controller> search_controller::create() { return make_shared<search_controller_impl>(); }

void search_controller_impl::subscribe(const shared_ptr<search_controller_observer>& observer) { observer_ = observer; }

void search_controller_impl::reset() {
  items_.clear();
  observer_->on_begin_update();
  observer_->on_update(search_view_data({true, "", items_}));
  observer_->on_end_update();
}

vector<string> search_controller_impl::fetch_recents() {
  vector<string> keys(recent_search_key_.size());
  keys.insert(keys.begin(), recent_search_key_.begin(), recent_search_key_.end());
  return keys;
}

void search_controller_impl::search(const string& key, int8_t page) {
  recent_search_key_.insert(key);

  const auto self = shared_from_this();

  unordered_map<string, string> params = {
      {METHOD, PHOTOS_SEARCH}, {API_KEY, API_KEY_VALUE}, {TEXT, key}, {PER_PAGE, "25"s}, {PAGE, to_string(page)}};

  observer_->on_begin_update();
  api_impl::instance().client()->get(BASE_URL, params, self);
}

void search_controller_impl::unsubscribe() { observer_ = nullptr; }

void search_controller_impl::on_failure(const string& reason) {
  string error;
  auto json = json11::Json::parse(reason, error);
  auto message = error.empty() ? json["message"].string_value() : "";
  observer_->on_update(search_view_data({true, message, items_}));
  observer_->on_end_update();
}

void search_controller_impl::on_success(const string& data) {
  string err;
  auto json = json11::Json::parse(data, err);

  auto topPhotos = json["photos"];
  auto photoArray = topPhotos["photo"];

  auto photos = photoArray.array_items();

  std::vector<search_detail_view_data> details;
  transform(photos.cbegin(), photos.cend(), back_inserter(details), [](const auto& j) {
    auto id = j["id"].string_value();
    auto image_url =
        construct_flickr_image_url(j["farm"].int_value(), j["server"].string_value(), id, j["secret"].string_value());
    auto title = j["title"].string_value();

    return search_detail_view_data{id, image_url, title};
  });

  items_.insert(items_.end(), details.begin(), details.end());
  observer_->on_update(search_view_data{false, json["stat"].string_value(), items_});
  observer_->on_end_update();
}
}
