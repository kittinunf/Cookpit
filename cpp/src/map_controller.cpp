#include "map_controller.hpp"

#include <json11.hpp>
#include <unordered_map>

#include "constants.hpp"
#include "coordinate.hpp"
#include "gen/map_controller_observer.hpp"
#include "gen/map_view_data.hpp"
#include "utility.hpp"

using namespace string_literals;

namespace cookpit
{
shared_ptr<map_controller> map_controller::create() { return make_shared<map_controller_impl>(); }

string map_controller::map_token() { return MAP_TOKEN; }

map_controller_impl::map_controller_impl() : curl_(curl_easy_init(), curl_easy_cleanup) {}

void map_controller_impl::subscribe(const shared_ptr<map_controller_observer>& observer) { observer_ = observer; }

void map_controller_impl::unsubscribe() { observer_ = nullptr; }

void map_controller_impl::request() {
  unordered_map<string, string> params = {
      {METHOD, PHOTOS_SEARCH}, {API_KEY, API_KEY_VALUE},   {FORMAT, JSON_FORMAT},        {NO_JSON_CALLBACK, "1"s},
      {PER_PAGE, "30"s},       {BBOX, "-180,-90,180,90"s}, {SORT, INTERESTINGNESS_DESC}, {EXTRAS, "geo"s}};

  const weak_ptr<map_controller_impl> weak_self = shared_from_this();

  observer_->on_begin_update();

  auto query_string = convert_to_query_param_string(params);
  auto url = BASE_URL + "?" + query_string;

  curl_get(curl_.get(), url,
           [weak_self](const string& /*url*/, int /*code*/, const string& response) {
             if (auto self = weak_self.lock()) {
               self->on_success(response);
             }
           },
           [weak_self](const string& /*url*/, int /*code*/, const string& reason) {
             if (auto self = weak_self.lock()) {
               self->on_failure(reason);
             }
           });
}

void map_controller_impl::on_failure(const string& /*reason*/) {}

void map_controller_impl::on_success(const string& data) {
  string error;
  auto json = json11::Json::parse(data, error);

  auto top = json["photos"];
  auto photos = top["photo"];

  vector<map_detail_view_data> details;
  transform(photos.array_items().cbegin(), photos.array_items().cend(), back_inserter(details), [](const auto& j) {
    auto id = j["id"].string_value();
    auto image_url =
        construct_flickr_image_url(j["farm"].int_value(), j["server"].string_value(), id, j["secret"].string_value());
    auto title = j["title"].string_value();

    auto lat = stod(j["latitude"].string_value());
    auto lng = stod(j["longitude"].string_value());
    return map_detail_view_data(id, image_url, title, coordinate(lat, lng));
  });

  if (observer_) {
    observer_->on_update(map_view_data{false, "ok", details});
    observer_->on_end_update();
  }
}
}
