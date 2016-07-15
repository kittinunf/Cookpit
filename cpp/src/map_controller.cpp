#include "map_controller.hpp"

#include "constants.hpp"

namespace cookpit {

shared_ptr<map_controller> map_controller::create() { return make_shared<map_controller_impl>(); }

string map_controller::map_token() { return MAP_TOKEN; }

map_controller_impl::map_controller_impl() : curl_(curl_easy_init(), curl_easy_cleanup) { }

void map_controller_impl::subscribe(const std::shared_ptr<map_controller_observer> &observer) {
  observer_ = observer;
}

void map_controller_impl::unsubscribe() {
  observer_ = nullptr;
}

void map_controller_impl::request() {
  
}

void map_controller_impl::on_failure(const string &/*reason*/) {
}

void map_controller_impl::on_success(const string &/*data*/) {
}
  
}
