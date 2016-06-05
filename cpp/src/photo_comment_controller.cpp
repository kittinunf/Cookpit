#include "photo_comment_controller.hpp"

#include <json11.hpp>
#include <unordered_map>

#include "api.hpp"
#include "constants.hpp"
#include "gen/http.hpp"
#include "gen/photo_comment_controller_observer.hpp"
#include "gen/photo_comment_view_data.hpp"
#include "utility.hpp"

namespace cookpit
{
shared_ptr<photo_comment_controller> photo_comment_controller::create(const string& id) {
  auto controller = make_shared<photo_comment_controller_impl>();
  controller->id(id);
  return controller;
}

void photo_comment_controller_impl::subscribe(const shared_ptr<photo_comment_controller_observer>& observer) {
  observer_ = observer;
}

void photo_comment_controller_impl::unsubscribe() { observer_ = nullptr; }

void photo_comment_controller_impl::id(const string& id) { id_ = id; }

void photo_comment_controller_impl::request_comments() {
  const auto self = shared_from_this();

  unordered_map<string, string> params = {{METHOD, PHOTOS_COMMENTS_GETLIST}, {API_KEY, API_KEY_VALUE}, {PHOTO_ID, id_}};

  observer_->on_begin_update();
  api_impl::instance().client()->get(BASE_URL, params, self);
}

void photo_comment_controller_impl::on_failure(const string& reason) {
  string error;
  auto json = json11::Json::parse(reason, error);
  auto message = error.empty() ? json["message"].string_value() : "";
  observer_->on_update(photo_comment_view_data{true, message, items_});
  observer_->on_end_update();
}

void photo_comment_controller_impl::on_success(const string& data) {
  string error;
  auto json = json11::Json::parse(data, error);
  
  auto topComments = json["comments"];
  auto comments = topComments["comment"].array_items();
  
  vector<photo_comment_detail_view_data> details;
  transform(comments.cbegin(), comments.cend(), back_inserter(details), [](const auto& j){
    auto id = j["id"].string_value();
    auto author_name = j["authorname"].string_value();
    auto author_avatar_url = construct_flickr_avatar_url(j["iconfarm"].int_value(), j["iconserver"].string_value(), j["author"].string_value());
    auto text = j["_content"].string_value();
    return photo_comment_detail_view_data{id, author_name, author_avatar_url, text};
  });
  
  observer_->on_update(photo_comment_view_data(false, json["stat"].string_value(), details));
  observer_->on_end_update();
}
}
