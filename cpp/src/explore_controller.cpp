#include "explore_controller.hpp"

#include <json11.hpp>
#include <sstream>

#include "api.hpp"
#include "constants.hpp"
#include "gen/explore_controller_observer.hpp"
#include "gen/explore_view_data.hpp"
#include "gen/http.hpp"

using namespace experimental;
using namespace string_literals;

namespace cookpit
{
shared_ptr<explore_controller> explore_controller::create() { return make_shared<explore_controller_impl>(); }

void explore_controller_impl::subscribe(const shared_ptr<explore_controller_observer>& observer) {
  observer_ = observer;
}

void explore_controller_impl::unsubscribe() { observer_ = nullptr; }

void explore_controller_impl::reset() { items_.clear(); }

void explore_controller_impl::request(int8_t page) {
  const auto self = shared_from_this();

  unordered_map<string, string> params = {
      {METHOD, INTERESTINGNESS_GETLIST}, {API_KEY, API_KEY_VALUE}, {PER_PAGE, "10"s}, {PAGE, to_string(page)}};

  observer_->on_begin_update();
  api_impl::instance().client()->get(BASE_URL, params, self);
}

void explore_controller_impl::on_failure(const string& reason) {
  string error;
  auto json = json11::Json::parse(reason, error);
  auto message = error.empty() ? json["message"].string_value() : "";
  observer_->on_update(explore_view_data{true, message, items_});
  observer_->on_end_update();
}

void explore_controller_impl::on_success(const string& data) {
  string error;
  auto json = json11::Json::parse(data, error);

  auto topPhotos = json["photos"];
  auto photoArray = topPhotos["photo"];

  auto photos = photoArray.array_items();

  std::vector<explore_detail_view_data> details;
  transform(photos.cbegin(), photos.cend(), back_inserter(details), [](const auto& j) {
    ostringstream oss;
    oss << "https://farm"s << j["farm"].int_value() << ".static.flickr.com/"s << j["server"].string_value() << "/"s
        << j["id"].string_value() << "_" << j["secret"].string_value() << "_z.jpg"s;

    auto id = j["id"].string_value();
    auto image_url = oss.str();
    auto title = j["title"].string_value();

    return explore_detail_view_data{id, image_url, title};
  });

  items_.insert(items_.end(), details.begin(), details.end());
  observer_->on_update(explore_view_data{false, json["stat"].string_value(), items_});
  observer_->on_end_update();
}
}
