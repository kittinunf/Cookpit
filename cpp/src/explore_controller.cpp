#include "explore_controller.hpp"

#include <json11.hpp>
#include <sstream>

#include "api.hpp"
#include "constants.hpp"
#include "gen/explore_controller_observer.hpp"
#include "gen/explore_view_data.hpp"
#include "utility.hpp"

using namespace string_literals;

namespace cookpit
{
shared_ptr<explore_controller> explore_controller::create() { return make_shared<explore_controller_impl>(); }

explore_controller_impl::explore_controller_impl() : curl_(curl_easy_init(), curl_easy_cleanup) {}

void explore_controller_impl::subscribe(const shared_ptr<explore_controller_observer>& observer) {
  observer_ = observer;
}

void explore_controller_impl::unsubscribe() { observer_ = nullptr; }

void explore_controller_impl::reset() { items_.clear(); }

void explore_controller_impl::request(int8_t page) {
  unordered_map<string, string> params = {
      {METHOD, INTERESTINGNESS_GETLIST}, {API_KEY, API_KEY_VALUE}, {FORMAT, JSON_FORMAT},
      {NO_JSON_CALLBACK, "1"s},          {PER_PAGE, "10"s},        {PAGE, to_string(page)}};

  const weak_ptr<explore_controller_impl> weak_self = shared_from_this();

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

void explore_controller_impl::on_failure(const string& reason) {
  string error;
  auto json = json11::Json::parse(reason, error);
  auto message = error.empty() ? json["message"].string_value() : "There is something wrong, please try again later";
  observer_->on_update(explore_view_data{true, message, items_});
}

void explore_controller_impl::on_success(const string& data) {
  string error;
  auto json = json11::Json::parse(data, error);

  auto topPhotos = json["photos"];
  auto photoArray = topPhotos["photo"];

  auto photos = photoArray.array_items();

  vector<explore_detail_view_data> details;
  transform(photos.cbegin(), photos.cend(), back_inserter(details), [](const auto& j) {
    auto id = j["id"].string_value();
    auto image_url =
        construct_flickr_image_url(j["farm"].int_value(), j["server"].string_value(), id, j["secret"].string_value());
    auto title = j["title"].string_value();

    return explore_detail_view_data{id, image_url, title};
  });

  items_.insert(items_.end(), details.begin(), details.end());
  observer_->on_update(explore_view_data{false, json["stat"].string_value(), items_});
}
}
