#include "sample_controller.hpp"
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
}

void sample_controller::unsubscribe() {}
}
