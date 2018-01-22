#include "explore_controller.hpp"

#include <json11.hpp>

#include "api.hpp"
#include "constants.hpp"
#include "gen/explore_controller_observer.hpp"
#include "gen/explore_view_data.hpp"
#include "utility.hpp"

const int item_per_page = 10;

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
  const weak_ptr<explore_controller_impl> weak_self = shared_from_this();

  observer_->on_begin_update();

  auto data = request_db(page);
  auto item_per_page = 10;
  if (items_.size() >= (size_t)(page * item_per_page)) {
    auto start = items_.begin() + ((page - 1) * item_per_page);
    copy(data.cbegin(), data.cend(), start);
  } else {
    items_.insert(items_.end(), data.cbegin(), data.cend());
  }
  observer_->on_update(explore_view_data{false, "cache", items_});

  auto url = construct_url(BASE_URL, page);
  curl_get(curl_.get(), url, api_impl::instance().proxy(),
           [weak_self](const string& url, int /*code*/, const string& response) {
             if (auto self = weak_self.lock()) {
               self->on_success(url, response);
             }
           },
           [weak_self](const string& url, int /*code*/, const string& response) {
             if (auto self = weak_self.lock()) {
               self->on_failure(url, response);
             }
           });
}

vector<explore_detail_view_data> explore_controller_impl::request_db(int8_t page) {
  auto env = api_impl::instance().db("explore");
  auto txn = lmdb::txn::begin(env, nullptr, MDB_RDONLY);
  auto db = lmdb::dbi::open(txn);
  auto cursor = lmdb::cursor::open(txn, db);
  auto url = construct_url(BASE_URL, page);

  string key, value;
  vector<explore_detail_view_data> results;
  while (cursor.get(key, value, MDB_NEXT)) {
    if (key == url) {
      results = construct_detail_view_data_from_data(value);
      break;
    }
  }

  cursor.close();
  txn.abort();
  return results;
}

void explore_controller_impl::on_failure(const string& /*url*/, const string& reason) {
  string error;
  auto json = json11::Json::parse(reason, error);
  auto message = error.empty() ? json["message"].string_value() : "There is something wrong, please try again later";
  if (observer_) {
    observer_->on_update(explore_view_data{true, message, items_});
    observer_->on_end_update();
  }
}

void explore_controller_impl::on_success(const string& url, const string& data) {
  auto details = construct_detail_view_data_from_data(data);

  auto page = -1;
  auto found = url.find("page=");
  if (found != string::npos) {
    page = stoi(url.substr(found + 5, 1));
  }

  if (page == -1) return;

  if (items_.size() >= (size_t)(page * item_per_page)) {
    auto start = items_.begin() + ((page - 1) * item_per_page);
    copy(details.cbegin(), details.cend(), start);
  } else {
    items_.insert(items_.end(), details.cbegin(), details.cend());
  }

  if (observer_) {
    observer_->on_update(explore_view_data{false, "ok", items_});
    observer_->on_end_update();
  }

  // save into our db
  auto env = api_impl::instance().db("explore");
  auto wtxn = lmdb::txn::begin(env);
  auto dbi = lmdb::dbi::open(wtxn);
  dbi.put(wtxn, url.c_str(), data.c_str());
  wtxn.commit();
}

vector<explore_detail_view_data> explore_controller_impl::construct_detail_view_data_from_data(const string& data) {
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
  return details;
}

string explore_controller_impl::construct_url(const string& url, int8_t page) {
  vector<pair<string, string>> params = {
      {METHOD, INTERESTINGNESS_GETLIST}, {API_KEY, API_KEY_VALUE}, {FORMAT, JSON_FORMAT},
      {NO_JSON_CALLBACK, "1"s},          {PAGE, to_string(page)},  {PER_PAGE, to_string(item_per_page)}};
  auto query_string = convert_to_query_param_string(params);
  return url + "?" + query_string;
}
}
