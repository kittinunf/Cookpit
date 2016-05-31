#include "gen/http_observer.hpp"
#include "gen/sample_controller.hpp"

using namespace std;

namespace cookpit
{
class sample_controller : public SampleController,
                          public HttpObserver,
                          public enable_shared_from_this<sample_controller> {
 public:
  void subscribe(const std::shared_ptr<SampleControllerObserver>& observer) override;
  void unsubscribe() override;

 private:
  shared_ptr<SampleControllerObserver> observer_;

  void on_failure() override;
  void on_success(const std::string& data) override;
};
}
