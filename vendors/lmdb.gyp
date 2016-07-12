{
  'targets': [
    {
      'target_name': 'lmdb',
      'type': 'static_library',
      'sources': [
        '<!@(python ../utils/glob.py -d lmdb/libraries/liblmdb -i *.c -e *test*.cc)',
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
        'lmdb/libraries/liblmdb',
      ],
    },
  ]
}
