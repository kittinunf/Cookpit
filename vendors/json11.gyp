{
  'targets': [
    {
      'target_name': 'json11',
      'type': 'static_library',
      'sources': [
        'json11/json11.cpp',
      ],
      'cflags_cc!': [
        '-Werror',
        '-fno-rtti',
        '-fno-exceptions',
      ],
      'xcode_settings': {
        'OTHER_CPLUSPLUSFLAGS!' : [
          '-Werror',
          '-fno-rtti',
          '-fno-exceptions',
        ],
      },
      'include_dirs': [
        'json11',
      ],
    },
  ]
}
