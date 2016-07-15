#pragma once

#include <string>

namespace cookpit
{
using namespace std;

const string BASE_URL = "https://api.flickr.com/services/rest/";

const string MAP_TOKEN = "pk.eyJ1Ijoia2l0dGludW5mIiwiYSI6ImNpcTZyY2MwODAwaDBmcW02N3JweTk3M2wifQ.zM0-aialUeNtcCslIVG1ow";
// key
const string METHOD = "method";
const string API_KEY = "api_key";
const string FORMAT = "format";
const string NO_JSON_CALLBACK = "nojsoncallback";
const string PER_PAGE = "per_page";
const string PAGE = "page";
const string TEXT = "text";
const string PHOTO_ID = "photo_id";

// value
const string API_KEY_VALUE = "21d58b359476ca14401d40590b495c0d";
const string JSON_FORMAT = "json";
const string INTERESTINGNESS_GETLIST = "flickr.interestingness.getList";
const string PHOTOS_SEARCH = "flickr.photos.search";
const string PHOTOS_INFO = "flickr.photos.getInfo";
const string PHOTOS_COMMENTS_GETLIST = "flickr.photos.comments.getList";
}
