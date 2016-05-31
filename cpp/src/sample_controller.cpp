#include "sample_controller.hpp"
#include "api.hpp"
#include "gen/http.hpp"
#include "gen/sample_controller_observer.hpp"
#include "gen/sample_view_data.hpp"

namespace cookpit
{
shared_ptr<SampleController> SampleController::create() { return make_shared<sample_controller>(); }

void sample_controller::subscribe(const std::shared_ptr<SampleControllerObserver>& observer) {
  observer_ = observer;

  if (observer_) {
    observer_->on_update(SampleViewData{"hello world from C++"});
  }

  const auto self = shared_from_this();
  api::instance().client()->get("https://httpbin.org/get", self);
}

void sample_controller::unsubscribe() { observer_ = nullptr; }

void sample_controller::on_success(const std::string& data) { observer_->on_update(SampleViewData{data}); }

void sample_controller::on_failure() { observer_->on_update(SampleViewData{"Connection failed"}); }
}
