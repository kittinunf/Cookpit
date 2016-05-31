#include <json11.hpp>
#include "api.hpp"
#include "gen/http.hpp"
#include "gen/sample_controller_observer.hpp"
#include "gen/sample_view_data.hpp"
#include "sample_controller.hpp"

using namespace experimental;

namespace cookpit
{
shared_ptr<sample_controller> sample_controller::create() { return make_shared<sample_controller_impl>(); }

void sample_controller_impl::subscribe(const std::shared_ptr<sample_controller_observer>& observer) {
  observer_ = observer;

  if (observer_) {
    observer_->on_update(sample_view_data{"hello world from C++"});
  }

  const auto self = shared_from_this();
  api_impl::instance().client()->get("https://httpbin.org/get", nullopt, self);
}

void sample_controller_impl::unsubscribe() { observer_ = nullptr; }

void sample_controller_impl::on_success(const std::string& data) {
  string err;
  auto json = json11::Json::parse(data, err);
  auto origin = json["origin"].string_value();
  observer_->on_update(sample_view_data{origin});
}

void sample_controller_impl::on_failure() { observer_->on_update(sample_view_data{"Connection failed"}); }
}
