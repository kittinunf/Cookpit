#include "gen/api.hpp"

using namespace std;

namespace cookpit
{
class api : public cookpit::Api {
 public:
  static api& instance();

  string path() const;
  void path(const string& path);

  shared_ptr<Http> client() const;
  void client(const shared_ptr<Http>& http_client);

 private:
  string path_;

  shared_ptr<Http> http_client_;
};
}
