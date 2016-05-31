#include "gen/api.hpp"

using namespace std;

namespace cookpit
{
class api : public cookpit::Api {
 public:
  static api& instance();

  string path() const;
  void path(const string& path);

 private:
  string path_;
};
}
