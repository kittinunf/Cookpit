{
  'targets': [
    {
      'target_name': 'googletest',
      'type': 'static_library',
      'sources': [
        'googletest/googletest/src/gtest-all.cc',
        'googletest/googletest/src/gtest_main.cc',
        'googletest/googlemock/src/gmock-all.cc',
        'googletest/googlemock/src/gmock_main.cc',
      ],
      'cflags_cc!': [
        '-Werror'
      ],
      'xcode_settings': {
        'OTHER_CPLUSPLUSFLAGS!' : [
          '-Werror'
        ],
      },
      'include_dirs': [
        'googletest/googletest',
        'googletest/googletest/include',
        'googletest/googlemock',
        'googletest/googlemock/include',
      ],
    },
  ]
}
