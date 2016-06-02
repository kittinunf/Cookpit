#include "photo_detail_controller.hpp"

#include <json11.hpp>
#include <unordered_map>

#include "api.hpp"
#include "constants.hpp"
#include "gen/http.hpp"
#include "gen/photo_detail_controller_observer.hpp"
#include "gen/photo_detail_view_data.hpp"
#include "utility.hpp"

namespace cookpit
{
shared_ptr<photo_detail_controller> photo_detail_controller::create(const string& id) {
  auto controller = make_shared<photo_detail_controller_impl>();
  controller->id(id);
  return controller;
}

void photo_detail_controller_impl::subscribe(const shared_ptr<photo_detail_controller_observer>& observer) {
  observer_ = observer;
}

void photo_detail_controller_impl::unsubscribe() { observer_ = nullptr; }

void photo_detail_controller_impl::id(const string& id) { id_ = id; }

void photo_detail_controller_impl::request_detail() {
  const auto self = shared_from_this();

  unordered_map<string, string> params = {{METHOD, PHOTO_INFO}, {API_KEY, API_KEY_VALUE}, {PHOTO_ID, id_}};

  observer_->on_begin_update();
  api_impl::instance().client()->get(BASE_URL, params, self);
}

void photo_detail_controller_impl::on_failure(const string& reason) {
  string error;
  auto json = json11::Json::parse(reason, error);
  auto message = error.empty() ? json["message"].string_value() : "";
  observer_->on_update(photo_detail_view_data{true, message, id_, "", "", "", "", 0, 0});
  observer_->on_end_update();
}

void photo_detail_controller_impl::on_success(const string& data) {
  string error;
  auto json = json11::Json::parse(data, error);
  auto photo = json["photo"];

  auto owner = photo["owner"];
  auto title = photo["title"];

  auto image_url = construct_flickr_image_url(photo["farm"].int_value(), photo["server"].string_value(),
                                              photo["id"].string_value(), photo["secret"].string_value());
  auto avatar_url = construct_flickr_avatar_url(owner["iconfarm"].int_value(), owner["iconserver"].string_value(),
                                                owner["nsid"].string_value());

  observer_->on_update(photo_detail_view_data(false, json["stat"].string_value(), photo["id"].string_value(),
                                              title["_content"].string_value(), image_url,
                                              owner["username"].string_value(), avatar_url, photo["views"].string_value(),
                                              photo["comments"]["_content"].string_value()));
  observer_->on_end_update();
}
}
