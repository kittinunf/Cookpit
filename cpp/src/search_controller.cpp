#include "search_controller.hpp"

#include <json11.hpp>
#include <set>
#include <sstream>

#include "api.hpp"
#include "constants.hpp"
#include "gen/search_controller_observer.hpp"
#include "gen/search_view_data.hpp"
#include "utility.hpp"

namespace cookpit
{
shared_ptr<search_controller> search_controller::create() { return make_shared<search_controller_impl>(); }

search_controller_impl::search_controller_impl() : curl_(curl_easy_init(), curl_easy_cleanup) {}

void search_controller_impl::subscribe(const shared_ptr<search_controller_observer>& observer) { observer_ = observer; }

void search_controller_impl::reset() { items_.clear(); }

vector<string> search_controller_impl::fetch_recents() {
  vector<string> keys(recent_search_key_.size());
  keys.insert(keys.begin(), recent_search_key_.begin(), recent_search_key_.end());
  return keys;
}

void search_controller_impl::search(const string& key, int8_t page) {
  // save item into recent search
  recent_search_key_.insert(key);

  // replace space if any to '+'
  auto converted_key = key;
  transform(converted_key.begin(), converted_key.end(), converted_key.begin(),
            [](auto ch) { return ch == ' ' ? '+' : ch; });

  unordered_map<string, string> params = {{METHOD, PHOTOS_SEARCH}, {API_KEY, API_KEY_VALUE}, {TEXT, converted_key},
                                          {FORMAT, JSON_FORMAT},   {NO_JSON_CALLBACK, "1"s}, {PER_PAGE, "25"s},
                                          {PAGE, to_string(page)}};

  const weak_ptr<search_controller_impl> weak_self = shared_from_this();

  observer_->on_begin_update();
  curl_get(curl_.get(), BASE_URL, params,
           [weak_self](int /*code*/, const string& response) {
             if (auto self = weak_self.lock()) {
               self->on_success(response);
               self->observer_->on_end_update();
             }
           },
           [weak_self](int /*code*/, const string& response) {
             if (auto self = weak_self.lock()) {
               self->on_failure(response);
               self->observer_->on_end_update();
             }
           });
}

void search_controller_impl::unsubscribe() { observer_ = nullptr; }

void search_controller_impl::on_failure(const string& reason) {
  string error;
  auto json = json11::Json::parse(reason, error);
  auto message = error.empty() ? json["message"].string_value() : "";
  observer_->on_update(search_view_data({true, message, items_}));
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
}
}
