#include "gen/sample_controller.hpp"

using namespace std;

namespace cookpit
{
class sample_controller : public cookpit::SampleController {
 public:
  void subscribe(const std::shared_ptr<SampleControllerObserver>& observer) override;
  void unsubscribe() override;

 private:
  shared_ptr<SampleControllerObserver> observer_;
};
}
