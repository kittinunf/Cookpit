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
  return make_shared<photo_comment_controller_impl>(id);
}

photo_comment_controller_impl::photo_comment_controller_impl(const string& id)
    : curl_(curl_easy_init(), curl_easy_cleanup), id_(id) {}

void photo_comment_controller_impl::subscribe(const shared_ptr<photo_comment_controller_observer>& observer) {
  observer_ = observer;
}

void photo_comment_controller_impl::unsubscribe() { observer_ = nullptr; }

void photo_comment_controller_impl::request_comments() {
  unordered_map<string, string> params = {{METHOD, PHOTOS_COMMENTS_GETLIST},
                                          {API_KEY, API_KEY_VALUE},
                                          {PHOTO_ID, id_},
                                          {FORMAT, JSON_FORMAT},
                                          {NO_JSON_CALLBACK, "1"s}};

  const weak_ptr<photo_comment_controller_impl> weak_self = shared_from_this();

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

void photo_comment_controller_impl::on_failure(const string& reason) {
  string error;
  auto json = json11::Json::parse(reason, error);
  auto message = error.empty() ? json["message"].string_value() : "";
  observer_->on_update(photo_comment_view_data{true, message, items_});
}

void photo_comment_controller_impl::on_success(const string& data) {
  string error;
  auto json = json11::Json::parse(data, error);

  auto topComments = json["comments"];
  auto comments = topComments["comment"].array_items();

  vector<photo_comment_detail_view_data> details;
  transform(comments.cbegin(), comments.cend(), back_inserter(details), [](const auto& j) {
    auto id = j["id"].string_value();
    auto author_name = j["authorname"].string_value();
    auto author_avatar_url = construct_flickr_avatar_url(j["iconfarm"].int_value(), j["iconserver"].string_value(),
                                                         j["author"].string_value());
    auto text = j["_content"].string_value();
    return photo_comment_detail_view_data{id, author_name, author_avatar_url, text};
  });

  observer_->on_update(photo_comment_view_data(false, json["stat"].string_value(), details));
}
}
